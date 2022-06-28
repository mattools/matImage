function [fd, labels] = imFeretDiameter(img, varargin)
% Feret diameter of region(s) for a given direction(s).
%
%   FD = imFeretDiameter(IMG, THETA);
%   Compute the Feret diameter for the region(s) in the (binary or label)
%   image IMG, for the direction THETA, given in degrees. 
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each region in IMG.
%
%   THETA can be a set of directions. In this case, the result has as many
%   columns as the number of directions, and as many rows as the number of
%   regions.
%
%   FD3D = imFeretDiameter(IMG3D, THETA);
%   Computes Feret diameter for region(s) within a 3D image. In that case,
%   THETA must be specified as a Nt-by-3 array of vectors representing the
%   direction vectors to use.
%
%
%   FD = imFeretDiameter(IMG);
%   Uses a default set of directions (180) for computing Feret diameters.
%
%   FD = imFeretDiameter(IMG, THETA, SPACING);
%   Specifies the spatial calibration of image. SPACING = [SX SY] is a
%   1-by-2 row vector that contains the size of a pixel. 
%   Default spacing value is [1 1].
%
%   FD = imFeretDiameter(IMG, THETA, SPACING, ORIGIN);
%   Also specifies the position of the upper left pixel, as a 1-by-2 row
%   vector.
%
%   FD = imFeretDiameter(..., LABELS);
%   Specifies the labels for which the Feret diameter should be computed.
%   LABELS is a N-by-1 column vector. This can be used to save computation
%   time when only few regions / regions are of interset within the
%   entire image.
%
%   [FD, LABELS] = imFeretDiameter(...);
%   Also returns the set of labels that were considered for measure.
%
%   The maximum Feret diameter can be obtained using a max() function, or
%   by calling the "imMaxFeretDiameter" function.
%
%   Example:
%     % compute Feret diameter for a discrete square
%     img = zeros(100, 100, 'uint8');
%     img(21:80, 21:80) = 1;
%     theta = linspace(0, 180, 201);
%     fd = imFeretDiameter(img, theta);
%     figure(1); clf; set(gca, 'fontsize', 14);
%     plot(theta, fd); xlim([0 180]);
%     xlabel('Angle (in degrees)');
%     ylabel('Diameter (in pixels)');
%     title('Feret diameter of discrete square');
%
%   % max Feret diameter:
%     diam = max(fd, [], 2)
%     ans =
%        84.4386
%
%   % Compute 3D Feret diameter of a box
%     img = false([8 10 6]);
%     img(2:end-1, 2:end-1, 2:end-1) = true; % create a 8x6x4 box
%     imFeretDiameter(img, [1 0 0])
%     ans =
%           8
%     imFeretDiameter(img, [0 1 0])
%     ans =
%           6
%     imFeretDiameter(img, [0 0 1])
%     ans =
%           4
%
%   See also 
%     imMaxFeretDiameter, imOrientedBox, imBoundingBox
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-03-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2011-02-06 update doc, use convex hull, use degrees instead of radians


%% Process input arguments

% determine dimensionality of input image
nd = ndims(img);

% default spatial calibration
spacing = ones(1, nd);
origin  = ones(1, nd);
calib   = false;

% Extract number of orientations
theta = 180;
if ~isempty(varargin)
    var1 = varargin{1};
    if isscalar(var1)
        % Number of directions given as scalar
        theta = var1;
        varargin(1) = [];
        
    elseif ndims(var1) == 2 && sum(size(var1) ~= [1 nd]) ~= 0 %#ok<ISMAT>
        % direction set given as vector
        theta = var1(:);
        varargin(1) = [];

    elseif ndims(var1) == 2 && size(var1, 2)==nd %#ok<ISMAT>
        % direction given as a list of vectors
        theta = var1;
        varargin(1) = [];

    end
end

% extract spatial calibration
if ~isempty(varargin) && sum(size(varargin{1}) == [1 nd]) == 2
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = zeros(1, nd);
    
    % extract origin
    if ~isempty(varargin) && sum(size(varargin{1}) == [1 nd]) == 2
        origin = varargin{1};
        varargin(1) = [];
    end
end

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end


%% Initialisations

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);

% allocate memory for result
nThetas = size(theta, 1);
fd = zeros(nLabels, nThetas);


%% Process

if nd == 2
    % iterate over labels
    for i = 1:nLabels
        % extract pixel coordinates
        [y, x] = find(img==labels(i));
        if isempty(x)
            continue;
        end

        % transform to physical space if needed
        if calib
            x = (x-1) * spacing(1) + origin(1);
            y = (y-1) * spacing(2) + origin(2);
        end

        % keep only points of the convex hull
        try
            inds = convhull(x, y);
            x = x(inds);
            y = y(inds);
        catch ME %#ok<NASGU>
            % an exception can occur if points are colinear.
            % in this case we transform all points
        end

        % recenter points (should be better for numerical accuracy)
        x = x - mean(x);
        y = y - mean(y);

        % iterate over orientations
        for t = 1:nThetas
            % convert angle to radians, and change sign (to make transformed
            % points aligned along x-axis)
            theta2 = -theta(t) * pi / 180;

            % compute only transformed x-coordinate
            x2  = x * cos(theta2) - y * sin(theta2);

            % compute diameter for extreme coordinates
            xmin    = min(x2);
            xmax    = max(x2);

            % store result (add 1 pixel to consider pixel width)
            dl = spacing(1) * abs(cos(theta2)) + spacing(2) * abs(sin(theta2));
            fd(i, t) = xmax - xmin + dl;
        end
    end
    
elseif nd == 3
    % pre-process directions
    thetaNorm = normalizeVector3d(theta);

    % iterate over labels
    for i = 1:nLabels
        % extract voxel coordinates
        inds = find(img==labels(i));
        if isempty(inds)
            continue;
        end
        [y, x, z] = ind2sub(size(img), inds);

        % transform to physical space if needed
        if calib
            x = (x-1) * spacing(1) + origin(1);
            y = (y-1) * spacing(2) + origin(2);
            z = (z-1) * spacing(3) + origin(3);
        end

        % keep only points of the convex hull
        try
            inds = unique(convhull(x, y, z));
            x = x(inds);
            y = y(inds);
            z = z(inds);
        catch ME %#ok<NASGU>
            % an exception can occur if points are colinear.
            % in this case we transform all points
        end

        % recenter points (should be better for numerical accuracy)
        x = x - mean(x);
        y = y - mean(y);
        z = z - mean(z);
        pts = [x y z];

        % iterate over orientations
        for t = 1:nThetas
            % assumes theta are given as 3D vectors
            proj = sum(bsxfun(@times, pts, thetaNorm(t,:)), 2);

            % compute diameter for extreme coordinates
            xmin    = min(proj);
            xmax    = max(proj);

            % store result (add 1 pixel to consider pixel width)
            dl = sum(spacing .* thetaNorm(t,:));
            fd(i, t) = xmax - xmin + dl;
        end
    end

else
    error('Unable to process image with dimensionality %d', nd);
end
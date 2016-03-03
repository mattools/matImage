function [fd, labels] = imFeretDiameter(img, varargin)
%IMFERETDIAMETER Feret diameter of a particle(s) for a given direction(s)
%
%   FD = imFeretDiameter(IMG, THETA);
%   Compute the Feret diameter for particles in image IMG (binary or
%   label), for the direction THETA, given in degrees.
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each particle in IMG.
%
%   THETA can be a set of directions. In this case, the result has as many
%   columns as the number of directions, and as many rows as the number of
%   particles.
%
%   FD = imFeretDiameter(IMG);
%   Uses a default set of directions for computing Feret diameter.
%
%   FD = imFeretDiameter(..., SPACING);
%   Specifies the spatial calibration of image. SPACING = [SX SY] is a
%   1-by-2 row vector that contains the size of a pixel. 
%   Default spacing value is [1 1].
%
%   FD = imFeretDiameter(..., SPACING, ORIGIN);
%   Also specifies the position of the upper left pixel, as a 1-by-2 row
%   vector.
%
%   FD = imFeretDiameter(..., LABELS);
%   Specifies the labels for which the Feret diameter should be computed.
%   LABELS is a N-by-1 column vector. This can be used to save computation
%   time when only few particles / regions are of interset within the
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
%   See also 
%     imMaxFeretDiameter, imOrientedBox

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-03-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2011-02-06 update doc, use convex hull, use degrees instead of radians


%% Extract number of orientations

theta = 180;
if ~isempty(varargin)
    var1 = varargin{1};
    if isscalar(var1)
        % Number of directions given as scalar
        theta = var1;
        varargin(1) = [];
        
    elseif ndims(var1) == 2 && sum(size(var1) ~= [1 2]) ~= 0 %#ok<ISMAT>
        % direction set given as vector
        theta = var1;
        varargin(1) = [];
    end
end


%% Extract spatial calibration

% default values
spacing = [1 1];
origin  = [1 1];
calib   = false;

% extract spacing
if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = [0 0];
end

% extract origin
if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
    origin = varargin{1};
end


%% Initialisations

nTheta = length(theta);

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);

% allocate memory for result
fd = zeros(nLabels, nTheta);

for i = 1:nLabels
    % extract pixel centroids
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
    for t = 1:nTheta
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


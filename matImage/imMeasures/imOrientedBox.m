function [rect, labels] = imOrientedBox(img, varargin)
%IMORIENTEDBOX Minimum-area oriented bounding box of particles in image
%
%   OBB = imOrientedBox(IMG);
%   Computes the minimum area oriented bounding box of labels in image IMG.
%   IMG is either a binary or a label image. The result OBB is a N-by-5
%   array, containing the center, the length, the width, and the
%   orientation of the bounding box of each particle in image.
%
%   The orientation is given in degrees, in the direction of the largest
%   box axis.
%
%   OBB = imOrientedBox(..., SPACING);
%   OBB = imOrientedBox(..., SPACING, ORIGIN);
%   Specifies the spatial calibration of image. Both SPACING and ORIGIN are
%   1-by-2 row vectors. SPACING = [SX SY] contains the size of a pixel.
%   ORIGIN = [OX OY] contains the center position of the top-left pixel of
%   image. 
%   If no calibration is specified, spacing = [1 1] and origin = [1 1] are
%   used. If only the sapcing is specified, the origin is set to [0 0].
%
%   OBB = imOrientedBox(..., PNAME, PVALUE);
%   Specify optional arguments as parameter pair-values. Available names
%   are:
%   * 'spacing' the spacing bewteen pixels
%   * 'origin'  the position of the first pixel
%   * 'labels'  restrict the computation to the set of specified labels,
%           given as a N-by-1 array
%
%   Example
%   % Compute and display the oriented box of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     boxes = imOrientedBox(lbl);
%     imshow(img); hold on;
%     drawOrientedBox(boxes, 'linewidth', 2, 'color', 'g');
%
%   See also
%   imFeretDiameter, imInertiaEllipse, imMaxFeretDiameter

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-02-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%   HISTORY
%   2011-03-30 use degrees for angles
%   2014-06-17 add psb to specify labels


% %% Extract number of orientations
% 
% theta = 180;
% if ~isempty(varargin) && ~ischar(varargin{1})
%     var1 = varargin{1};
%     if isscalar(var1)
%         % Number of directions given as scalar
%         theta = var1;
%         varargin(1) = [];
%         
%     elseif ndims(var1) == 2 && sum(size(var1) ~= [1 2]) ~= 0 %#ok<ISMAT>
%         % direction set given as vector
%         theta = var1;
%         varargin(1) = [];
%     end
% end


%% Extract spatial calibration

% default values
spacing = [1 1];
origin  = [1 1];
calib   = false;

% extract spacing (for backward compatibility)
if ~isempty(varargin) && ~ischar(varargin{1})
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = [0 0];
end

% extract origin (for backward compatibility)
if ~isempty(varargin) && ~ischar(varargin{1})
    origin = varargin{1};
end

labels  = [];
while length(varargin) > 1 && ischar(varargin{1})
    paramName = varargin{1};
    switch lower(paramName)
%         case 'angles'
%             theta = varargin{2};
        case 'spacing'
            spacing = varargin{2};
        case 'origin'
            origin = varargin{2};
        case 'labels'
            labels = varargin{2};
        otherwise
            error(['Can not handle param name: ' paramName]);
    end
    
    varargin(1:2) = [];
end


%% Initialisations

% % if theta is scalar, create an array of directions (in degrees)
% if isscalar(theta)
%     theta = linspace(0, 180, theta+1);
%     theta = theta(1:end-1);
% end
% nTheta = length(theta);

% extract the set of labels is necessary, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);

% allocate memory for result
rect = zeros(nLabels, 5);


%% Iterate over labels

for i = 1:nLabels
    % extract points of the current particle
    [y, x] = find(img==labels(i));
    if isempty(x)
        continue;
    end
    
    % transform to physical space if needed
    if calib
        x = (x-1) * spacing(1) + origin(1);
        y = (y-1) * spacing(2) + origin(2);
    end
    
    % special case of particles composed of only one pixel
    if length(x) == 1
        rect(i,:) = [x y 1 1 0];
        continue;
    end
    
%     % keep only points of the convex hull
%     try
%         inds = convhull(x, y);
%         x = x(inds);
%         y = y(inds);
%     catch ME %#ok<NASGU>
%         % an exception can occur if points are colinear.
%         % in this case we transform all points
%         disp(sprintf('can not compute convex hull of label: %d', labels(i))); %#ok<DSPS>
%     end

    % compute bounding box of particle pixel centers
    try
        obox = orientedBox([x y]);
    catch ME %#ok<NASGU>
        % if points are aligned, convex hull computation fails.
        % Perform manual computation of box.
        xc = mean(x);
        yc = mean(y);
        x = x - xc;
        y = y - yc;
        
        theta = mean(mod(atan2(y, x), pi));
        [x2, y2] = transformPoint(x, y, createRotation(-theta)); %#ok<ASGLU>
        dmin = min(x2);
        dmax = max(x2);
        center = [(dmin + dmax)/2 0];
        center = transformPoint(center, createRotation(theta)) + [xc yc];
        obox  = [center (dmax-dmin) 0 rad2deg(theta)];
    end
    
    % pre-compute trigonometric functions
    thetaMax = obox(5);
    cot = cosd(thetaMax);
    sit = sind(thetaMax);

    % add a thickness of one pixel in both directions
    dsx = spacing(1) * abs(cot) + spacing(2) * abs(sit);
    dsy = spacing(1) * abs(sit) + spacing(2) * abs(cot);
    obox(3:4) = obox(3:4) + [dsx dsy];

    % concatenate rectangle data
    rect(i,:) = obox;
end


function [boxes, labels] = imBoundingBox(img, varargin)
%IMBOUNDINGBOX Bounding box of a binary or label image
%
%   BOX = imBoundingBox(IMG)
%   Compute the bounding boxes of the particles in labeled image IMG. If
%   the image is binary, one box, corresponding to the foreground (i.e.
%   the pixels with value 1) will be computed.
%
%   The result is a N-by-4 array BOX = [XMIN XMAX YMIN YMAX], containing
%   coordinates of the box extent.
%
%   The same result could be obtained with the regionprops function. The
%   advantage of using imBoundingBox is that equivalent boxes can be
%   obtained in one call. 
%
%   BOX = imBoundingBox(IMG3D)
%   If input image is a 3D array, the result is a N-by-6 array, containing
%   the maximal coordinates in the X, Y and Z directions:
%   BOX = [XMIN XMAX YMIN YMAX ZMIN ZMAX].
%
%
%   Example
%   % Draw a complex particle together with its bounding box
%     img = imread('circles.png');
%     imshow(img); hold on;
%     boxes = imBoundingBox(img);
%     drawBox(boxes)
%
%   % Compute and display the bounding box of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     boxes = imBoundingBox(lbl);
%     imshow(img); hold on;
%     drawBox(boxes, 'linewidth', 2, 'color', 'g');
%
%   See also
%   regionprops, drawBox, imOrientedBox, imInertiaEllipse

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% History
% 2013-03-29 add support for 3D images


%% Initialisations

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
nd = ndims(img);
boxes = zeros(nLabels, 2 * nd);


if nd == 2
    %% Process planar case 
    for i = 1:nLabels
        % extract points of the current particle
        [y, x] = find(img==labels(i));

        % compute extreme coordinates, and add the half-width of the pixel
        xmin = min(x) - .5;
        xmax = max(x) + .5;
        ymin = min(y) - .5;
        ymax = max(y) + .5;

        % create the resulting bounding box
        boxes(i,:) = [xmin xmax ymin ymax];
    end
    
elseif nd == 3
    %% Process 3D case
    dim = size(img);
    for i = 1:nLabels
        % extract points of the current particle
        inds = find(img==labels(i));
        [y, x, z] = ind2sub(dim, inds);

        % compute extreme coordinates, and add the half-width of the pixel
        xmin = min(x) - .5;
        xmax = max(x) + .5;
        ymin = min(y) - .5;
        ymax = max(y) + .5;
        zmin = min(z) - .5;
        zmax = max(z) + .5;

        % create the resulting bounding box
        boxes(i,:) = [xmin xmax ymin ymax zmin zmax];
    end
    
else
    error('Image dimension must be 2 or 3');
end

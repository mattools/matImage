function [boxes, labels] = imBoundingBox(img, varargin)
% Bounding box of regions within a 2D or 3D binary or label image.
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
%   [BOX, LABELS] = imBoundingBox(...)
%   Also returns the labels of the regions for which a bounding box was
%   computed. LABELS is a N-by-1 array with as many rows as BOX.
%
%   [...] = imBoundingBox(IMG, LABELS)
%   Specifies the labels of the regions whose bounding box need to be
%   computed.
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
%     regionprops, drawBox, imOrientedBox, imEquivalentEllipse

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% History
% 2013-03-29 add support for 3D images


%% Process input arguments

% default spatial calibration
nd = ndims(img);
spacing = ones(1, nd);
origin  = ones(1, nd);
calib   = false;

% extract spacing
if ~isempty(varargin) && all(size(varargin{1}) == [1 nd])
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = zeros(1, nd);
    
    % extract origin
    if ~isempty(varargin) && all(size(varargin{1}) == [1 nd])
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

if nd == 2
    %% Process planar case 
    props = regionprops(img, 'BoundingBox');
    bb = reshape([props.BoundingBox], [4 length(props)])';
    bb = bb(labels, :);
    
    % convert to MatImage convention
    boxes = [bb(:, 1) bb(:, 1)+bb(:, 3) bb(:, 2) bb(:, 2)+bb(:, 4)];
    
    % spatial calibration
    if calib
        boxes = bsxfun(@plus, bsxfun(@times, (boxes - 1), spacing([1 1 2 2])), origin([1 1 2 2]));
    end
    
elseif nd == 3
    %% Process 3D case
    stats = regionprops3(img, 'BoundingBox');
    bb = reshape([stats.BoundingBox], [6 size(stats, 1)])';
    bb = bb(labels, :);

    % convert to MatImage convention
    boxes = [bb(:, 1) bb(:, 1)+bb(:, 4) bb(:, 2) bb(:, 2)+bb(:, 5) bb(:, 3) bb(:, 3)+bb(:, 6)];
   
    % spatial calibration
    if calib
        boxes = bsxfun(@plus, bsxfun(@times, (boxes - 1), spacing([1 1 2 2 3 3])), origin([1 1 2 2 3 3]));
    end
else
    error('Image dimension must be 2 or 3');
end

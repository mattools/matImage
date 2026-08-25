function [cvx_perim, labels] = imConvexPerimeter(img, varargin)
%IMCONVEXPERIMETER Perimeter of the convex image of region(s) within image.
%
%   CVPERIM = imConvexPerimeter(IMG)
%   Computes the perimeter of the convex hull image of a binary region. If
%   IMG is a label map image, computes the convex perimeter for each region
%   within the label map, and returns a column vector with as many elements
%   as the number of regions within the image.
%
%   The convex perimeter is determined by firs computing the convex image,
%   then by computing the perimeter using Crofton method (same method used
%   in the "imPerimeter" function).
%
%   CVPERIM = imConvexPerimeter(IMG, NDIRS)
%   Specifies number of directions to use. Use either 2 or 4 (the default).
%
%   CVPERIM = imConvexPerimeter(..., SPACING)
%   Also specifies the spatial calibration of the image, as a 1-by-2 row
%   vector containing the pixel size in each physical direction. 
%
%   [CVPERIM, LABELS] = imConvexPerimeter(IMG, ...)
%   Also returns the labels for which a value was computed.
%
%   Example
%     % compute perimeter and convex perimeter
%     img = imFillHoles(imread('circles.png'));
%     [imPerimeter(img) imConvexPerimeter(img)]
%     ans = 
%          950.0385  640.5601
%
%     % also display boundary polygons
%     figure; imshow(img); hold on;
%     drawPolygon(imBoundaryContours(img), 'linewidth', 2, 'color', 'g');
%     cvimg = imConvexImage(img);
%     drawPolygon(imBoundaryContours(cvimg), 'linewidth', 2, 'color', 'm');
%
%   See also
%     imPerimeter, imConvexImage, imConvexArea
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-25,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.

%% Parse input arguments

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('First argument should be a 2D image');
end

% default options
labels = [];
spacings = [1 1];

% parse input arguments
while ~isempty(varargin)
    var1 = varargin{1};
    varargin(1) = [];

    if size(var1, 2) == 1
        % the labels to compute
        labels = var1;
    elseif all(size(var1) == [1 2])
        % spatial calibration
        spacings = var1;
    else
        error('Unable to interpret input argument');
    end
end

%% Process binary image

if islogical(img)
    % compute area, multiplied by image resolution
    bin2 = imConvexImage(img);
    cvx_perim = imPerimeter(bin2, 4, spacings);
    labels = 1;

    return;
end


%% Process label image
% in case of a label image, return a vector with a set of results

% extract labels if necessary (considers 0 as background)
if isempty(labels)
    labels = imFindLabels(img);
end

% allocate result array
nLabels = length(labels);
cvx_perim = zeros(nLabels, 1);

% compute bounding box of each region
boxes = imBoundingBox(img, labels);

% iterate over regions to compute perimeter of convex hull
for i = 1:nLabels
    label = labels(i);

    % convert bounding box to image extent, in x, and y
    i0 = ceil(boxes(i, [3 1]));
    i1 = floor(boxes(i, [4 2]));

    bin = img(i0(1):i1(1), i0(2):i1(2)) == label;
    bin2 = imConvexImage(bin);
    cvx_perim(i) = imPerimeter(bin2, 4, spacings);
end

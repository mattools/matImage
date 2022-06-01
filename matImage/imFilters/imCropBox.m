function res = imCropBox(img, box, varargin)
% Crop the content of an image within a box.
%
%   RES = imCropBox(IMG, BOX)
%   Crops the content of the image IMG that is contained within the box
%   defined by BOX. The format of BOX is [XMIN XMAX YMIN YMAX] for 2D
%   images, or [XMIN XMAX YMIN YMAX ZMIN ZMAX] for 3D images.
%
%
%   Example
%     % read and display input image
%     img = imread('circles.png');
%     figure; imshow(img); hold on;
%     % compute and overlay bounding box
%     box = imBoundingBox(img);
%     drawBox(box, 'g');
%     % crop according to box
%     res = imCropBox(img, box);
%     figure; imshow(res)
%
%   See also
%     imCropOrientedBox, drawBox
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2017-06-28,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

% retrieve box bounds, and convert to integers
xmin = ceil(box(1));
xmax = floor(box(2));
ymin = ceil(box(3));
ymax = floor(box(4));

% dispatch processing according to dimensionality
is3D = length(size(img)) > 2 && size(img, 3) ~= 3;
if ~is3D
    if ~isColorImage(img)
        res = img(ymin:ymax, xmin:xmax);
    else
        res = img(ymin:ymax, xmin:xmax, :);
    end
    
else
    if size(box, 2) < 6
        error('Cropping 3D image equires a box with at least 6 parameters');
    end
    
    zmin = ceil(box(5));
    zmax = floor(box(6));
    
    if ~isColorImage(img)
        res = img(ymin:ymax, xmin:xmax, zmin:zmax);
    else
        res = img(ymin:ymax, xmin:xmax, :, zmin:zmax);
    end
end


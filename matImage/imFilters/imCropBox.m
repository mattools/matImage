function res = imCropBox(img, box, varargin)
%IMCROPBOX Crop an image with a box
%
%   output = imCropBox(input)
%
%   Example
%   imCropBox
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2017-06-28,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

xmin = ceil(box(1));
xmax = floor(box(2));
ymin = ceil(box(3));
ymax = floor(box(4));

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



function hue = imGetHue(img)
%IMGETHUE  Extract hue of a color image, using rgb2hsv.
%
%   HUE = imGetHue(RGB)
%   When RGB is a color image, returns the hue value of each pixel. The
%   result image HUE has the same physical size as input image IMG, without
%   the color dimension.
%
%   Example
%   % show hue value of a color image
%     img = imread('peppers.png');
%     hue = imGetHue(img);
%     % convert hue value, coded between 0 and 1, into RGB
%     rgbHue = angle2rgb(hue, 1);
%     subplot(121);imshow(img); subplot(122); imshow(rgbHue);
%
%   See also
%   rgb2hsv, angle2rgb
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-05-15,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

% History
% 2010-11-09 update doc, add code for 3D


if ndims(img) == 3
    % process 2D image
    hsv = rgb2hsv(img);
    hue = hsv(:,:,1);
    
elseif ndims(img) == 4
    % process 3D color image
    
    % compute size of result
    dim = size(img);
    dim2 = dim([1 2 4]);
    
    % allocate memory
    hue = zeros(dim2);
    
    % iterate on image slices
    for i=1:dim(4)
        hsv = rgb2hsv(img(:,:,:,i));
        hue(:,:,i) = hsv(:,:,1);
    end
    
else
    error('Dimension not managed');
end

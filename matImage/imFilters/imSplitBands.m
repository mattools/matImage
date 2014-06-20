function [r g b] = imSplitBands(rgb)
%IMSPLITBANDS  Split the 3 bands of a 2D or 3D image
%
%   Note: deprecated, use imSplitChannels instead
%
%   [R, G, B] = imSplitBands(RGB);
%   
%   Example
%   img = imread('peppers.png');
%   [r, g, b] = imSplitBands(img);
%   figure; imshow(r); title('red');
%   figure; imshow(g); title('green');
%
%   See also
%   imMergeBands
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-02-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

warning('imFilters:deprecated', ...
    'imSplitBands is deprecated, use imSplitChannels instead');

if ndims(rgb) == 3
    r = rgb(:,:,1);
    g = rgb(:,:,2);
    b = rgb(:,:,3);
elseif ndims(rgb) == 4
    r = squeeze(rgb(:,:,1,:));
    g = squeeze(rgb(:,:,2,:));
    b = squeeze(rgb(:,:,3,:));
else 
    error('unprocessed image dimension');
end

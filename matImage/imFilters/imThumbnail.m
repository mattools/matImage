function res = imThumbnail(img, siz, varargin)
%IMTHUMBNAIL Resize an image to bound the size in each direction
%
%   RES = imThumbnail(IMG, SIZ)
%   Resizes the image given in IMG such that the dimension is lower or
%   equal to the dimension given by SIZ.
%
%   Example
%     img = imread('cameraman.tif');
%     img2 = imThumbnail(img, [64 64]);
%     imshow(img2)
%
%     img = imread('peppers.png');
%     img2 = imThumbnail(img, [64 64]);
%     imshow(img2)
%
%   See also
%   imresize
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-02-14,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

k1 = siz(1) / size(img, 1);
k2 = siz(2) / size(img, 2);
k = min(k1, k2);

res = imresize(img, k, varargin{:});

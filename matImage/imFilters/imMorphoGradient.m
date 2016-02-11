function res = imMorphoGradient(img, se)
%IMMORPHOGRADIENT Morphological gradient of an image
%
%   RES = imMorphoGradient(IMG, SE)
%   Computes the morphological gradient of the image IMG, using the
%   structuring element SE.
%
%   Morphological gradient is defined as the difference of a morphological
%   dilation and a morphological erosion with the same structuring element.
%   This function is mainly a shortcut to apply all operations in one call.
%
%   Example
%   img = imread('cameraman.tif');
%   se = ones(3, 3);
%   grad = imMorphoGradient(img, se);
%   imshow(grad);
%
%   See also
%   imdilate, imerode, imGradientFilter, imsubtract, rangefilt
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-04-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

res = imsubtract(imdilate(img, se), imerode(img, se));
function res = imMorphoLaplacian(img, se)
%IMMORPHOLAPLACIAN Morphological laplacian of an image
%
%   RES = imMorphoLaplacian(IMG, SE)
%   Computes the morphological laplacian of the image IMG, using the
%   structuring element SE.
%
%   Morphological laplacian is defined as the sum of a morphological
%   dilation and a morphological erosion with the same structuring element,
%   minus twice the original image. 
%   This function is mainly a shortcut to apply all operations in one call.
%
%   Note: the output type is the same as the input image type, but
%   morphological laplacian produces signed results. It is therefore
%   necessary to cast the input image to signed data type before computing
%   filter.
%
%   Example
%     % Morphological Laplacian computed on rice image
%     img = imread('rice.png');
%     se = ones(3, 3);
%     grad = imMorphoLaplacian(double(img), se);
%     imshow(grad, []);
%
%     % Morphological Laplacian computed on cameraman image
%     img = imread('cameraman.tif');
%     se = ones(3, 3);
%     grad = imMorphoLaplacian(double(img), se);
%     imshow(grad, []);
%
%   See also
%   imdilate, imerode, imsubtract, rangefilt, imLaplacian
%   imMorphoGradient
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-04-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

res = imsubtract(imadd(imsubtract(imdilate(img, se), img), imerode(img, se)), img);

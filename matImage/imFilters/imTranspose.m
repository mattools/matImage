function res = imTranspose(img)
% Transpose an image (grayscale or RGB).
%
%   RES = imTranspose(IMG)
%   Simply permutes image dimensions 1 and 2. Works for gray-scale images
%   as well as for color images.
%
%   Example
%   img = imread('peppers.png');
%   img2 = imTranspose(img);
%   imshow(img2);
%
%   See also
%     imFlip, imRotate90

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2007-08-16,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.


if ndims(img) == 2 %#ok<ISMAT>
    res = img';
else
    res = permute(img, [2 1 3]);
end

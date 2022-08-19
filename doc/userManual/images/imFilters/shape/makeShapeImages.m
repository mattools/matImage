%MAKESHAPEIMAGES  One-line description here, please.
%
%   output = makeShapeImages(input)
%
%   Example
%   makeShapeImages
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-07-09,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

% read data
img = imread('cameraman.tif');

% flipH
imgFlip = imFlip(img, 1);
imwrite(imgFlip, 'cameraman_flipH.png', 'png');

% rotate 90
imgRot90 = imRotate90(img);
imwrite(imgRot90, 'cameraman_rot90.png', 'png');

% crop border
imgCropBorder = imCropBorder(img, [20 40 30 50]);
imwrite(imgCropBorder, 'cameraman_cropBorder.png', 'png');

% add border
imgAddBorder = imAddBorder(img, [20 40 30 50]);
imwrite(imgAddBorder, 'cameraman_addBorder.png', 'png');


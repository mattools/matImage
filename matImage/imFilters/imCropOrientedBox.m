function res = imCropOrientedBox(img, obox)
% Crop the content of an image within an oriented box.
%
%   RES = imCropOrientedBox(IMG, OBOX)
%   Crops the content of the image IMG that is contained within the
%   oriented box OBOX. The size of the resulting image is approximately
%   (due to rounding) the size of the oriented box.
%
%   Example
%     % open and display input image
%     img = imread('circles.png');
%     img = uint8(img) * 255;
%     figure; imshow(img); hold on;
%     % identifies oriented box around the main region
%     obox = imOrientedBox(img);
%     drawOrientedBox(obox, 'g');
%     % crop the content of the oriented box
%     res = imCropOrientedBox(img, obox);
%     figure; imshow(res)
%
%   See also
%     imOrientedBox, imCropBox
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.

% retrieve oriented box parameters
boxCenter = obox(1:2);
boxSize = obox(3:4);
boxAngle = obox(5);

% create the transform matrix that maps from box coords to global coords
transfo = createTranslation(boxCenter) * createRotation(deg2rad(boxAngle));

% sample points within the box (use single pixel spacing)
lx = -floor(boxSize(1)/2):ceil(boxSize(1)/2);
ly = -floor(boxSize(2)/2):ceil(boxSize(2)/2);

% map into global coordinate space
[x, y] = meshgrid(lx, ly);
[x, y] = transformPoint(x, y, transfo);

% evaluate within image
res = imEvaluate(img, x, y);

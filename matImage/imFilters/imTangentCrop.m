function res = imTangentCrop(img, pos, boxSize)
% Crop an image around a point based on local orientation.
%
%   RES = imTangentCrop(IMG, BOXCENTER, BOXSIZE)
%   Computes and orientated crop of the input image IMG, by considering all
%   pixels within a oriented box with centered given by BOXCENTER, size 
%   given by BOXSIZE, and orientation evaluated from local gradient of the
%   image at the point POS. 
%   
%
%   Example
%
%   See also
%     imCropOrientedBox, imCropBox, imTangentCrop3d
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.


%% Compute transform

% evaluate gradient
grad = imLocalGradient(img, pos, 3);

% convert gradient to rotation angle
angle = atan2(grad(2), grad(1)) - pi/2;

% create the transform matrix that maps from box coords to global coords
transfo = createTranslation(pos) * createRotation(angle);


%% Sample points within box

% generate point coords along each box axis:
% * number of values equals to round(boxSize)
% * use single pixel spacing
radius = round(boxSize) / 2;
lx = -radius(1)+0.5:radius(1)-0.5;
ly = -radius(2)+0.5:radius(2)-0.5;

% map into global coordinate space
[x, y] = meshgrid(lx, ly);
[x, y] = transformPoint(x, y, transfo);

% evaluate within image
res = imEvaluate(img, x, y);

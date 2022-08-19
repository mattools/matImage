%FILTERS_BINARY_DISCS  One-line description here, please.
%
%   output = filters_binary_discs(input)
%
%   Example
%   filters_binary_discs
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-03-23,    using Matlab 9.7.0.1247435 (R2019b) Update 2
% Copyright 2020 INRAE.

img = imread('circles.png');

bnd = imBoundary(img);
imwrite(uint8(~bnd) * 255, 'circles-boundary-inv.png');

imgFH = imFillHoles(img);
imwrite(uint8(~imgFH) * 255, 'circles-fillHoles-inv.png');

skel = imSkeleton(img);
imwrite(uint8(~skel) * 255, 'circles-skeleton-inv.png');

cvx = imConvexImage(img);
imwrite(uint8(~cvx) * 255, 'circles-convex-inv.png');

distMap = imDistanceMap(imgFH);
rgb = double2rgb(distMap, [1 1 1; parula]);
imwrite(rgb, 'circles-fillHoles-distMap-RGB.png');

thMap = imThicknessMap(imgFH);
rgb = double2rgb(thMap, [1 1 1; parula]);
imwrite(rgb, 'circles-fillHoles-thicknessMap-RGB.png');

%DISTANCEMAPS_LEAF  One-line description here, please.
%
%   output = distanceMaps_leaf(input)
%
%   Example
%   distanceMaps_leaf
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

% read data
img = imread('IJ-leaf-bin.tif');
imwrite(255 - img, 'ijLeaf-binInv.png', 'png');

% compute distance map
distMap = imDistanceMap(img);

% save RGB display
rgb = double2rgb(distMap, [1 1 1; parula]);
imwrite(rgb, 'ijLeaf-bin-distMap-rgb.png', 'png');

% compute thickness map
thMap = imThicknessMap(img);

% save RGB display
rgb = double2rgb(thMap, [1 1 1; parula]);
imwrite(rgb, 'ijLeaf-bin-thickMap-rgb.png', 'png');

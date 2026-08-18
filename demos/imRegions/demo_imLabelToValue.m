%DEMO_IMLABEL2VALUE Demo script for the imLabel2Value function.
%
%   output = demo_imLabel2Value(input)
%
%   Example
%   demo_imLabel2Value
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-18,    using Matlab 25.1.0.2943329 (R2025a)
% Copyright 2026 INRAE.

% read input image
img = imread('rice.png');

% reduce noise and background
img2 = imMedianFilter(imtophat(img, ones(30, 30)), ones(3,3));

% binarize
[~,bin]= imOtsuThreshold(img2);

% tranform into a label map
lbl = bwlabel(bin);

% compute a feature for each region
meas = imMaxFeretDiameter(lbl);

% create feature map
map = imLabelToValue(lbl, meas, NaN);
figure; imshow(map, []); title('parametric map')

% create RGB image for representing the feature map
rgb = double2rgb(map, 'jet', [10 35], 'w');
figure; imshow(rgb); title('colorized parametric map')

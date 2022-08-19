%MAKEFILTERIMAGES  One-line description here, please.
%
%   output = makeFilterImages(input)
%
%   Example
%   makeFilterImages
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-07-09,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

img = imread('rice.png');

img2 = img(81:180, 81:180);
imwrite(img2, 'riceCrop.png');

img2f1 = imBoxFilter(img2, [5 5]);
imwrite(img2f1, 'riceCrop_boxFilter5x5.png');

img2f2 = imGaussianFilter(img2, [2 2]);
imwrite(img2f2, 'riceCrop_gaussianFilter2x2.png');

img2f3 = imMedianFilter(img2, [5 5]);
imwrite(img2f3, 'riceCrop_medianFilter5x5.png');

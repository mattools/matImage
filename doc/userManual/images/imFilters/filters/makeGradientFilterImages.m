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

[img2gx, img2gy] = imGradientFilter(img2);
imwrite(uint8(img2gx * 2 + 127), 'riceCrop_gradientFilterX.png');
imwrite(uint8(img2gy * 2 + 127), 'riceCrop_gradientFilterY.png');

img2gn = imGradientFilter(img2);
imwrite(uint8(img2gn * 5), 'riceCrop_gradientFilterN.png');

img2Lap = imLaplacian(img2);
imwrite(uint8(img2Lap * 2 + 127), 'riceCrop_Laplacian.png');

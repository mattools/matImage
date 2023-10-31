%DEMO_IMNORMALIZEBACKGROUND_RICE  One-line description here, please.
%
%   output = demo_imNormalizeBackground_rice(input)
%
%   Example
%   demo_imNormalizeBackground_rice
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-31,    using Matlab 23.2.0.2409890 (R2023b) Update 3
% Copyright 2023 INRAE.

img = imread('rice.png');
[img2, bg] = imNormalizeBackground(img, img>150);
figure;
subplot(2,1,1); imHistogram(img); title('Original');
subplot(2,1,2); imHistogram(img2); title('Corrected');
print(gcf, 'rice_backgroundCorrection_histograms.png', '-dpng');
imwrite(img2, 'rice_backgroundCorrection.png');
imwrite(bg, 'rice_backgroundCorrection_background.png');

% binarise corrected image
bin = img2 > imOtsuThreshold(img2);
ovr = imOverlay(img, imBoundary(bin));
figure; imshow(ovr);
imwrite(ovr, 'rice_backgroundCorrection_segOverlay.png');

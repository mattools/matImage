% Demo script for granulometry applied on grayscale image of coins.
%
%   output = granulo_coins(input)
%
%   Example
%   granulo_coins
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-01-17,    using Matlab 9.13.0.2049777 (R2022b)
% Copyright 2023 INRAE.

%% Sample image

% read image
img = imread('coins.png');
imwrite(img, 'coins.png');

% compute several steps (before, between and after the two peaks)
radiusList = [15 27 35];
for iPlot = 1:3
    se = strel('disk', radiusList(iPlot), 0);
    imgOp = imopen(img, se);
    
    imwrite(imgOp, sprintf('coins_OpDisk%02d.tif', radiusList(iPlot)));
end


%% compute granulo.

% granulometry analysis setup
xi = 1:60;
vol0 = sum(img(:));
[gr, diams, vol] = imGranulo(img, 'opening', 'disk', xi);

% display granulo
figure; plot(diams, gr, 'color', 'b', 'linewidth', 2);
xlim([0 100]);
xlabel('Diameter of structuring element (pixels)');
ylabel('Variation of gray levels (%)');
title('Gray level granulometry by opening', 'Interpreter', 'none');
print(gcf, 'coins_grOpDk30.png', '-dpng');

% display volume curve
figure; plot([0 diams], vol, 'color', 'b', 'linewidth', 2);
xlim([0 100]);
xlabel('Diameter of structuring element (pixels)');
ylabel('Sum of gray levels');
title('Gray level granulometry by opening', 'Interpreter', 'none');
print(gcf, 'coins_grOpDk40_sumOfGrays.png', '-dpng');


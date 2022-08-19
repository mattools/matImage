%GRANULORICE  One-line description here, please.
%
%   output = granuloRice(input)
%
%   Example
%   granuloRice
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-03-23,    using Matlab 9.7.0.1247435 (R2019b) Update 2
% Copyright 2020 INRAE.

% read image
img = imread('rice.png');
imwrite(img, 'rice.png');

% compute granulo.
xi = 1:20;
[gr, vol] = imGranulo(img, 'opening', 'square', xi);

% display granulo
diams = 2*xi + 1;
figure; plot(diams, gr, 'color', 'b', 'linewidth', 2);
xlim([0 40]);
xlabel('Diameter of structuring element (pixels)');
ylabel('Variation of gray levels (%)');
title('Gray level granulometry by opening', 'Interpreter', 'none');
print(gcf, 'rice_grOpSq20.png', '-dpng');

% display volume curve
figure; plot([0 diams], vol, 'color', 'b', 'linewidth', 2);
xlim([0 40]);
xlabel('Diameter of structuring element (pixels)');
ylabel('Sum of gray levels');
title('Gray level granulometry by opening', 'Interpreter', 'none');
print(gcf, 'rice_grOpSq20_sumOfGrays.png', '-dpng');


%DEMOHISTOGRAMRGB  One-line description here, please.
%
%   output = demoHistogramRGB(input)
%
%   Example
%   demoHistogramRGB
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-10-08,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.

%% Read Color image

img = Image.read('peppers.png');
figure; show(img);
print(gcf, 'peppers-show.png', '-dpng');


%% Compute histogram

figure; histogram(img);
print(gcf, 'peppers-histogram.png', '-dpng');

%% Compute line profile

lineProfile(img, [150 50], [150 300]);
print(gcf, 'peppers-lineProfile.png', '-dpng');

% overlay line profile on original image
img(149:151, 50:300, :) = 255;
write(img, 'peppers-lineOverlay.png');
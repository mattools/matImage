%Computes geodesic distance map inside a complex particle
%
%   output = demoGeodesicDistanceMap(input)
%
%   Example
%   demoGeodesicDistanceMap
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-08-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Read image a create marker

% read image
img = imread('circles.png');

% create marker
marker = false(size(img));
marker(80, 80) = 1;

% show image
imshow(imOverlay(img, imdilate(marker, ones(3, 3))));


%% compute using quasi-enclidean weights

% compute distance map
dist = imGeodesicDistanceMap(img, marker, [1 sqrt(2)]);

% convert to rgb (use function in 'imFilters')
rgb = double2rgb(dist, prism, [], [1 1 1]);

% display result
figure; 
imshow(rgb);

% decorate
title('Quasi-euclidean distance');


%% compute using integer weights, giving integer results

% compute distance using integer weights
dist34 = imGeodesicDistanceMap(img, marker, int16([3 4]));

% convert to double and normalize
dist34d = double(dist34);
dist34d(~img) = inf;

% convert to RGB
bounds = [0 210];
rgb34 = double2rgb(dist34d, prism, bounds, [1 1 1]);

% display rgb
figure;
imshow(rgb34);

% decorate
title('Borgefors 3-4 weights');


%% The same, using Chess-knight weights

% compute distance using integer weights
distCK = imGeodesicDistanceMap(img, marker, int16([5 7 11]));

% convert to double and normalize
distCK = double(distCK);
distCK(~img) = inf;

% convert to RGB
bounds = [0 210];
rgbCK = double2rgb(distCK, prism, bounds, [1 1 1]);

% display rgb
figure;
imshow(rgbCK);

% decorate
title('ChessKnight 5-7-11 weights');

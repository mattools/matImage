function tests = test_imGeodesicDistanceMap(varargin)
%TEST_IMGEODESICDISTANCEMAP  One-line description here, please.
%
%   output = test_imGeodesicDistanceMap(input)
%
%   Example
%   test_imGeodesicDistanceMap
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-07-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


%% Tests for Grayscale image 2D

function test_MarkerAtUpperLeftCorner_10x12(testCase) %#ok<*DEFNU>
% use blank image, marker at the upper left corner.

img = true(10, 12);
marker = false(size(img));
marker(1, 1) = 1;

dist = imGeodesicDistanceMap(img, marker, [1 0]);
maxDist = max(dist(img(:)));

assertTrue(isfinite(maxDist));

expDist = 10+12-2;
assertEqual(testCase, expDist, maxDist);


function test_MarkerAtBottomRightCorner_10x12(testCase)
% use blank image, marker at the bottom left corner.

img = true(10, 12);
marker = false(size(img));
marker(end, end) = 1;

dist = imGeodesicDistanceMap(img, marker, [1 0]);
maxDist = max(dist(img(:)));

assertTrue(isfinite(maxDist));

expDist = 10+12-2;
assertEqual(testCase, expDist, maxDist);


function test_MarkerAtUpperLeftCorner_10x30(testCase)
% use blank image, marker at the upper left corner.

img = true(10, 30);
marker = false(size(img));
marker(1, 1) = 1;

dist = imGeodesicDistanceMap(img, marker, [1 1]);
maxDist = max(dist(img(:)));

assertTrue(isfinite(maxDist));

expDist = 29;
assertEqual(testCase, expDist, maxDist);


function test_MarkerAtBottomRightCorner_10x30(testCase)
% use blank image, marker at the upper left corner.

img = true(10, 30);
marker = false(size(img));
marker(end, end) = 1;

dist = imGeodesicDistanceMap(img, marker, [1 1]);
maxDist = max(dist(img(:)));

assertTrue(isfinite(maxDist));

expDist = 29;
assertEqual(testCase, expDist, maxDist);


function test_FiniteDistWithMarkerOutside(testCase)

img = [...
    0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 1 1 1 1 1 1 1 0; ...
    0 0 0 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 0 0 1 0; ...
    0 1 0 0 0 1 0 0 1 0; ...
    0 1 1 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 1 1 1 0; ...
    0 0 0 0 1 1 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0];
    
marker = false(size(img));
marker(2, 2) = 1;

dist = imGeodesicDistanceMap(img, marker);
maxDist = max(dist(isfinite(dist)));

assertTrue(isfinite(maxDist));

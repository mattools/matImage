function tests = test_imDownSample
% Test suite for the file imDownSample.
%
%   Test suite for the file imDownSample
%
%   Example
%   test_imDownSample
%
%   See also
%     imDownSample

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-11-26,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_gray2d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = imread('rice.png');

img2 = imDownSample(img, 4);

assertEqual(testCase, size(img2), size(img)/4);


function test_Color2d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = imread('peppers.png');

img2 = imDownSample(img, 4);

assertEqual(testCase, size(img2, [1 2]), size(img, [1 2])/4);



function tests = test_imProjectedArea
% Test suite for the file imProjectedArea.
%
%   Test suite for the file imProjectedArea
%
%   Example
%   test_imProjectedArea
%
%   See also
%     imProjectedArea

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2026-10-15,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% create a cuboid with size 5x4x3
img = false([7 6 5]);
img(2:6,2:5,2:4) = true;

resX = imProjectedArea(img, [0 1 0]);
resY = imProjectedArea(img, [1 0 0]);
resZ = imProjectedArea(img, [0 0 1]);

assertEqual(testCase, 12, resX);
assertEqual(testCase, 15, resY);
assertEqual(testCase, 20, resZ);

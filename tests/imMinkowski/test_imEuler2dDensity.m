function tests = test_imEuler2dDensity
% Test suite for the file imEuler2dDensity.
%
%   Test suite for the file imEuler2dDensity
%
%   Example
%   test_imEuler2dDensity
%
%   See also
%     imEuler2dDensity

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2026-10-15,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_logical_square3x3(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = false([5 5]);
img(2:4, 2:4) = true;

res = imEuler2dDensity(img);

assertTrue(testCase, isscalar(res));
assertTrue(testCase, res < 1);


function test_int_twoPhases(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = zeros([5 5], 'uint8');
img(2:4, 2:4) = 3;
img(3:4, 4) = 5;

res = imEuler2dDensity(img);

assertEqual(testCase, [2 1], size(res));
assertTrue(testCase, res(1) < 1);
assertTrue(testCase, res(2) < 1);



function tests = test_imConvexArea
% Test suite for the file imConvexArea.
%
%   Test suite for the file imConvexArea
%
%   Example
%   test_imConvexArea
%
%   See also
%     imConvexArea

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2026-08-18,    using Matlab 25.1.0.2943329 (R2025a)
% Copyright 2026 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_ring_binary(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = false([8 8]);
img(2:6, 2:6) = true;
img(3:5, 3:5) = false;

res = imConvexArea(img);

assertEqual(testCase, res, 25);


function test_label_twoC(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = zeros([12 10], 'uint8');
img(2, 2:6) = 3;
img(2:8, 2) = 3;
img(8, 2:6) = 3;
img(5, 4:8) = 7;
img(5:11, 8) = 7;
img(11, 4:8) = 7;

res = imConvexArea(img);

assertEqual(testCase, size(res), [2 1]);
assertEqual(testCase, res, [35;35]);

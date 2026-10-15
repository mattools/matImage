function tests = test_imAreaDensity
% Test suite for the file imAreaDensity.
%
%   Test suite for the file imAreaDensity
%
%   Example
%   test_imAreaDensity
%
%   See also
%     imAreaDensity

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2026-10-15,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_Simple(testCase)
% Test call of function without argument

img = [ ...
    1 1 1 0 0 0 0 ; ...
    1 1 0 0 1 1 0 ; ...
    0 0 0 1 1 1 0 ; ...
    0 1 0 1 1 0 0 ; ...
    0 1 1 0 0 0 1 ; ...
    0 1 0 0 0 1 1 ; ...
    ] > 0;

res = imAreaDensity(img);
assertEqual(testCase, [1 1], size(res));
assertTrue(testCase, res < 1);


function test_labels(testCase)
% Test call of function without argument

img = [ ...
    2 2 2 5 5 ; ...
    2 2 0 0 5 ; ...
    0 6 6 6 7 ; ...
    0 0 0 7 7 ];

res = imAreaDensity(img);

assertEqual(testCase, [4 1], size(res));
assertTrue(testCase, res(1) < 1);
assertTrue(testCase, res(2) < 1);
assertTrue(testCase, res(3) < 1);
assertTrue(testCase, res(4) < 1);


function test_labels_anisotropic(testCase)
% Test call of function without argument

calib = [4 3];
img = [ ...
    2 2 2 5 5 ; ...
    2 2 0 0 5 ; ...
    0 6 6 6 7 ; ...
    0 0 0 7 7 ];

res = imAreaDensity(img, calib);

assertEqual(testCase, [4 1], size(res));
assertTrue(testCase, res(1) < 1);
assertTrue(testCase, res(2) < 1);
assertTrue(testCase, res(3) < 1);
assertTrue(testCase, res(4) < 1);


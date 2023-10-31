function tests = test_imAdjustDynamic
% Test suite for the file imAdjustDynamic.
%
%   Test suite for the file imAdjustDynamic
%
%   Example
%   test_imAdjustDynamic
%
%   See also
%     imAdjustDynamic

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2023-10-31,    using Matlab 23.2.0.2409890 (R2023b) Update 3
% Copyright 2023 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = imread('rice.png');
res = imAdjustDynamic(img);

assertTrue(testCase, isa(res, 'uint8'));
assertEqual(testCase, min(res(:)), uint8(0));
assertEqual(testCase, max(res(:)), uint8(255));


function test_GetCoeffs(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = imread('rice.png');
[res, coeffs] = imAdjustDynamic(img);

res2 = uint8(coeffs(1) + double(img) * coeffs(2));

assertTrue(testCase, all(res2(:) == res(:)));

function tests = test_imBoxFilter(varargin)
% Test suite for function imBoxFilter.
%
%   Test case for the file imBoxFilter
%
%   Example
%   test_imBoxFilter
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-11-22,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2018 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_SquareUInt8_5x5(testCase) %#ok<*DEFNU>
% Test call of function without argument

img = zeros([20, 20], 'uint8');
img(6:15, 6:15) = 255;
dims = [5 5];

res = imBoxFilter(img, dims);

assertEqual(testCase, size(res), size(img));
assertEqual(testCase, class(res), class(img));


function test_SquareFloat_5x5(testCase) %#ok<*DEFNU>
% Test call of function without argument

img = zeros([20, 20], 'uint8');
img(6:15, 6:15) = 255;
dims = [5 5];

resRef = imBoxFilter(img, dims);
res = uint8(imBoxFilter(double(img), dims));

assertEqual(testCase, res, resRef);


function test_CubeFloat_7x5x3(testCase) %#ok<*DEFNU>
% Test call of function without argument

img = zeros([40 40 40], 'uint8');
img(11:30, 11:30, 11:30) = 255;
dims = [7 5 3];

resRef = imBoxFilter(img, dims);
res = uint8(imBoxFilter(double(img), dims));

assertEqual(testCase, res, resRef);

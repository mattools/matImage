function tests = test_imSurfaceArea(varargin)
% Test case for the file imSurfaceArea.
%
%   output = test_imSurfaceArea(input)
%
%   Example
%   test_imSurfaceArea
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-10-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRAE - Cepia Software Platform.

tests = functiontests(localfunctions);


function testAddBorderD3(testCase)

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 3;
b = imSurfaceArea(img, nDir);
bb = imSurfaceArea(imgb, nDir);
assertEqual(testCase, b, bb);


function testAddBorderD13(testCase)

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 13;
b = imSurfaceArea(img, nDir);
bb = imSurfaceArea(imgb, nDir);
assertEqual(testCase, b, bb);


function test_Anisotropic(testCase)

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 3;
b = imSurfaceArea(img, nDir, [1 2 3]);
bb = imSurfaceArea(imgb, nDir, [1 2 3]);
assertEqual(testCase, b, bb);


function test_Labels(testCase)

img = zeros([5 5 5]);
img(1:3, 1:3, 1:3) = 1;
img(4:5, 1:3, 1:3) = 2;
img(1:3, 4:5, 1:3) = 3;
img(4:5, 4:5, 1:3) = 4;
img(1:3, 1:3, 4:5) = 5;
img(4:5, 1:3, 4:5) = 6;
img(1:3, 4:5, 4:5) = 7;
img(4:5, 4:5, 4:5) = 8;

b3 = imSurfaceArea(img, 3);
b13 = imSurfaceArea(img, 13);
assertEqual(testCase, 8, length(b3));
assertEqual(testCase, 8, length(b13));

imgb = padarray(img, [1 1 1]);
bb3 = imSurfaceArea(imgb, 3);
bb13 = imSurfaceArea(imgb, 13);

assertEqual(testCase, b3, bb3);
assertEqual(testCase, b13, bb13);


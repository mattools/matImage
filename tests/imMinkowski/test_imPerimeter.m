function tests = test_imPerimeter(varargin)
% Test function for function testImPerimeter
%   output = testImPerimeter(input)
%
%   Example
%   test_imPerimeter
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function testAddBorderD2(testCase)

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 2;
p   = imPerimeter(img, nd);
pb  = imPerimeter(imgb, nd);

assertEqual(testCase, p, pb);


function testAddBorderD4(testCase)

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 4;
p   = imPerimeter(img, nd);
pb  = imPerimeter(imgb, nd);

assertEqual(testCase, p, pb);


function testAddBorderD4Aniso(testCase)

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 4;
p   = imPerimeter(img, nd, [2 3]);
pb  = imPerimeter(imgb, nd, [2 3]);

assertEqual(testCase, p, pb);


function testLabelImage(testCase)

lbl = bwlabel(imread('coins.png') > 100);

p = imPerimeter(lbl);

assertEqual(testCase, 10, length(p));
assertTrue(testCase, min(p) > 150);
assertTrue(testCase, max(p) < 300);

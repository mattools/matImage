function test_suite = test_imPerimeter(varargin) %#ok<STOUT>
% Test function for function testImPerimeter
%   output = testImPerimeter(input)
%
%   Example
%   testImEuler2d
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

initTestSuite;

function testAddBorderD2 %#ok<*DEFNU>

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 2;
p   = imPerimeter(img, nd);
pb  = imPerimeter(imgb, nd);
assertEqual(p, pb);

function testAddBorderD4

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 4;
p   = imPerimeter(img, nd);
pb  = imPerimeter(imgb, nd);
assertEqual(p, pb);


function testAddBorderD4Aniso

img = ones([5, 5]);
imgb = padarray(img, [1 1]);

nd  = 4;
p   = imPerimeter(img, nd, [2 3]);
pb  = imPerimeter(imgb, nd, [2 3]);
assertEqual(p, pb);

function testLabelImage

lbl = bwlabel(imread('coins.png') > 100);
p = imPerimeter(lbl);

assertEqual(10, length(p));
assertTrue(min(p) > 150);
assertTrue(max(p) < 300);

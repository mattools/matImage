function tests = test_imArea(varargin)
% Test function for function testImArea
%   output = testImArea(input)
%
%   Example
%   testImEuler2d
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function testSquare(testCase)

img = false(10, 10);
img(3:3+4, 4:4+4) = true;

a = imArea(img);

assertEqual(testCase, 25, a);


function testDelta(testCase)
% Test with a non uniform resolution

img = false(10, 10);
img(3:3+2, 4:4+3) = true;
delta = [3 5];
expectedArea = 3*delta(1) * 4*delta(2); 

a = imArea(img, delta);

assertEqual(testCase, expectedArea, a);


function testLabel(testCase)

% create image with 5 different regions
img = floor(rand(10, 10)*5)+1;

a = imArea(img);

assertEqual(testCase, length(a), 5);
assertEqual(testCase, numel(img), sum(a));


function testLabelImage(testCase)

lbl = bwlabel(imread('coins.png') > 100);

a = imArea(lbl);

assertEqual(testCase, 10, length(a));
assertTrue(min(a) > 1500);
assertTrue(max(a) < 3000);

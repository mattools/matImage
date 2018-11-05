function testSuite = test_imArea(varargin)
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

testSuite = buildFunctionHandleTestSuite(localfunctions);

function testSquare %#ok<*DEFNU>

img = false(10, 10);
img(3:3+4, 4:4+4) = true;

a = imArea(img);
assertEqual(25, a);


function testDelta
% Test with a non uniform resolution

img = false(10, 10);
img(3:3+2, 4:4+3) = true;
delta = [3 5];
expectedArea = 3*delta(1) * 4*delta(2); 

a = imArea(img, delta);
assertEqual(expectedArea, a);

function testLabel

% create image with 5 different regions
img = floor(rand(10, 10)*5)+1;
a = imArea(img);
assertEqual(length(a), 5);
assertEqual(numel(img), sum(a));

function testLabelImage

lbl = bwlabel(imread('coins.png') > 100);
a = imArea(lbl);

assertEqual(10, length(a));
assertTrue(min(a) > 1500);
assertTrue(max(a) < 3000);

function tests = test_imEuler2d(varargin)
% Test function for function imEuler2d
%   output = testImEuler2d(input)
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


function testSimplePoints(testCase)
% Some points in a black image

img = false(10, 10);
img(3, 4) = true;
img(7, 8) = true;
img(1, 2) = true;
img(10, 2) = true;

epc = imEuler2d(img);

assertEqual(testCase, 4, epc);


function testBorderPoints(testCase)
% Some points on the border

img = false(10, 10);
img(1, 2) = true;
img(10, 2) = true;
img(6, 10) = true;
img(4, 10) = true;
img(10, 10) = true;

epc = imEuler2d(img);

assertEqual(testCase, 5, epc);


function testConn8(testCase)
% test with 3 points touching by corner

img = false(10, 10);
img(3, 4) = true;
img(4, 5) = true;
img(5, 4) = true;

epc = imEuler2d(img);

assertEqual(testCase, 3, epc);


function testLabels(testCase)

% create a label image with 3 labels
img = zeros(10, 10);
img(2:3, 2:3) = 3;
img(6:8, 2:3) = 5;
img(3:5, 5:8) = 9;
img(4, 6) = 0;

[chi, labels] = imEuler2d(img);

assertElementsAlmostEqual(chi, [1 1 0]');
assertElementsAlmostEqual(labels, [3 5 9]');


function testLabelImage(testCase)

lbl = bwlabel(imread('coins.png') > 100);

chi = imEuler2d(lbl);

assertEqual(testCase, 10, length(chi));
assertEqual(testCase, 1, max(chi));

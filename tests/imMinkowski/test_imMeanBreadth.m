function tests = test_imMeanBreadth(varargin)
%TEST_IMMEANBREADTH  One-line description here, please.
%
%   output = test_imMeanBreadth(input)
%
%   Example
%   test_imMeanBreadth
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);

function testAddBorderD3(testCase)

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 3;
b = imMeanBreadth(img, nDir);
bb = imMeanBreadth(imgb, nDir);

assertEqual(testCase, b, bb);

function testAddBorderD13(testCase)

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 13;
b = imMeanBreadth(img, nDir);
bb = imMeanBreadth(imgb, nDir);
assertEqual(testCase, b, bb);


function test_Labels(testCase)

img = zeros([6 6 6]);
img(1:3, 1:3, 1:3) = 2;
img(4:6, 1:3, 1:3) = 3;
img(1:3, 4:6, 1:3) = 5;
img(4:6, 4:6, 1:3) = 7;
img(1:3, 1:3, 4:6) = 11;
img(4:6, 1:3, 4:6) = 13;
img(1:3, 4:6, 4:6) = 17;
img(4:6, 4:6, 4:6) = 19;

[mb, labels] = imMeanBreadth(img);
assertEqual(testCase, size(mb), [8 1], .01);
assertEqual(testCase, labels, [2 3 5 7 11 13 17 19]');


function test_Labels2(testCase)

img = zeros([6 6 6]);
img(1:3, 1:3, 1:3) = 2;
img(4:6, 1:3, 1:3) = 3;
img(1:3, 4:6, 1:3) = 5;
img(4:6, 4:6, 1:3) = 7;
img(1:3, 1:3, 4:6) = 11;
img(4:6, 1:3, 4:6) = 13;
img(1:3, 4:6, 4:6) = 17;
img(4:6, 4:6, 4:6) = 19;
labels = [2 3 5 7 11 13 17 19]';

mb = imMeanBreadth(img, labels);
assertEqual(testCase, size(mb), [8 1]);

mb2 = imMeanBreadth(img, labels(1:2:end));
assertEqual(testCase, size(mb2), [4 1]);


function test_Anisotropic(testCase)

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 3;
b = imMeanBreadth(img, nDir, [1 2 3]);
bb = imMeanBreadth(imgb, nDir, [1 2 3]);

assertEqual(testCase, b, bb);


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


function test_isolatedCube_D3(testCase)

img = false([5 5 5]);
imgb = padarray(img, [1 1 1]) > 0;

nDir = 3;
b = imSurfaceArea(img, nDir);
bb = imSurfaceArea(imgb, nDir);
assertEqual(testCase, b, bb);


function test_isolatedCube_D13(testCase)

img = false([5 5 5]);
imgb = padarray(img, [1 1 1]) > 0;

nDir = 13;
b = imSurfaceArea(img, nDir);
bb = imSurfaceArea(imgb, nDir);
assertEqual(testCase, b, bb);


function test_isolatedCube_Anisotropic_D3(testCase)

nDirs = 3;
calib = [3 4 5];
img = false([5 5 5]);
imgb = padarray(img, [1 1 1]) > 0;

b = imSurfaceArea(img, nDirs, calib);
bb = imSurfaceArea(imgb, nDirs, calib);

assertEqual(testCase, b, bb);


function test_isolatedCube_Anisotropic_D13(testCase)

nDirs = 13;
calib = [3 4 5];
img = false([5 5 5]);
imgb = padarray(img, [1 1 1]) > 0;

b = imSurfaceArea(img, nDirs, calib);
bb = imSurfaceArea(imgb, nDirs, calib);

assertEqual(testCase, b, bb);


function test_Labels_D3(testCase)

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
assertEqual(testCase, 8, length(b3));

imgb = padarray(img, [1 1 1]);
bb3 = imSurfaceArea(imgb, 3);

assertEqual(testCase, b3, bb3);


function test_Labels_D13(testCase)

img = zeros([5 5 5]);
img(1:3, 1:3, 1:3) = 1;
img(4:5, 1:3, 1:3) = 2;
img(1:3, 4:5, 1:3) = 3;
img(4:5, 4:5, 1:3) = 4;
img(1:3, 1:3, 4:5) = 5;
img(4:5, 1:3, 4:5) = 6;
img(1:3, 4:5, 4:5) = 7;
img(4:5, 4:5, 4:5) = 8;

b13 = imSurfaceArea(img, 13);
assertEqual(testCase, 8, length(b13));

imgb = padarray(img, [1 1 1]);
bb13 = imSurfaceArea(imgb, 13);
assertEqual(testCase, b13, bb13);


function test_Labels_nonRegular_D3(testCase)

img = zeros([5 5 5]);
img(1:3, 1:3, 1:3) = 2;
img(4:5, 1:3, 1:3) = 3;
img(1:3, 4:5, 1:3) = 5;
img(4:5, 4:5, 1:3) = 7;
img(1:3, 1:3, 4:5) = 11;
img(4:5, 1:3, 4:5) = 13;
img(1:3, 4:5, 4:5) = 17;
img(4:5, 4:5, 4:5) = 19;

[b3, labels3] = imSurfaceArea(img, 3);

assertEqual(testCase, 8, length(b3));
assertEqual(testCase, 8, length(labels3));
assertEqual(testCase, labels3, [2 3 5 7 11 13 17 19]');


function test_Labels_nonRegular_D13(testCase)

img = zeros([5 5 5]);
img(1:3, 1:3, 1:3) = 2;
img(4:5, 1:3, 1:3) = 3;
img(1:3, 4:5, 1:3) = 5;
img(4:5, 4:5, 1:3) = 7;
img(1:3, 1:3, 4:5) = 11;
img(4:5, 1:3, 4:5) = 13;
img(1:3, 4:5, 4:5) = 17;
img(4:5, 4:5, 4:5) = 19;

[b13, labels13] = imSurfaceArea(img, 13);

assertEqual(testCase, 8, length(b13));
assertEqual(testCase, 8, length(labels13));
assertEqual(testCase, labels13, [2 3 5 7 11 13 17 19]');


function test_Labels_nonRegular_Anisotropic_D3(testCase)

nDirs = 3;
calib = [3 4 5];
labels = [2 3 5 7 11 13 17 19];
img = zeros([8 8 8]);
img(1:3, 1:3, 1:3) = labels(1);
img(4:8, 1:3, 1:3) = labels(2);
img(1:3, 4:8, 1:3) = labels(3);
img(4:8, 4:8, 1:3) = labels(4);
img(1:3, 1:3, 4:8) = labels(5);
img(4:8, 1:3, 4:8) = labels(6);
img(1:3, 4:8, 4:8) = labels(7);
img(4:8, 4:8, 4:8) = labels(8);

[res, resLabels] = imSurfaceArea(img, nDirs, calib);

assertEqual(testCase, 8, length(res));
assertEqual(testCase, 8, length(resLabels));
assertEqual(testCase, resLabels, labels');



function test_Labels_nonRegular_Anisotropic_D13(testCase)

nDirs = 13;
calib = [3 4 5];
labels = [2 3 5 7 11 13 17 19];
img = zeros([8 8 8]);
img(1:3, 1:3, 1:3) = labels(1);
img(4:8, 1:3, 1:3) = labels(2);
img(1:3, 4:8, 1:3) = labels(3);
img(4:8, 4:8, 1:3) = labels(4);
img(1:3, 1:3, 4:8) = labels(5);
img(4:8, 1:3, 4:8) = labels(6);
img(1:3, 4:8, 4:8) = labels(7);
img(4:8, 4:8, 4:8) = labels(8);

[res, resLabels] = imSurfaceArea(img, nDirs, calib);

assertEqual(testCase, 8, length(res));
assertEqual(testCase, 8, length(resLabels));
assertEqual(testCase, resLabels, labels');



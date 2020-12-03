function tests = test_imVolume(varargin)
%TEST_imVolume  One-line description here, please.
%
%   output = test_imVolume(input)
%
%   Example
%   test_imVolume
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function testBasic(testCase)

img = ones([2 3 4]);
img = padarray(img, [1 1 1]);

v = imVolume(img);

exp = prod([2 3 4]);
assertEqual(testCase, exp, v);


function testAddBorder(testCase)

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

v0 = imVolume(img);
v2 = imVolume(imgb);

assertEqual(testCase, v0, v2);


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

[vols, labels] = imVolume(img);
assertEqual(testCase, vols, repmat(27, 8, 1), .01);
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

vols = imVolume(img, labels);
assertEqual(testCase, size(vols), [8 1]);
assertEqual(testCase, vols, repmat(27, 8, 1), .01);

vols2 = imVolume(img, labels(1:2:end));
assertEqual(testCase, size(vols2), [4 1]);
assertEqual(testCase, vols2, repmat(27, 4, 1), .01);


function test_Anisotropic(testCase)

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

v0 = imVolume(img, [1 2 3]);
v2 = imVolume(imgb, [1 2 3]);

assertEqual(testCase, v0, v2);


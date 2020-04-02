function tests = test_imAddBorder(varargin) 
% Test suite for function imAddBorder.
%
%   Test case for the file imAddBorder
%
%   Example
%   test_imAddBorder
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-08-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_Rice10(testCase) %#ok<*DEFNU>

img = imread('rice.png');
img2 = imAddBorder(img, 10);
dim2 = size(img2);
assertEqual(testCase, [276 276], dim2);

function test_Rice1020(testCase)

img = imread('rice.png');
img2 = imAddBorder(img, [10 20]);
dim2 = size(img2);
assertEqual(testCase, [276 296], dim2);

function test_Rice10203040(testCase) 

img = imread('rice.png');
img2 = imAddBorder(img, [10 20 30 40]);
dim2 = size(img2);
assertEqual(testCase, [286 326], dim2);


function test_Peppers(testCase)

img = imread('peppers.png');
img2 = imAddBorder(img, 10);
dim2 = size(img2);
assertEqual(testCase, [404 532 3], dim2);


function test_Head_RGB(testCase)

load mri; %#ok<LOAD>
img = cat(3, D, D, D);
img2 = imAddBorder(img, 10);
dim2 = size(img2);
exp = size(img) + [2*10 2*10 0 2*10];
assertEqual(testCase, exp, dim2);


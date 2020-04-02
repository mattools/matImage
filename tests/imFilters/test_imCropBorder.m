function tests = test_imCropBorder(varargin) 
% Test suite for function imCropBorder.
%
%   Test case for the file imCropBorder
%
%   Example
%   test_imCropBorder
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-11-05,    using Matlab (R2018b)
% Copyright 2012 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);

function test_Rice10(testCase) %#ok<*DEFNU>

img = imread('rice.png');
img2 = imCropBorder(img, 10);
dim2 = size(img2);
assertEqual(testCase, [236 236], dim2);

function test_AddCrop_Rice10(testCase) %#ok<*DEFNU>

img = imread('rice.png');
pad = 10;
img2 = imCropBorder(imAddBorder(img, pad), pad);
assertEqual(testCase, size(img), size(img2));

function test_AddCrop_Rice_10_20(testCase) %#ok<*DEFNU>

img = imread('rice.png');
pad = [10 20];
img2 = imCropBorder(imAddBorder(img, pad), pad);
assertEqual(testCase, size(img), size(img2));

function test_AddCrop_Rice_10_20_30_40(testCase) %#ok<*DEFNU>

img = imread('rice.png');
pad = [10 20 30 40];
img2 = imCropBorder(imAddBorder(img, pad), pad);
assertEqual(testCase, size(img), size(img2));

function test_Crop_Peppers_10_20(testCase) %#ok<*DEFNU>

img = imread('peppers.png');
pad = [10 20];
img2 = imCropBorder(img, pad);
assertEqual(testCase, size(img)-2*[pad 0], size(img2));

function test_Crop_Head_RGB(testCase)

load mri; %#ok<LOAD>
img = cat(3, D, D, D);
img2 = imCropBorder(img, 2);
dim2 = size(img2);
exp = size(img) - [2*2 2*2 0 2*2];
assertEqual(testCase, exp, dim2);

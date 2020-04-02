function tests = test_stackSlice(varargin)
%TEST_STACKSLICE  One-line description here, please.
%
%   output = test_stackSlice(input)
%
%   Example
%   test_stackSlice
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-12-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_sliceX_gray(testCase) %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceYZ = stackSlice(img, 1, 5);
assertEqual(testCase, [dim(3) dim(2)], size(sliceYZ));

sliceYZ = stackSlice(img, 'x', 5);
assertEqual(testCase, [dim(3) dim(2)], size(sliceYZ));


function test_sliceY_gray(testCase) %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceZX = stackSlice(img, 2, 5);
assertEqual(testCase, [dim(1) dim(3)], size(sliceZX));

sliceZX = stackSlice(img, 'y', 5);
assertEqual(testCase, [dim(1) dim(3)], size(sliceZX));


function test_sliceZ_gray(testCase) %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceXY = stackSlice(img, 3, 5);
assertEqual(testCase, [dim(2) dim(1)], size(sliceXY));

sliceXY = stackSlice(img, 'z', 5);
assertEqual(testCase, [dim(2) dim(1)], size(sliceXY));


function img = createTestImage

[x, y, z] = meshgrid(1:10, 1:15, 1:20);
img = 5*x + 4*y + 3*z;


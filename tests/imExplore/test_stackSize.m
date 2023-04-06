function tests = test_stackSize(varargin)
%TEST_STACKSIZE  One-line description here, please.
%
%   output = test_stackSize(input)
%
%   Example
%   test_stackSize
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


function test_grayStack(testCase)

img = createTestImage;
dim = stackSize(img);

assertEqual(testCase, [10 15 20], dim);

function test_colorStack(testCase)

img = uint8(createTestImage);
img = permute(img, [1 2 4 3]);
rgb = cat(3, img, img, img);

dim = stackSize(rgb);
assertEqual(testCase, [10 15 20], dim);


function img = createTestImage

[x, y, z] = meshgrid(1:10, 1:15, 1:20);
img = 5*x + 4*y + 3*z;


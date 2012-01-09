function test_suite = test_stackSlice(varargin) %#ok<STOUT>
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


initTestSuite;

function test_sliceX_gray %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceYZ = stackSlice(img, 1, 5);
assertEqual([dim(3) dim(2)], size(sliceYZ));

sliceYZ = stackSlice(img, 'x', 5);
assertEqual([dim(3) dim(2)], size(sliceYZ));


function test_sliceY_gray %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceZX = stackSlice(img, 2, 5);
assertEqual([dim(1) dim(3)], size(sliceZX));

sliceZX = stackSlice(img, 'y', 5);
assertEqual([dim(1) dim(3)], size(sliceZX));


function test_sliceZ_gray %#ok<*DEFNU>

img = createTestImage;
dim = stackSize(img);

sliceXY = stackSlice(img, 3, 5);
assertEqual([dim(2) dim(1)], size(sliceXY));

sliceXY = stackSlice(img, 'z', 5);
assertEqual([dim(2) dim(1)], size(sliceXY));


function img = createTestImage

[x y z] = meshgrid(1:10, 1:15, 1:20);
img = 5*x + 4*y + 3*z;
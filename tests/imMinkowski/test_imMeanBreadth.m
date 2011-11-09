function test_suite = test_imMeanBreadth(varargin) %#ok<STOUT>
%TEST_IMMEANBREADTH  One-line description here, please.
%
%   output = test_imMeanBreadth(input)
%
%   Example
%   test_imMeanBreadth
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function testAddBorderD3 %#ok<*DEFNU>

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 3;
b = imMeanBreadth(img, nDir);
bb = imMeanBreadth(imgb, nDir);
assertEqual(b, bb);

function testAddBorderD13

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 13;
b = imMeanBreadth(img, nDir);
bb = imMeanBreadth(imgb, nDir);
assertEqual(b, bb);

function test_Anisotropic

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

nDir = 3;
b = imMeanBreadth(img, nDir, [1 2 3]);
bb = imMeanBreadth(imgb, nDir, [1 2 3]);
assertEqual(b, bb);


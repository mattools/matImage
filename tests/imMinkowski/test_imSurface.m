function test_suite = test_imSurface(varargin) %#ok<STOUT>
%TEST_IMSURFACE  One-line description here, please.
%
%   output = test_imSurface(input)
%
%   Example
%   test_imSurface
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

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 3;
b = imSurface(img, nDir);
bb = imSurface(imgb, nDir);
assertEqual(b, bb);

function testAddBorderD13

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 13;
b = imSurface(img, nDir);
bb = imSurface(imgb, nDir);
assertEqual(b, bb);

function test_Anisotropic

img = ones([5 5 5]) > 0;
imgb = padarray(img, [1 1 1]) > 0;

nDir = 3;
b = imSurface(img, nDir, [1 2 3]);
bb = imSurface(imgb, nDir, [1 2 3]);
assertEqual(b, bb);

function test_Labels

img = zeros([5 5 5]);
img(1:3, 1:3, 1:3) = 1;
img(4:5, 1:3, 1:3) = 2;
img(1:3, 4:5, 1:3) = 3;
img(4:5, 4:5, 1:3) = 4;
img(1:3, 1:3, 4:5) = 5;
img(4:5, 1:3, 4:5) = 6;
img(1:3, 4:5, 4:5) = 7;
img(4:5, 4:5, 4:5) = 8;

b3 = imSurface(img, 3);
b13 = imSurface(img, 13);
assertEqual(8, length(b3));
assertEqual(8, length(b13));

imgb = padarray(img, [1 1 1]);
bb3 = imSurface(imgb, 3);
bb13 = imSurface(imgb, 13);

assertEqual(b3, bb3);
assertEqual(b13, bb13);


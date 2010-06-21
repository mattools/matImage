function test_suite = testRotateStack90(varargin)
%TESTROTATESTACK90  One-line description here, please.
%   output = testRotateStack90(input)
%
%   Example
%   testRotateStack90
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function testGrayScaleImage

% create a 3D image
lx = 1:10;
ly = 30:5:60;
lz = 50:10:200;
[x y z] = meshgrid(lx, ly, lz);
img = uint8(x+y+z);
dim = size(img);

% rotate around Y-axis
img2 = rotateStack90(img, 1, 1);
assertEqual(dim([1 3 2]), size(img2));
assertEqual(img(1,1,1), img2(1, end,1));
assertEqual(img(1,1,end), img2(1, 1,1));

% rotate around X-axis
img2 = rotateStack90(img, 2, 1);
assertEqual(dim([3 2 1]), size(img2));

% rotate around Z-axis
img2 = rotateStack90(img, 3, 1);
assertEqual(dim([2 1 3]), size(img2));

function testColorImage

% Create rgb image with non equal size in each dimension
lx = 1:50;
ly = 1:52;
lz = 1:54;
r = uint8(discreteBall(lx, ly, lz, [20 30 30], 15)*255);
g = uint8(discreteBall(lx, ly, lz, [30 20 30], 15)*255);
b = uint8(discreteBall(lx, ly, lz, [30 30 20], 15)*255);
img = imMergeBands(r, g, b);

% basic checks
assertEqual('uint8', class(img));
assertEqual([52 50 3 54], size(img));

% dimension of base image, without color
dim = size(r);

% rotate around Y-axis
img2 = rotateStack90(img, 1, 1);
assertEqual([dim(1) dim(3) 3 dim(2)], size(img2));
assertEqual(img(1,1,:,1), img2(1, end,:,1));
assertEqual(img(1,1,:,end), img2(1, 1,:,1));

% rotate around X-axis
img2 = rotateStack90(img, 2, 1);
assertEqual([dim(3) dim(2) 3 dim(1)], size(img2));

% rotate around Z-axis
img2 = rotateStack90(img, 3, 1);
assertEqual([dim(2) dim(1) 3 dim(3)], size(img2));

function test_suite = test_stackRotate90(varargin) %#ok<STOUT>
%TEST_STACKROTATE90  One-line description here, please.
%   output = test_stackRotate90(input)
%
%   Example
%   test_stackRotate90
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



function testRotateX

img = createBasicTestImage;

rotX1th = cat(3, [5 6;1 2], [7 8;3 4]);
imgRX1 = stackRotate90(img, 1, 1);
assertEqual(rotX1th, imgRX1);
imgRX1 = stackRotate90(img, 'x', 1);
assertEqual(rotX1th, imgRX1);

rotX2th = cat(3, [7 8;5 6], [3 4;1 2]);
imgRX2 = stackRotate90(img, 1, 2);
assertEqual(rotX2th, imgRX2);
imgRX2 = stackRotate90(img, 'x', 2);
assertEqual(rotX2th, imgRX2);

rotX3th = cat(3, [3 4;7 8], [1 2;5 6]);
imgRX3 = stackRotate90(img, 1, 3);
assertEqual(rotX3th, imgRX3);
imgRX3 = stackRotate90(img, 'x', 3);
assertEqual(rotX3th, imgRX3);


function testRotateY

img = createBasicTestImage;

rotY1th = cat(3, [2 6;4 8], [1 5;3 7]);
imgRY1 = stackRotate90(img, 2, 1);
assertEqual(rotY1th, imgRY1);
imgRY1 = stackRotate90(img, 'y', 1);
assertEqual(rotY1th, imgRY1);

rotY2th = cat(3, [6 5;8 7], [2 1;4 3]);
imgRY2 = stackRotate90(img, 2, 2);
assertEqual(rotY2th, imgRY2);
imgRY2 = stackRotate90(img, 'y', 2);
assertEqual(rotY2th, imgRY2);

rotY3th = cat(3, [5 1;7 3], [6 2;8 4]);
imgRY3 = stackRotate90(img, 2, 3);
assertEqual(rotY3th, imgRY3);
imgRY3 = stackRotate90(img, 'y', 3);
assertEqual(rotY3th, imgRY3);


function testRotateZ

img = createBasicTestImage;

rotZ1th = cat(3, [3 1;4 2], [7 5;8 6]);
imgRZ1 = stackRotate90(img, 3, 1);
assertEqual(rotZ1th, imgRZ1);
imgRZ1 = stackRotate90(img, 'z', 1);
assertEqual(rotZ1th, imgRZ1);

rotZ2th = cat(3, [4 3;2 1], [8 7;6 5]);
imgRZ2 = stackRotate90(img, 3, 2);
assertEqual(rotZ2th, imgRZ2);
imgRZ2 = stackRotate90(img, 'z', 2);
assertEqual(rotZ2th, imgRZ2);

rotZ3th = cat(3, [2 4;1 3], [6 8;5 7]);
imgRZ3 = stackRotate90(img, 3, 3);
assertEqual(rotZ3th, imgRZ3);
imgRZ3 = stackRotate90(img, 'z', 3);
assertEqual(rotZ3th, imgRZ3);


function testRotateGrayscaleY %#ok<*DEFNU>

img = createTestImageGray;
dim = size(img);

% rotate around Y-axis
img2 = stackRotate90(img, 2, 1);

% check dimension
assertEqual(dim([1 3 2]), size(img2));


function testRotateGrayscaleX

img = createTestImageGray;
dim = size(img);

% rotate around X-axis
img2 = stackRotate90(img, 1, 1);

assertEqual(dim([3 2 1]), size(img2));


function testRotateGrayscaleZ

img = createTestImageGray;
dim = size(img);

% rotate around Z-axis
img2 = stackRotate90(img, 3, 1);
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
img2 = stackRotate90(img, 2, 1);
assertEqual([dim(1) dim(3) 3 dim(2)], size(img2));
assertEqual(img(1,1,:,1), img2(1, end,:,1));
assertEqual(img(1,1,:,end), img2(1, 1,:,1));

% rotate around X-axis
img2 = stackRotate90(img, 1, 1);
assertEqual([dim(3) dim(2) 3 dim(1)], size(img2));

% rotate around Z-axis
img2 = stackRotate90(img, 3, 1);
assertEqual([dim(2) dim(1) 3 dim(3)], size(img2));



function img = createBasicTestImage
img = cat(3, [1 2;3 4], [5 6;7 8]);

function img = createTestImageGray
% create a 3D gray-scale test image
%  ______
% |1    2|\ 
% | 5    |6|
% |3____4| |
%  \7____\8|
%
lx = 1:10;
ly = 30:5:60;
lz = 50:10:200;
[x y z] = meshgrid(lx, ly, lz);
img = uint8(x+y+z);




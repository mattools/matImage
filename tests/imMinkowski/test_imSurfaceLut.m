function tests = test_imSurfaceLut(varargin)
%TEST_IMSURFACELUT  Test case for the file imSurfaceLut
%
%   Test case for the file imSurfaceLut

%   Example
%   test_imSurfaceLut
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2018-09-10,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2018 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_Ball_S3(testCase)
% Test call of function without argument

R = 20;
Sth = 4*pi*R*R;

img = discreteBall(1:50, 1:50, 1:50, [25.12 25.23 25.34 R]);
S3 = imSurface(img, 3);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut3 = imSurfaceLut([1 1 1], 3);

S3byLut = sum(bch .* lut3);

assertEqual(testCase, Sth, S3, 'AbsTol', Sth*.02);
assertEqual(testCase, S3, S3byLut, 'AbsTol', Sth*.01);


function test_Ball_S13(testCase)
% Test call of function without argument

R = 20;
Sth = 4*pi*R*R;

img = discreteBall(1:50, 1:50, 1:50, [25.12 25.23 25.34 R]);
S13 = imSurface(img, 13);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut13 = imSurfaceLut([1 1 1], 13);

S13byLut = sum(bch .* lut13);

assertEqual(testCase, Sth, S13, 'AbsTol', Sth*.02);
assertEqual(testCase, S13, S13byLut, 'AbsTol', Sth*.01);


function test_Singleton_S3_resol345(testCase)
% Test call of function without argument

img = false([5 5 5]);
img(3,3,3) = 1;
resol = [3 4 5];
S3 = imSurface(img, resol, 3);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut3 = imSurfaceLut(resol, 3);

S3byLut = sum(bch .* lut3);

assertEqual(testCase, S3, S3byLut, 'AbsTol', S3*.01);


function test_Cube_S3_resol345(testCase)
% Test call of function without argument

img = false([5 5 5]);
img(2:4,2:4,2:4) = 1;
resol = [3 4 5];
S3 = imSurface(img, resol, 3);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut3 = imSurfaceLut(resol, 3);

S3byLut = sum(bch .* lut3);

assertEqual(testCase, S3, S3byLut, 'AbsTol', S3*.01);


function test_Ball_S3_resol345(testCase)
% Test call of function without argument

R = 40;
Sth = 4*pi*R*R;

img = discreteBall(1:3:100, 1:4:100, 1:5:100, [50.12 50.23 50.34 R]);
resol = [3 4 5];
S3 = imSurface(img, resol, 3);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut3 = imSurfaceLut(resol, 3);

S3byLut = sum(bch .* lut3);

assertEqual(testCase, Sth, S3, 'AbsTol', Sth*.02);
assertEqual(testCase, S3, S3byLut, 'AbsTol', Sth*.01);


function test_Ball_S13_resol345(testCase)
% Test call of function without argument

R = 40;
Sth = 4*pi*R*R;

img = discreteBall(1:3:100, 1:4:100, 1:5:100, [50.12 50.23 50.34 R]);
resol = [3 4 5];
S13 = imSurface(img, resol, 13);

% compute histogram of configurations
bch = imBinaryConfigHisto(img);
lut13 = imSurfaceLut(resol, 13);

S13byLut = sum(bch .* lut13);

assertEqual(testCase, Sth, S13, 'AbsTol', Sth*.02);
assertEqual(testCase, S13, S13byLut, 'AbsTol', Sth*.01);

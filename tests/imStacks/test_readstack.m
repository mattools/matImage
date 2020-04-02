function tests = test_readstack(varargin)
%TEST_READSTACK  Test case for the file readstack
%
%   Test case for the file readstack

%   Example
%   test_readstack
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-09-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_TifList(testCase)
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName);

exp = [96 96 96];
assertEqual(testCase, exp, size(img));


function test_TifListVerbose(testCase)
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName, 'verbose');

exp = [96 96 96];
assertEqual(testCase, exp, size(img));


function test_TifListQuiet(testCase)
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName, 'quiet');

exp = [96 96 96];
assertEqual(testCase, exp, size(img));


function test_TifListRange(testCase)
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
range = 21:80;
img = readstack(fName, range);

exp = [96 96 length(range)];
assertEqual(testCase, exp, size(img));


function test_TifStack(testCase)
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1stack.tif');
img = readstack(fName);

exp = [96 96 96];
assertEqual(testCase, exp, size(img));


function test_TifSlicesRGB(testCase)
% Test call of function without argument

fName = 'mriOverlay/mriOvr-000.tif';
img = readstack(fName);

exp = [128 128 3 27];
assertEqual(testCase, exp, size(img));


function test_TifStackRGB(testCase)
% Test call of function without argument

fName = 'mriOverlay.tif';
img = readstack(fName);

exp = [128 128 3 27];
assertEqual(testCase, exp, size(img));


function test_rawImage(testCase)

img = readstack('img_10x15x20_int16.raw', [10 15 20], 'int16');

exp = [15 10 20];
assertEqual(testCase, exp, size(img));


function test_LSM(testCase)

fName = fullfile('images', '16c_col0_607.lsm');
img = readstack(fName);
exp = [512 512 89];
assertEqual(testCase, exp, size(img));



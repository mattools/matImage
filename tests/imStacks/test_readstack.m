function test_suite = test_readstack(varargin) %#ok<STOUT>
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

initTestSuite;

function test_TifList %#ok<*DEFNU>
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName);

exp = [96 96 96];
assertEqual(exp, size(img));


function test_TifListVerbose
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName, 'verbose');

exp = [96 96 96];
assertEqual(exp, size(img));


function test_TifListQuiet
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
img = readstack(fName, 'quiet');

exp = [96 96 96];
assertEqual(exp, size(img));


function test_TifListRange
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1-000.tif');
range = 21:80;
img = readstack(fName, range);

exp = [96 96 length(range)];
assertEqual(exp, size(img));


function test_TifStack
% Test call of function without argument

fName = fullfile('ratBrainMriSlices', 'BRNOR39e5p1stack.tif');
img = readstack(fName);

exp = [96 96 96];
assertEqual(exp, size(img));



function test_TifStackRGB
% Test call of function without argument

fName = 'mriOverlay.tif';
img = readstack(fName);

exp = [128 128 3 27];
assertEqual(exp, size(img));


function test_rawImage

img = readstack('img_10x15x20_int16.raw', [10 15 20], 'int16');

exp = [10 15 20];
assertEqual(exp, size(img));

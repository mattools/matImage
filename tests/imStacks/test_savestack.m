function tests = test_savestack(varargin)
%TEST_SAVESTACK  Test case for the file savestack
%
%   Test case for the file savestack

%   Example
%   test_savestack
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


function test_SaveGrayStack(testCase)
% Test call of function without argument

D = load ('mri');
D = squeeze(D.D);

fName = 'testSaveGrayStack.tif';
if exist(fName, 'file')
    delete(fName);
end

savestack(D, fName);

info = imfinfo(fName);
assertEqual(testCase, 27, length(info));

delete(fName);


function test_SaveGraySlices(testCase)

D = load ('mri');
D = squeeze(D.D);

genericName = 'testSaveGraySlices*.tif';
patternName = 'testSaveGraySlices###.tif';

list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end

savestack(D, patternName);

list = dir(genericName);
assertEqual(testCase, 27, length(list));

list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end


function test_SaveRGBStack(testCase)
% Test call of function without argument

% create a 3D color image
mri = load ('mri');
mri = squeeze(mri.D);
bin = imclose(mri>0, ones(3, 3));
bnd = imdilate(imBoundary(bin), ones(3, 3));
ovr = imOverlay(mri*3, bnd);

fName = 'testSaveRGBStack.tif';
if exist(fName, 'file')
    delete(fName);
end

savestack(ovr, fName);

info = imfinfo(fName);
assertEqual(testCase, 27, length(info));

delete(fName);


function test_SaveRGBSlices(testCase)
% Test call of function without argument

% create a 3D color image
mri = load ('mri');
mri = squeeze(mri.D);
bin = imclose(mri > 0, ones(3, 3));
bnd = imdilate(imBoundary(bin), ones(3, 3));
ovr = imOverlay(mri*3, bnd);

genericName = 'testSaveRGBSlices*.tif';
patternName = 'testSaveRGBSlices###.tif';

list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end

savestack(ovr, patternName);

list = dir(genericName);
assertEqual(testCase, 27, length(list));

list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end

function test_SaveGrayStackMap(testCase)

D = load ('mri');
D = squeeze(D.D);

fName = 'testSaveGrayStackMap.tif';
if exist(fName, 'file')
    delete(fName);
end
map = jet(256);

savestack(D, map, fName);

info = imfinfo(fName);
assertEqual(testCase, 27, length(info));
assertFalse(testCase, isempty(info(1).Colormap));

delete(fName);


function test_SaveGraySlicesMap(testCase)

D = load ('mri');
D = squeeze(D.D);
map = jet(256);

genericName = 'testSaveGraySlicesMap*.tif';
patternName = 'testSaveGraySlicesMap###.tif';

list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end

savestack(D, map, patternName);

list = dir(genericName);
assertEqual(testCase, 27, length(list));
info = imfinfo(list(1).name);
assertFalse(testCase, isempty(info.Colormap));


list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end


function test_suite = test_savestack(varargin) %#ok<STOUT>
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

initTestSuite;

function test_SaveGrayStack %#ok<*DEFNU>
% Test call of function without argument

D = load ('mri');
D = squeeze(D.D);

fName = 'testSaveGrayStack.tif';
if exist(fName, 'file')
    delete(fName);
end

savestack(D, fName);

info = imfinfo(fName);
assertEqual(27, length(info));

delete(fName);


function test_SaveGraySlices

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
assertEqual(27, length(list));


list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end


function test_SaveRGBStack
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
assertEqual(27, length(info));

delete(fName);


function test_SaveRGBSlices
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
assertEqual(27, length(list));


list = dir(genericName);
for i = 1:length(list)
    delete(list(i).name);
end


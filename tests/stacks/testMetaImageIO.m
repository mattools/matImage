function test_suite = testMetaImageIO(varargin)
% Test MetaImage import and export
%   output = testMetaImageIO(input)
%
%   Example
%   testMetaImageIO
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-07-01,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

initTestSuite;

function testRW_Gray8_2D %#ok<*DEFNU>

img = zeros(10, 10, 'uint8');
img(3:8, 3:8) = 50;
img(4:7, 4:7) = 150;
img(5:6, 5:6) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x10_gray8');

info = metaImageInfo('img_10x10_gray8.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);

function testRW_Gray8_2D_Directory


img = zeros(10, 10, 'uint8');
img(3:8, 3:8) = 50;
img(4:7, 4:7) = 150;
img(5:6, 5:6) = 250;
imgSize = size(img);

fileName = fullfile('images', 'img_10x10_gray8_Dir.mhd');
metaImageWrite(img, fileName);

info = metaImageInfo(fileName);

% % check the binary filename has no directory part
% binaryFileName = info.ElementDataFile;
% [path name] = fileparts(binaryFileName);
% assertTrue(isempty(path));

res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);


function testRW_Gray8_2D_NoExtension

img = zeros(10, 10, 'uint8');
img(3:8, 3:8) = 50;
img(4:7, 4:7) = 150;
img(5:6, 5:6) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x10_gray8');

info = metaImageInfo('img_10x10_gray8');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);


function testRW_Gray8_2D_Rect

Nx = 15;
Ny = 10;
img = zeros(Ny, Nx, 'uint8');
img(3:8, 3:8) = 50;
img(4:7, 4:7) = 150;
img(5:6, 5:6) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x15_gray8');

info = metaImageInfo('img_10x15_gray8.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);


function testRW_Gray8_3D

img = zeros([10, 10, 10], 'uint8');
img(2:8, 3:8) = 50;
img(3:7, 4:7) = 150;
img(4:6, 5:6) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x10x10_gray8');

info = metaImageInfo('img_10x10x10_gray8.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);


function testRW_Gray8_3D_Rect

img = zeros([15, 10, 20], 'uint8');
img(2:8, 3:8, 5:16) = 50;
img(3:7, 4:7, 7:13) = 150;
img(4:6, 5:6, 9:11) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x15x20_gray8');

info = metaImageInfo('img_10x15x20_gray8.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);


function testRW_Gray8_3D_Info
% add some info to header file, and test they are read correctly
img = zeros([10, 15, 20], 'uint8');
img(2:8, 3:8, 5:16) = 50;
img(3:7, 4:7, 7:13) = 150;
img(4:6, 5:6, 9:11) = 250;
imgSize = size(img);

elementSize = [1 2 3];
headerSize = 0;
byteOrder = true;
metaImageWrite(img, 'img_10x15x20_gray8', ...
    'ElementSize', elementSize, ...
    'HeaderSize', headerSize,  ...
    'ElementByteOrderMSB', byteOrder);

info = metaImageInfo('img_10x15x20_gray8.mhd');
res = metaImageRead(info);
resSize = size(res);

assertTrue(isfield(info, 'ElementSize'));
resElementSize = info.ElementSize;
assertEqual(length(resElementSize), length(elementSize));
assertElementsAlmostEqual(resElementSize, elementSize);

assertTrue(isfield(info, 'HeaderSize'));
resHeaderSize = info.HeaderSize;
assertEqual(length(resHeaderSize), length(headerSize));
assertElementsAlmostEqual(resHeaderSize, headerSize);

assertTrue(isfield(info, 'ElementByteOrderMSB'));
resByteOrder = info.ElementByteOrderMSB;
assertTrue(resByteOrder);


assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);



function testRW_Gray16_3D_Rect

img = zeros([15, 10, 20], 'uint16');
img(2:8, 3:8, 5:16) = 50;
img(3:7, 4:7, 7:13) = 150;
img(4:6, 5:6, 9:11) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x15x20_gray16');

info = metaImageInfo('img_10x15x20_gray16.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);

imgType = class(img);
resType = class(res);
assertEqual(imgType, resType, 'error in image type I/O');


function testRW_In16_3D_Rect

img = zeros([15, 10, 20], 'int16');
img(2:8, 3:8, 5:16) = 50;
img(3:7, 4:7, 7:13) = 150;
img(4:6, 5:6, 9:11) = 250;
imgSize = size(img);

metaImageWrite(img, 'img_10x15x20_int16');

info = metaImageInfo('img_10x15x20_int16.mhd');
res = metaImageRead(info);
resSize = size(res);

assertEqual(length(imgSize), length(resSize));
assertElementsAlmostEqual(imgSize, resSize);

imgType = class(img);
resType = class(res);
assertEqual(imgType, resType, 'error in image type I/O');



function test_read_slices_list

filename = 'BRNOR39e5p1List.mhd';
info = metaImageInfo(fullfile('ratBrainMriSlices', filename));
img = metaImageRead(info);

exp = [96 96 96];
assertEqual(exp, size(img), 'image does not have the right size');

assertTrue(max(img(:))>0);


function test_read_slices_pattern

filename = 'BRNOR39e5p1Pattern.mhd';
info = metaImageInfo(fullfile('ratBrainMriSlices', filename));
img = metaImageRead(info);

exp = [96 96 96];
assertEqual(exp, size(img), 'image does not have the right size');

assertTrue(max(img(:))>0);

function tests = test_metaImageRead
% Test suite for the file metaImageRead.
%
%   Test suite for the file metaImageRead
%
%   Example
%   test_metaImageRead
%
%   See also
%     metaImageRead

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_UInt8_2D(testCase)

fileName = 'img_UInt8_rampXY_20x10.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 2);
assertEqual(testCase, size(res), [10 20]);


function test_UInt8_2D_NoExtension(testCase)

fileName = 'img_UInt8_rampXY_20x10';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 2);
assertEqual(testCase, size(res), [10 20]);


function test_RGB8_2D_peppers(testCase)

fileName = 'img_RGB8_peppers.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [384 512 3]);


function test_UInt8_3D_RampXYZ(testCase)

fileName = 'img_UInt8_rampXYZ_6x5x4.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1,1,1), uint8(0));
assertEqual(testCase, res(1,end,1), uint8(5));
assertEqual(testCase, res(end,1,1), uint8(40));
assertEqual(testCase, res(end,end,1), uint8(45));
assertEqual(testCase, res(end,end,end), uint8(255));


function test_read_slice_list(testCase)

filename = 'BRNOR39e5p1List.mhd';
img = metaImageRead(fullfile('ratBrainMriSlices', filename));

exp = [96 96 96];
assertEqual(testCase, size(img), exp, 'image does not have the right size');

assertTrue(max(img(:))>0);


function test_read_slices_pattern(testCase)

filename = 'BRNOR39e5p1Pattern.mhd';
img = metaImageRead(fullfile('ratBrainMriSlices', filename));

exp = [96 96 96];
assertEqual(testCase, size(img), exp, 'image does not have the right size');

assertTrue(max(img(:))>0);


function test_UInt16_3D_RampXYZ_msb(testCase)

fileName = 'img_UInt16_rampXYZ_6x5x4_msb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), uint16(0));
assertEqual(testCase, res(1, 6, 1), uint16(5));
assertEqual(testCase, res(5, 1, 1), uint16(40));
assertEqual(testCase, res(5, 6, 1), uint16(45));
assertEqual(testCase, res(1, 1, 4), uint16(300));
assertEqual(testCase, res(1, 6, 4), uint16(305));
assertEqual(testCase, res(5, 1, 4), uint16(340));
assertEqual(testCase, res(5, 6, 4), uint16(345));


function test_UInt16_3D_RampXYZ_lsb(testCase)

fileName = 'img_UInt16_rampXYZ_6x5x4_lsb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), uint16(0));
assertEqual(testCase, res(1, 6, 1), uint16(5));
assertEqual(testCase, res(5, 1, 1), uint16(40));
assertEqual(testCase, res(5, 6, 1), uint16(45));
assertEqual(testCase, res(1, 1, 4), uint16(300));
assertEqual(testCase, res(1, 6, 4), uint16(305));
assertEqual(testCase, res(5, 1, 4), uint16(340));
assertEqual(testCase, res(5, 6, 4), uint16(345));


function test_Int16_3D_RampXYZ_msb(testCase)

fileName = 'img_Int16_rampXYZ_6x5x4_msb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), int16(0));
assertEqual(testCase, res(1, 6, 1), int16(5));
assertEqual(testCase, res(5, 1, 1), int16(40));
assertEqual(testCase, res(5, 6, 1), int16(45));
assertEqual(testCase, res(1, 1, 4), int16(300));
assertEqual(testCase, res(1, 6, 4), int16(305));
assertEqual(testCase, res(5, 1, 4), int16(340));
assertEqual(testCase, res(5, 6, 4), int16(345));


function test_Int16_3D_RampXYZ_lsb(testCase)

fileName = 'img_Int16_rampXYZ_6x5x4_lsb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), int16(0));
assertEqual(testCase, res(1, 6, 1), int16(5));
assertEqual(testCase, res(5, 1, 1), int16(40));
assertEqual(testCase, res(5, 6, 1), int16(45));
assertEqual(testCase, res(1, 1, 4), int16(300));
assertEqual(testCase, res(1, 6, 4), int16(305));
assertEqual(testCase, res(5, 1, 4), int16(340));
assertEqual(testCase, res(5, 6, 4), int16(345));


function test_Int32_3D_RampXYZ_msb(testCase)

fileName = 'img_Int32_rampXYZ_6x5x4_msb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), int32(0));
assertEqual(testCase, res(1, 6, 1), int32(5));
assertEqual(testCase, res(5, 1, 1), int32(40));
assertEqual(testCase, res(5, 6, 1), int32(45));
assertEqual(testCase, res(1, 1, 4), int32(300));
assertEqual(testCase, res(1, 6, 4), int32(305));
assertEqual(testCase, res(5, 1, 4), int32(340));
assertEqual(testCase, res(5, 6, 4), int32(345));


function test_Int32_3D_RampXYZ_lsb(testCase)

fileName = 'img_Int32_rampXYZ_6x5x4_lsb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), int32(0));
assertEqual(testCase, res(1, 6, 1), int32(5));
assertEqual(testCase, res(5, 1, 1), int32(40));
assertEqual(testCase, res(5, 6, 1), int32(45));
assertEqual(testCase, res(1, 1, 4), int32(300));
assertEqual(testCase, res(1, 6, 4), int32(305));
assertEqual(testCase, res(5, 1, 4), int32(340));
assertEqual(testCase, res(5, 6, 4), int32(345));


function test_Float32_3D_RampXYZ_msb(testCase)

fileName = 'img_Float32_rampXYZ_6x5x4_msb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), single(0));
assertEqual(testCase, res(1, 6, 1), single(5));
assertEqual(testCase, res(5, 1, 1), single(40));
assertEqual(testCase, res(5, 6, 1), single(45));
assertEqual(testCase, res(1, 1, 4), single(300));
assertEqual(testCase, res(1, 6, 4), single(305));
assertEqual(testCase, res(5, 1, 4), single(340));
assertEqual(testCase, res(5, 6, 4), single(345));


function test_Float32_3D_RampXYZ_lsb(testCase)

fileName = 'img_Float32_rampXYZ_6x5x4_lsb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), single(0));
assertEqual(testCase, res(1, 6, 1), single(5));
assertEqual(testCase, res(5, 1, 1), single(40));
assertEqual(testCase, res(5, 6, 1), single(45));
assertEqual(testCase, res(1, 1, 4), single(300));
assertEqual(testCase, res(1, 6, 4), single(305));
assertEqual(testCase, res(5, 1, 4), single(340));
assertEqual(testCase, res(5, 6, 4), single(345));


function test_Float64_3D_RampXYZ_msb(testCase)

fileName = 'img_Float64_rampXYZ_6x5x4_msb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), 0);
assertEqual(testCase, res(1, 6, 1), 5);
assertEqual(testCase, res(5, 1, 1), 40);
assertEqual(testCase, res(5, 6, 1), 45);
assertEqual(testCase, res(1, 1, 4), 300);
assertEqual(testCase, res(1, 6, 4), 305);
assertEqual(testCase, res(5, 1, 4), 340);
assertEqual(testCase, res(5, 6, 4), 345);


function test_Float64_3D_RampXYZ_lsb(testCase)

fileName = 'img_Float64_rampXYZ_6x5x4_lsb.mhd';

res = metaImageRead(fullfile('mhd_images', fileName));

assertEqual(testCase, ndims(res), 3);
assertEqual(testCase, size(res), [5 6 4]);

assertEqual(testCase, res(1, 1, 1), 0);
assertEqual(testCase, res(1, 6, 1), 5);
assertEqual(testCase, res(5, 1, 1), 40);
assertEqual(testCase, res(5, 6, 1), 45);
assertEqual(testCase, res(1, 1, 4), 300);
assertEqual(testCase, res(1, 6, 4), 305);
assertEqual(testCase, res(5, 1, 4), 340);
assertEqual(testCase, res(5, 6, 4), 345);


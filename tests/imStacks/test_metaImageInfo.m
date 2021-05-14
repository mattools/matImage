function tests = test_metaImageInfo
% Test suite for the file metaImageInfo.
%
%   Test suite for the file metaImageInfo
%
%   Example
%   test_metaImageInfo
%
%   See also
%     metaImageInfo

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_UInt8_2D(testCase)

fileName = 'img_UInt8_rampXY_20x10.mhd';

info = metaImageInfo(fullfile('mhd_images', fileName));

assertEqual(testCase, [1 1], info.ElementSpacing);
assertEqual(testCase, [1 1], info.ElementSize);


function test_UInt8_3D_noSizeInit(testCase)

fileName = 'img_UInt8_rampXYZ_6x5x4.mhd';

info = metaImageInfo(fullfile('mhd_images', fileName));

assertEqual(testCase, [1 1 1], info.ElementSpacing);
assertEqual(testCase, [1 1 1], info.ElementSize);


function test_UInt8_3D_initSizeFromSpacing(testCase)

fileName = 'img_UInt8_rampXYZ_6x5x4_Spacing123.mhd';

info = metaImageInfo(fullfile('mhd_images', fileName));

assertEqual(testCase, [1 2 3], info.ElementSpacing);
assertEqual(testCase, [1 2 3], info.ElementSize);


function test_UInt8_3D_initSpacingFromSize(testCase)

fileName = 'img_UInt8_rampXYZ_6x5x4_Size123.mhd';

info = metaImageInfo(fullfile('mhd_images', fileName));

assertEqual(testCase, [1 2 3], info.ElementSpacing);
assertEqual(testCase, [1 2 3], info.ElementSize);


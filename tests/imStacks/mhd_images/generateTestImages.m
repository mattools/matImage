function generateTestImages(varargin)
% Generate the test images used for testing metaimage I/O functions.
%
%   output = generateTestImages(input)
%
%   Example
%   generateTestImages
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.


%% 2D images
% For 2D images, use a small size equal to 20x10, and populate arrays with
% values equals to (10*y + x).

% image size
dims = [20 10];

% generate ramp along each dimension
lx = 0:dims(1)-1;
ly = 0:dims(2)-1;
[x, y] = meshgrid(lx, ly);

% create data
data = y * 10 + x;

% save as UInt8
metaImageWrite(uint8(data), 'img_UInt8_rampXY_20x10.mhd');

% save as UInt16
metaImageWrite(uint16(data), 'img_UInt16_rampXY_20x10_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(uint16(data), 'img_UInt16_rampXY_20x10_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Int16
metaImageWrite(int16(data), 'img_Int16_rampXY_20x10_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(int16(data), 'img_Int16_rampXY_20x10_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Int32
metaImageWrite(int32(data), 'img_Int32_rampXY_20x10_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(int32(data), 'img_Int32_rampXY_20x10_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Float32 (single)
metaImageWrite(single(data), 'img_Float32_rampXY_20x10_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(single(data), 'img_Float32_rampXY_20x10_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Float64 (double)
metaImageWrite(data, 'img_Float64_rampXY_20x10_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(data, 'img_Float64_rampXY_20x10_lsb.mhd', 'ElementByteOrderMSB', false);


%% 2D color image
% For 2D color image, use peppers image, an save it as MHD.

img = imread('peppers.png');

% save as UInt8
metaImageWrite(img, 'img_RGB8_peppers.mhd', 'colorImage', true);


%% 3D images
% For 3D images, use a small size equal to 20x10, and populate arrays with
% values equals to (10*y + x).

% image size
dims = [6 5 4];

% generate ramp along each dimension
lx = 0:dims(1)-1;
ly = 0:dims(2)-1;
lz = 0:dims(3)-1;
[x, y, z] = meshgrid(lx, ly, lz);

% create data
data = z * 100 + y * 10 + x;

% save as UInt8
metaImageWrite(uint8(data), 'img_UInt8_rampXYZ_6x5x4.mhd');

% save as UInt16
metaImageWrite(uint16(data), 'img_UInt16_rampXYZ_6x5x4_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(uint16(data), 'img_UInt16_rampXYZ_6x5x4_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Int16
metaImageWrite(int16(data), 'img_Int16_rampXYZ_6x5x4_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(int16(data), 'img_Int16_rampXYZ_6x5x4_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Int32
metaImageWrite(int32(data), 'img_Int32_rampXYZ_6x5x4_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(int32(data), 'img_Int32_rampXYZ_6x5x4_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Float32 (single)
metaImageWrite(single(data), 'img_Float32_rampXYZ_6x5x4_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(single(data), 'img_Float32_rampXYZ_6x5x4_lsb.mhd', 'ElementByteOrderMSB', false);

% save as Float64 (double)
metaImageWrite(data, 'img_Float64_rampXYZ_6x5x4_msb.mhd', 'ElementByteOrderMSB', true);
metaImageWrite(data, 'img_Float64_rampXYZ_6x5x4_lsb.mhd', 'ElementByteOrderMSB', false);


function tests = test_metaImageWrite
% Test suite for the file metaImageWrite.
%
%   Test suite for the file metaImageWrite
%
%   Example
%   test_metaImageWrite
%
%   See also
%     metaImageWrite

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_array3D_uint8_864(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% arrange data
data = zeros([6 8 4], 'uint8');
baseName = 'array_864_uint8';
headerFileName = [baseName '.mhd'];
dataFileName = [baseName '.raw'];

% ensure clean setup
if exist(headerFileName, 'file') > 0
    delete(headerFileName);
end
if exist(dataFileName, 'file') > 0
    delete(dataFileName);
end

% save file
metaImageWrite(data, [baseName '.mhd']);

% assert
assertTrue(testCase, exist(headerFileName, 'file') > 0);
assertTrue(testCase, exist(dataFileName, 'file') > 0);

newData = metaImageRead(headerFileName);
assertEqual(testCase, ndims(newData), 3);
assertEqual(testCase, size(newData), [6 8 4]);

% cleanup
delete(headerFileName);
delete(dataFileName);


function test_array3D_uint8_543(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% arrange data
[x, y, z] = meshgrid(0:4, 0:3, 0:2);
data = uint8(z * 100 + y * 10 + x);
baseName = 'array_543_uint8';
headerFileName = [baseName '.mhd'];
dataFileName = [baseName '.raw'];

% ensure clean setup
if exist(headerFileName, 'file') > 0
    delete(headerFileName);
end
if exist(dataFileName, 'file') > 0
    delete(dataFileName);
end

% save file
metaImageWrite(data, [baseName '.mhd']);

% assert
assertTrue(testCase, exist(headerFileName, 'file') > 0);
assertTrue(testCase, exist(dataFileName, 'file') > 0);

newData = metaImageRead(headerFileName);
assertEqual(testCase, ndims(newData), 3);
assertEqual(testCase, size(newData), [4 5 3]);

% check value at the eight corners of the data cube
assertEqual(testCase, newData(1, 1, 1), uint8(0));
assertEqual(testCase, newData(4, 1, 1), uint8(30));
assertEqual(testCase, newData(1, 5, 1), uint8(4));
assertEqual(testCase, newData(4, 5, 1), uint8(34));
assertEqual(testCase, newData(1, 1, 3), uint8(200));
assertEqual(testCase, newData(4, 1, 3), uint8(230));
assertEqual(testCase, newData(1, 5, 3), uint8(204));
assertEqual(testCase, newData(4, 5, 3), uint8(234));

% cleanup
delete(headerFileName);
delete(dataFileName);

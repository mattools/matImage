function tests = test_imMaxFeretDiameter
% Test suite for the file imMaxFeretDiameter.
%
%   Test suite for the file imMaxFeretDiameter
%
%   Example
%   test_imMaxFeretDiameter
%
%   See also
%     imMaxFeretDiameter

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2025-09-03,    using Matlab 25.1.0.2943329 (R2025a)
% Copyright 2025 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_square_side20(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% create a binary array containing a 20-by-20 square
img = false(30, 30);
img(6:25, 6:25) = true;

fd = imMaxFeretDiameter(img);
value = 20 * sqrt(2);
assertEqual(testCase, value, fd, 'AbsTol', 0.01);


function test_cube_side20(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% create a 3D binary array containing a cube with side 30 voxels
img = false(30, 30, 30);
img(6:25, 6:25, 6:25) = true;

fd = imMaxFeretDiameter(img);

% keep some tolerance, as extreme points are not the corners of the cube
value = 20 * sqrt(3) - 1;
assertEqual(testCase, value, fd, 'AbsTol', 0.2);


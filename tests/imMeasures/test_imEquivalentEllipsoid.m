function tests = test_imEquivalentEllipsoid
% Test suite for the file imEquivalentEllipsoid.
%
%   Test suite for the file imEquivalentEllipsoid
%
%   Example
%   test_imEquivalentEllipsoid
%
%   See also
%     imEquivalentEllipsoid

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-11-03,    using Matlab 9.10.0.1684407 (R2021a) Update 3
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

%
img = readstack(fullfile('files', 'ellipsoid_Center30x27x25_Size20x12x8_Orient40x30x20.tif'));

elli = imEquivalentEllipsoid(img > 0);

assertEqual(testCase, size(elli), [1 9]);
assertEqual(testCase, [30 27 25], elli(1:3), 'AbsTol', 0.5);
assertEqual(testCase, [20 12  8], elli(4:6), 'AbsTol', 0.5);
assertEqual(testCase, [40 30 20], elli(7:9), 'AbsTol', 0.5);


function test_Calibrated(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = readstack(fullfile('files', 'ellipsoid_Center30x27x25_Size20x12x8_Orient40x30x20.tif'));

elli = imEquivalentEllipsoid(img > 0, 'Spacing', [0.5 0.5 0.5], 'Origin', [0.5 0.5 0.5]);

assertEqual(testCase, size(elli), [1 9]);
assertEqual(testCase, [15 13.5 12.5], elli(1:3), 'AbsTol', 0.5);
assertEqual(testCase, [10 6 4], elli(4:6), 'AbsTol', 0.5);
assertEqual(testCase, [40 30 20], elli(7:9), 'AbsTol', 0.5);


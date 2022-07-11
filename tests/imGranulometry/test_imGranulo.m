function tests = test_imGranulo
% Test suite for the file imGranulo.
%
%   Test suite for the file imGranulo
%
%   Example
%   test_imGranulo
%
%   See also
%     imGranulo

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2022-07-11,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_opening_square(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = createTestImage13x13;

gr = imGranulo(img, 'opening', 'square', [1 2 3]);

vols = [17 39 25];
assertEqual(testCase, gr, 100 * vols / sum(vols), 'AbsTol', 0.01);


function test_opening_lineH(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = createTestImage13x13;

gr = imGranulo(img, 'opening', 'lineH', [1 2 3]);

vols = [9 27 45];
assertEqual(testCase, gr, 100 * vols / sum(vols), 'AbsTol', 0.01);


function test_opening_lineV(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = createTestImage13x13;

gr = imGranulo(img, 'opening', 'lineV', [1 2 3]);

vols = [9 27 45];
assertEqual(testCase, gr, 100 * vols / sum(vols), 'AbsTol', 0.01);


function img = createTestImage13x13
% creates a test images with rectangles whose side lengths are 1, 3, and 5.

img = zeros(13, 13);
img(2, 2) = 255;
img(4:6, 2) = 255;
img(8:12, 2) = 255;
img(2, 4:6) = 255;
img(4:6, 4:6) = 255;
img(8:12, 4:6) = 255;
img(2, 8:12) = 255;
img(4:6, 8:12) = 255;
img(8:12, 8:12) = 255;

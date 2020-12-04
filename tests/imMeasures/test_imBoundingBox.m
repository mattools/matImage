function tests = test_imBoundingBox
% Test suite for the file imBoundingBox.
%
%   Test suite for the file imBoundingBox
%
%   Example
%   test_imBoundingBox
%
%   See also
%     imBoundingBox

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-04,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = false(5, 5);
img(2:3, 3:4) = true;

box = imBoundingBox(img);

assertEqual(testCase, size(box), [1 4]);
assertEqual(testCase, box, [2.5 4.5 1.5 3.5]);


function test_MultiLabels(testCase) %#ok<*DEFNU>
% Test call of function without argument.

lbl = [...
    0 0 0 0 0 0; ...
    0 1 0 2 2 0;...
    0 0 0 0 0 0; ...
    0 3 0 4 4 0; ...
    0 3 0 4 4 0; ...
    0 0 0 0 0 0];
boxes = imBoundingBox(lbl);

assertEqual(testCase, size(boxes), [4 4]);

function test_SpecifyLabels(testCase) %#ok<*DEFNU>
% Test call of function without argument.

lbl = [...
    0 0 0 0 0 0; ...
    0 1 0 3 3 0;...
    0 0 0 0 0 0; ...
    0 4 0 9 9 0; ...
    0 4 0 9 9 0; ...
    0 0 0 0 0 0];
boxes = imBoundingBox(lbl, [3 ; 4]);

assertEqual(testCase, size(boxes), [2 4]);



function test_Simple3d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = false([6 6 6]);
img(3:4, 4:5, 2:3) = true;

box = imBoundingBox(img);

assertEqual(testCase, size(box), [1 6]);
assertEqual(testCase, box, [3.5 5.5  2.5 4.5  1.5 3.5]);


function test_Labels3d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = zeros([9 9 9], 'uint8');
img(2:3, 2:3, 2:3) = 1;
img(5:8, 2:3, 2:3) = 2;
img(2:3, 5:8, 2:3) = 3;
img(5:8, 5:8, 2:3) = 4;
img(2:3, 2:3, 5:8) = 5;
img(5:8, 2:3, 5:8) = 6;
img(2:3, 5:8, 5:8) = 7;
img(5:8, 5:8, 5:8) = 8;

box = imBoundingBox(img);

assertEqual(testCase, size(box), [8 6]);


function test_NonUniformLabels3d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = zeros([9 9 9], 'uint8');
img(2:3, 2:3, 2:3) = 2;
img(5:8, 2:3, 2:3) = 3;
img(2:3, 5:8, 2:3) = 5;
img(5:8, 5:8, 2:3) = 7;
img(2:3, 2:3, 5:8) = 11;
img(5:8, 2:3, 5:8) = 13;
img(2:3, 5:8, 5:8) = 17;
img(5:8, 5:8, 5:8) = 19;

[box, labels] = imBoundingBox(img);

assertEqual(testCase, size(box), [8 6]);
assertEqual(testCase, labels, [2 3 5 7 11 13 17 19]');


function test_SpecifyLabels3d(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = zeros([9 9 9], 'uint8');
img(2:3, 2:3, 2:3) = 1;
img(5:8, 2:3, 2:3) = 2;
img(2:3, 5:8, 2:3) = 3;
img(5:8, 5:8, 2:3) = 4;
img(2:3, 2:3, 5:8) = 5;
img(5:8, 2:3, 5:8) = 6;
img(2:3, 5:8, 5:8) = 7;
img(5:8, 5:8, 5:8) = 8;

box = imBoundingBox(img, [3 4 2 6 7]');

assertEqual(testCase, size(box), [5 6]);


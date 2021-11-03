function tests = test_imEuler3d(varargin) 
%TESTIMEULER3D  One-line description here, please.
%
%   output = testImEuler3d(input)
%
%   Example
%   testImEuler3d
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);

function test_ball(testCase)

% create a simple ball
img = discreteBall(1:20, 1:20, 1:20, [10 10 10 6]);

% check EPC=1 for all adjacencies
epcTh = 1;
assertEqual(testCase, epcTh, imEuler3d(img));
assertEqual(testCase, epcTh, imEuler3d(img, 6));
assertEqual(testCase, epcTh, imEuler3d(img, 26));

% add a holes in the ball -> EPC=2
img = img & ~discreteBall(1:20, 1:20, 1:20, [10 10 10 3]);

% check EPC=1 for all adjacencies
epcTh  = 2;
assertEqual(testCase, epcTh, imEuler3d(img));
assertEqual(testCase, epcTh, imEuler3d(img, 6));
assertEqual(testCase, epcTh, imEuler3d(img, 26));


function test_Torus(testCase)

% create a torus, EPC=0
img = discreteTorus(1:60, 1:60, 1:60, [30 30 30 20 5 60 45]);

% check EPC=1 for all adjacencies
epcTh = 0;
assertEqual(testCase, epcTh, imEuler3d(img));
assertEqual(testCase, epcTh, imEuler3d(img, 6));
assertEqual(testCase, epcTh, imEuler3d(img, 26));



function test_3d_cube_C6(testCase)

% create a simple cube
img = false([5 5 5]);
img(2:4, 2:4, 2:4) = true;

% check EPC=1
epcTh = 1;
assertEqual(testCase, epcTh, imEuler3d(img, 6));

% add a hole in the ball -> EPC=2
img(3, 3, 3) = false;

% check EPC=2
epcTh  = 2;
assertEqual(testCase, epcTh, imEuler3d(img, 6));


function test_3d_cube_C26(testCase)

% create a simple cube
img = false([5 5 5]);
img(2:4, 2:4, 2:4) = true;

% check EPC=1
epcTh = 1;
assertEqual(testCase, epcTh, imEuler3d(img, 26));

% add a hole in the ball -> EPC=2
img(3, 3, 3) = false;

% check EPC=2
epcTh  = 2;
assertEqual(testCase, epcTh, imEuler3d(img, 26));



function test_3d_cubeRing_C6(testCase)

% create a simple cubic ring
img = false([5 5 5]);
img(2:4, 2:4, 2:4) = true;
img(3, 3, 2:4) = false;

% check EPC=0
epcTh = 0;
assertEqual(testCase, epcTh, imEuler3d(img, 6));


function test_3d_cubeRing_C26(testCase)

% create a cubic ring
img = false([5 5 5]);
img(2:4, 2:4, 2:4) = true;
img(3, 3, 2:4) = false;

% check EPC=0
epcTh = 0;
assertEqual(testCase, epcTh, imEuler3d(img, 26));


function test_3D_cubeDiagonals_C6(testCase)

% create a small 3D image with points along cube diagonal
img = false([5 5 5]);
for i = 1:5
    img(i, i, i) = true;
    img(6-i, i, i) = true;
    img(i, 6-i, i) = true;
    img(6-i, 6-i, i) = true;
end

epc6 = imEuler3d(img, 6);

epc6Th = 17;
assertEqual(testCase, epc6, epc6Th);


function test_3D_cubeDiagonals_C26(testCase)

% create a small 3D image with points along cube diagonal
img = false([7 7 7]);
for i = 2:6
    img(i, i, i) = true;
    img(8-i, i, i) = true;
    img(i, 8-i, i) = true;
    img(8-i, 8-i, i) = true;
end

epc26 = imEuler3d(img, 26);

epc26Th = 1;
assertEqual(testCase, epc26, epc26Th);


function test_3D_cubeDiagonals_touchingBorder_C26(testCase)

% create a small 3D image with points along cube diagonal
img = false([5 5 5]);
for i = 1:5
    img(i, i, i) = true;
    img(6-i, i, i) = true;
    img(i, 6-i, i) = true;
    img(6-i, 6-i, i) = true;
end

epc26 = imEuler3d(img, 26);

epc26Th = 1;
assertEqual(testCase, epc26, epc26Th);

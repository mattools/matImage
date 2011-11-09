function test_suite = test_imEuler3d(varargin) %#ok<STOUT>
%TESTIMEULER3D  One-line description here, please.
%
%   output = testImEuler3d(input)
%
%   Example
%   testImEuler3d
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function test_ball %#ok<*DEFNU>

% create a simple ball
img = discreteBall(1:20, 1:20, 1:20, [10 10 10 6]);

% check EPC=1 for all adjacencies
epcTh = 1;
assertEqual(epcTh, imEuler3d(img));
assertEqual(epcTh, imEuler3d(img, 6));
assertEqual(epcTh, imEuler3d(img, 26));

% add a holes in the ball -> EPC=2
img = img & ~discreteBall(1:20, 1:20, 1:20, [10 10 10 3]);

% check EPC=1 for all adjacencies
epcTh  = 2;
assertEqual(epcTh, imEuler3d(img));
assertEqual(epcTh, imEuler3d(img, 6));
assertEqual(epcTh, imEuler3d(img, 26));

function test_Torus

% create a torus, EPC=0
img = discreteTorus(1:60, 1:60, 1:60, [30 30 30 20 5 60 45]);

% check EPC=1 for all adjacencies
epcTh = 0;
assertEqual(epcTh, imEuler3d(img));
assertEqual(epcTh, imEuler3d(img, 6));
assertEqual(epcTh, imEuler3d(img, 26));


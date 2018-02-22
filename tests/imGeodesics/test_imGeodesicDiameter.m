function testSuite = test_imGeodesicDiameter(varargin)
%TEST_IMGEODESICDIAMETER  One-line description here, please.
%
%   output = test_imGeodesicDiameter(input)
%
%   Example
%   test_imGeodesicDiameter
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-07-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

testSuite = buildFunctionHandleTestSuite(localfunctions);

function test_Square5x5 %#ok<*DEFNU>

img = zeros(8, 8);
img(2:6, 3:7) = 1;

assertElementsAlmostEqual((2*11+2*5+1)/5, imGeodesicDiameter(img));
assertElementsAlmostEqual(5, imGeodesicDiameter(img, [1 1]));
assertElementsAlmostEqual(9, imGeodesicDiameter(img, [1 2]));
assertElementsAlmostEqual(19/3, imGeodesicDiameter(img, [3 4]));


function test_SmallSpiral

img = [...
    0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 1 1 1 1 1 1 1 0; ...
    0 0 0 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 0 0 1 0; ...
    0 1 0 0 0 1 0 0 1 0; ...
    0 1 1 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 1 1 1 0; ...
    0 0 0 0 1 1 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0];

% number of orthogonal and diagonal move between extremities
no = 5 + 1 + 3 + 2;
nd = 2 + 2 + 3 + 1;

% exp1s2 = no + nd*sqrt(2) + 1;
% assertElementsAlmostEqual(exp1s2, imGeodesicDiameter(img));
exp11 = no + nd + 1;
assertElementsAlmostEqual(exp11, imGeodesicDiameter(img, [1 1]));
exp12 = no + nd*2 + 1;
assertElementsAlmostEqual(exp12, imGeodesicDiameter(img, [1 2]));
exp34 = (no*3 + nd*4)/3 + 1;
assertElementsAlmostEqual(exp34, imGeodesicDiameter(img, [3 4]));
% assertElementsAlmostEqual(uint16(exp34), imGeodesicDiameter(img, uint16([3 4])));


function test_VerticalLozenge
% vertical lozenge that does not pass test with first version of algo

img = [...
    0 0 0 0 0 0 0 ; ...
    0 0 0 1 0 0 0 ; ...
    0 0 1 1 1 0 0 ; ...
    0 0 1 1 1 0 0 ; ...
    0 1 1 1 1 1 0 ; ...
    0 0 1 1 1 0 0 ; ...
    0 0 1 1 1 0 0 ; ...
    0 0 0 1 0 0 0 ; ...
    0 0 0 0 0 0 0 ; ...
    ];

exp = 7;

assertElementsAlmostEqual(exp, imGeodesicDiameter(img));
assertElementsAlmostEqual(exp, imGeodesicDiameter(img, [1 1]));
assertElementsAlmostEqual(exp, imGeodesicDiameter(img, [1 2]));
assertElementsAlmostEqual(exp, imGeodesicDiameter(img, [3 4]));
assertEqual(uint16(exp), imGeodesicDiameter(img, uint16([3 4])));

function test_SeveralParticles

img = zeros(10, 10);
img(2:4, 2:4) = 1; 
img(6:9, 2:4) = 2; 
img(2:4, 6:9) = 3; 
img(6:9, 6:9) = 4; 

exp11 = [2 3 3 3]' + 1;
exp12 = [4 5 5 6]' + 1;
exp34 = [8/3 11/3 11/3 12/3]' + 1;

% test on label image
assertElementsAlmostEqual(exp11, imGeodesicDiameter(img, [1 1]));
assertElementsAlmostEqual(exp12, imGeodesicDiameter(img, [1 2]));
assertElementsAlmostEqual(exp34, imGeodesicDiameter(img, [3 4]));

function test_SeveralParticles_UInt16

img = zeros(10, 10);
img(2:4, 2:4) = 1; 
img(6:9, 2:4) = 2; 
img(2:4, 6:9) = 3; 
img(6:9, 6:9) = 4; 

exp11 = uint16([2 3 3 3]' + 1);
exp12 = uint16([4 5 5 6]' + 1);
exp34 = uint16([8/3 11/3 11/3 12/3]' + 1);

% test on label image
assertEqual(exp11, imGeodesicDiameter(img, uint16([1 1])));
assertEqual(exp12, imGeodesicDiameter(img, uint16([1 2])));
assertEqual(exp34, imGeodesicDiameter(img, uint16([3 4])));



function test_Verbosity
% this test to ensure verbosity messages do not cause problems

img = [...
    0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 1 1 1 1 1 1 1 0; ...
    0 0 0 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 0 0 1 0; ...
    0 1 0 0 0 1 0 0 1 0; ...
    0 1 1 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 1 1 1 0; ...
    0 0 0 0 1 1 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0]; %#ok<NASGU>

% number of orthogonal and diagonal move between extremities
no = 5 + 1 + 3 + 2;
nd = 2 + 2 + 3 + 1;

% exp1s2 = no + nd*sqrt(2) + 1;
% assertElementsAlmostEqual(exp1s2, imGeodesicDiameter(img, 'verbose', true));
evalc('res11 = imGeodesicDiameter(img, [1 1], ''verbose'', true)');
exp11 = no + nd + 1;
assertElementsAlmostEqual(exp11, res11);

evalc('res12 = imGeodesicDiameter(img, [1 2], ''verbose'', true)');
exp12 = no + nd*2 + 1;
assertElementsAlmostEqual(exp12, res12);

evalc('res34 = imGeodesicDiameter(img, [3 4], ''verbose'', true)');
exp34 = (no*3 + nd*4)/3 + 1;
assertElementsAlmostEqual(exp34, res34);


function test_Verbosity_With_Labeling
% check verbosity when labelling

img = [...
    0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 1 1 1 1 1 1 1 0; ...
    0 0 0 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 0 0 1 0; ...
    0 1 0 0 0 1 0 0 1 0; ...
    0 1 1 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 1 1 1 0; ...
    0 0 0 0 1 1 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0]; %#ok<NASGU>

% number of orthogonal and diagonal move between extremities
no = 5 + 1 + 3 + 2;
nd = 2 + 2 + 3 + 1;
evalc('res34 = imGeodesicDiameter(img, [3 4], ''verbose'', true)');
exp34 = (no*3 + nd*4)/3 + 1;
assertElementsAlmostEqual(exp34, res34);

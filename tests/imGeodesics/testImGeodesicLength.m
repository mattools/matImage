function test_suite = testImGeodesicLength(varargin)
%testImGeodesicLength  One-line description here, please.
%
%   output = testImGeodesicLength(input)
%
%   Example
%   testImGeodesicLength
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


initTestSuite;


function test_Square5x5 %#ok<*DEFNU>

img = zeros(8, 8);
img(2:6, 3:7) = 1;

assertAlmostEqual(4*sqrt(2), imGeodesicLength(img));
assertAlmostEqual(4, imGeodesicLength(img, [1 1]));
assertAlmostEqual(8, imGeodesicLength(img, [1 2]));
assertAlmostEqual(16/3, imGeodesicLength(img, [3 4]));


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

exp1s2 = no + nd*sqrt(2);
assertAlmostEqual(exp1s2, imGeodesicLength(img));
exp11 = no + nd;
assertAlmostEqual(exp11, imGeodesicLength(img, [1 1]));
exp12 = no + nd*2;
assertAlmostEqual(exp12, imGeodesicLength(img, [1 2]));
exp34 = (no*3 + nd*4)/3;
assertAlmostEqual(exp34, imGeodesicLength(img, [3 4]));
assertAlmostEqual(exp34, imGeodesicLength(img, uint16([3 4])));

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

exp = 6;

assertAlmostEqual(exp, imGeodesicLength(img));
assertAlmostEqual(exp, imGeodesicLength(img, [1 1]));
assertAlmostEqual(exp, imGeodesicLength(img, [1 2]));
assertAlmostEqual(exp, imGeodesicLength(img, [3 4]));
assertAlmostEqual(exp, imGeodesicLength(img, uint16([3 4])));

function test_SeveralParticles

img = zeros(10, 10);
img(2:4, 2:4) = 1; 
img(6:9, 2:4) = 2; 
img(2:4, 6:9) = 3; 
img(6:9, 6:9) = 4; 

exp11 = [2 3 3 3]';
exp12 = [4 5 5 6]';
exp34 = [8/3 11/3 11/3 12/3]';

% test on label image
assertAlmostEqual(exp11, imGeodesicLength(img, [1 1]));
assertAlmostEqual(exp12, imGeodesicLength(img, [1 2]));
assertAlmostEqual(exp34, imGeodesicLength(img, [3 4]));
assertAlmostEqual(exp34, imGeodesicLength(img, uint16([3 4])));

% test on binary image that will be labeled
assertAlmostEqual(exp11, imGeodesicLength(img>0, [1 1]));
assertAlmostEqual(exp12, imGeodesicLength(img>0, [1 2]));
assertAlmostEqual(exp34, imGeodesicLength(img>0, [3 4]));
assertAlmostEqual(exp34, imGeodesicLength(img>0, uint16([3 4])));



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
    0 0 0 0 0 0 0 0 0 0];

% number of orthogonal and diagonal move between extremities
no = 5 + 1 + 3 + 2;
nd = 2 + 2 + 3 + 1;

exp1s2 = no + nd*sqrt(2);
assertAlmostEqual(exp1s2, imGeodesicLength(img, 'verbose', true));
exp11 = no + nd;
assertAlmostEqual(exp11, imGeodesicLength(img, [1 1], 'verbose', true));
exp12 = no + nd*2;
assertAlmostEqual(exp12, imGeodesicLength(img, [1 2], 'verbose', true));
exp34 = (no*3 + nd*4)/3;
assertAlmostEqual(exp34, imGeodesicLength(img, [3 4], 'verbose', true));
assertAlmostEqual(exp34, imGeodesicLength(img, uint16([3 4]), 'verbose', true));


% and a small test to check verbosity when labelling
assertAlmostEqual(exp34, imGeodesicLength(img>0, [3 4], 'verbose', true));

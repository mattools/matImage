function test_suite = testDistancePoints(varargin)
%TESTDISTANCEPOINTS  One-line description here, please.
%   output = testDistancePoints(input)
%
%   Example
%   testDistancePoints
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

initTestSuite;

function testSingleSingle

pt1 = [10 10];
pt2 = [10 20];
pt3 = [20 20];

assertElementsAlmostEqual(distancePoints(pt1, pt2), 10);
assertElementsAlmostEqual(distancePoints(pt2, pt3), 10);
assertElementsAlmostEqual(distancePoints(pt1, pt3), 10*sqrt(2));

function testSingleArray

pt1 = [10 10];
pt2 = [10 20];
pt3 = [20 20];

assertElementsAlmostEqual(...
    distancePoints(pt1, [pt1; pt2; pt3]), ...
    [0 10 10*sqrt(2)]);

function testArrayArray

pt1 = [10 10];
pt2 = [10 20];
pt3 = [20 20];
pt4 = [20 10];

array1 = [pt1;pt2;pt3];
array2 = [pt1;pt2;pt3;pt4];
res = [...
    0 10 10*sqrt(2) 10;...
    10 0 10 10*sqrt(2);...
    10*sqrt(2) 10 0 10];
    
assertElementsAlmostEqual(distancePoints(array1, array2), res);

function testArrayArrayDiag

pt1 = [10 10];
pt2 = [10 20];
pt3 = [20 20];

array = [pt1;pt2;pt3];

assertElementsAlmostEqual(...
    distancePoints(array, array, 'diag'), ...
    [0;0;0]);

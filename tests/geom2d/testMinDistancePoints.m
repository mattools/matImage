function test_suite = testMinDistancePoints(varargin)
%TESTMINDISTANCEPOINTS  One-line description here, please.
%   output = testMinDistancePoints(input)
%
%   Example
%   testMinDistancePoints
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

function testArray

pts = [50 10;40 60;30 30;20 0;10 60;10 30;0 10];
assertElementsAlmostEqual(minDistancePoints(pts), 20);


function testPointArray

pts = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
assertElementsAlmostEqual(minDistancePoints([40 50], pts), 10*sqrt(5));
assertElementsAlmostEqual(minDistancePoints([25 30], pts), 5*sqrt(5));
assertElementsAlmostEqual(minDistancePoints([30 40], pts), 10);
assertElementsAlmostEqual(minDistancePoints([20 40], pts), 0);

function testArrayArray

pts1 = [40 50;25 30;40 20];
pts2 = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
res = [10*sqrt(5);5*sqrt(5);10];
assertElementsAlmostEqual(minDistancePoints(pts1, pts2), res);



function testArrayNorm

pts = [50 10;40 60;40 30;20 0;10 60;10 30;0 10];
assertElementsAlmostEqual(minDistancePoints(pts, 1), 30);
assertElementsAlmostEqual(minDistancePoints(pts, 100), 20);


function testPointArrayNorm

pts = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
assertElementsAlmostEqual(minDistancePoints([40 50], pts, 2), 10*sqrt(5));
assertElementsAlmostEqual(minDistancePoints([25 30], pts, 2), 5*sqrt(5));
assertElementsAlmostEqual(minDistancePoints([30 40], pts, 2), 10);
assertElementsAlmostEqual(minDistancePoints([20 40], pts, 2), 0);
assertElementsAlmostEqual(minDistancePoints([40 50], pts, 1), 30);
assertElementsAlmostEqual(minDistancePoints([25 30], pts, 1), 15);
assertElementsAlmostEqual(minDistancePoints([30 40], pts, 1), 10);
assertElementsAlmostEqual(minDistancePoints([20 40], pts, 1), 0);

function testArrayArrayNorm

pts1 = [40 50;25 30;40 20];
pts2 = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
res1 = [10*sqrt(5);5*sqrt(5);10];
assertElementsAlmostEqual(minDistancePoints(pts1, pts2, 2), res1);

res2 = [30;15;10];
assertElementsAlmostEqual(minDistancePoints(pts1, pts2, 1), res2);


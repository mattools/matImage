function test_suite = testClipEdge(varargin)
%TESTCLIPEDGE  One-line description here, please.
%   output = testClipEdge(input)
%
%   Example
%   testClipEdge
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

function testInside
% test edges totally inside window, possibly touching edges

box = [0 100 0 100];
assertElementsAlmostEqual(clipEdge([20 30 80 60], box), [20 30 80 60]);
assertElementsAlmostEqual(clipEdge([0  30 80 60], box), [0  30 80 60]);
assertElementsAlmostEqual(clipEdge([0  30 100 60], box), [0  30 100 60]);
assertElementsAlmostEqual(clipEdge([30 0 80 100], box), [30 0 80 100]);
assertElementsAlmostEqual(clipEdge([0 0 100 100], box), [0 0 100 100]);
assertElementsAlmostEqual(clipEdge([0 100 100 0], box), [0 100 100 0]);

function testClip
% test edges totally inside window, possibly touching edges

box = [0 100 0 100];
assertElementsAlmostEqual(clipEdge([20 60 120 60], box), [20 60 100 60]);
assertElementsAlmostEqual(clipEdge([-20 60 80 60], box), [0  60 80 60]);
assertElementsAlmostEqual(clipEdge([20 60 20 160], box), [20 60 20 100]);
assertElementsAlmostEqual(clipEdge([20 -30 20 60], box), [20 0 20 60]);


function testOutside
% test edges totally outside window

box = [0 100 0 100];
assertElementsAlmostEqual(clipEdge([120 30 180 60], box), [0 0 0 0]);
assertElementsAlmostEqual(clipEdge([-20 30 -80 60], box), [0 0 0 0]);
assertElementsAlmostEqual(clipEdge([30 120 60 180], box), [0 0 0 0]);
assertElementsAlmostEqual(clipEdge([30 -20 60 -80], box), [0 0 0 0]);
assertElementsAlmostEqual(clipEdge([-120 110 190 150], box), [0 0 0 0]);

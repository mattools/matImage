function test_suite = testClipLine(varargin)
%TESTCLIPLINE  One-line description here, please.
%   output = testClipLine(input)
%
%   Example
%   testClipLine
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

function testHoriz
% test edges totally inside window, possibly touching edges

box = [0 100 0 100];

% inside
assertElementsAlmostEqual(clipLine([30 40 10 0], box), [0 40 100 40]);

% outside
assertTrue(sum(isnan(clipLine([30 140 10 0], box)))==4);

function testVert
% test edges totally inside window, possibly touching edges

box = [0 100 0 100];
% inside
assertElementsAlmostEqual(clipLine([30 40 0 10], box), [30 0 30 100]);
% outside
assertTrue(sum(isnan(clipLine([140 30 0 10], box)))==4);

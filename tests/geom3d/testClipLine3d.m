function test_suite = testClipLine3d(varargin)
%testClipLine3d  One-line description here, please.
%   output = testClipLine3d(input)
%
%   Example
%   testClipLine3d
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-06-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

initTestSuite;

function testOx
% line parallel to Ox axis
box     = [0 100 0 100 0 100];
line    = [10 20 30 10 0 0];

clipped = clipLine3d(line, box);
edge    = [0 20 30 100 20 30];
assertElementsAlmostEqual(edge, clipped);

function testOy
% line parallel to Ox axis
box     = [0 100 0 100 0 100];
line    = [10 20 30 0 10 0];

clipped = clipLine3d(line, box);
edge    = [10 0 30 10 100 30];
assertElementsAlmostEqual(edge, clipped);

function testOz
% line parallel to Ox axis
box     = [0 100 0 100 0 100];
line    = [10 20 30 0 0 10];

clipped = clipLine3d(line, box);
edge    = [10 20 0 10 20 100];
assertElementsAlmostEqual(edge, clipped);

function testArray
box     = [0 100 0 100 0 100];
lineOx  = [10 20 30 10 0 0];
lineOy  = [10 20 30 0 10 0];
lineOz  = [10 20 30 0 0 10];
lines   = [lineOx;lineOy;lineOz];
clipped = clipLine3d(lines, box);

assertEqual(3, size(clipped, 1));

function test_suite = testNormalizeAngle(varargin)
%  One-line description here, please.
%   output = testNormalizeAngle(input)
%
%   Example
%   testAngle2Points
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

initTestSuite;

function testDefault

theta = pi/2;
assertAlmostEqual(theta, normalizeAngle(theta));

theta = pi;
assertAlmostEqual(theta, normalizeAngle(theta));

theta = 3*pi/2;
assertAlmostEqual(theta, normalizeAngle(theta));

function testVector

theta = linspace(0, 2*pi-.1, 100);
assertElementsAlmostEqual(theta, normalizeAngle(theta));


function testPiCentered

theta = 0;
assertAlmostEqual(theta, normalizeAngle(theta, pi));

theta = pi/2;
assertAlmostEqual(theta, normalizeAngle(theta, pi));

theta = -pi;
assertAlmostEqual(theta, normalizeAngle(theta, pi));

theta = 7*pi/2;
assertAlmostEqual(-pi/2, normalizeAngle(theta, pi));

function testVectorPiCentered

theta = linspace(-pi+.1, pi-.1, 100);
assertElementsAlmostEqual(theta, normalizeAngle(theta, pi));



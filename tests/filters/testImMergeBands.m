function test_suite = testImMergeBands(varargin)
%TESTIMMERGEBANDS  One-line description here, please.
%   output = testImMergeBands(input)
%
%   Example
%   testImMergeBands
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function testImage2dUint8

r = zeros(10, 10, 'uint8');
r(2:4, 4:5) = 200;
g = zeros(10, 10, 'uint8');
r(3:5, 3:7) = 200;
b = zeros(10, 10, 'uint8');
r(6:8, 2:6) = 200;
rgb = imMergeBands(r, g, b);
assertEqual([10 10 3], size(rgb));

[r2 g2 b2] = imSplitBands(rgb);
assertEqual(r, r2);
assertEqual(g, g2);
assertEqual(b, b2);


function testImage3dUint8

r = zeros(10, 10, 10, 'uint8');
r(2:4, 4:5, 5:6) = 200;
g = zeros(10, 10, 10, 'uint8');
r(3:5, 3:7, 2:5) = 200;
b = zeros(10, 10, 10, 'uint8');
r(6:8, 2:6, 3:4) = 200;
rgb = imMergeBands(r, g, b);
assertEqual([10 10 3 10], size(rgb));

[r2 g2 b2] = imSplitBands(rgb);
assertEqual(r, r2);
assertEqual(g, g2);
assertEqual(b, b2);

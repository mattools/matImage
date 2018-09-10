function testSuite = test_imVolume(varargin)
%TEST_imVolume  One-line description here, please.
%
%   output = test_imVolume(input)
%
%   Example
%   test_imVolume
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

testSuite = buildFunctionHandleTestSuite(localfunctions);

function testBasic %#ok<*DEFNU>

img = ones([2 3 4]);
img = padarray(img, [1 1 1]);

v = imVolume(img);
exp = prod([2 3 4]);
assertEqual(exp, v);


function testAddBorder

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

v0 = imVolume(img);
v2 = imVolume(imgb);
assertEqual(v0, v2);


function test_Anisotropic

img = ones([5 5 5]);
imgb = padarray(img, [1 1 1]);

v0 = imVolume(img, [1 2 3]);
v2 = imVolume(imgb, [1 2 3]);
assertEqual(v0, v2);


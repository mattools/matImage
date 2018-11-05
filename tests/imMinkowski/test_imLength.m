function testSuite = test_imLength(varargin)
%TEST_IMLENGTH  One-line description here, please.
%
%   output = test_imLength(input)
%
%   Example
%   test_imLength
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

img = [0 0 1 1 1 1 1 0];

len = imLength(img);
exp = 5;
assertEqual(exp, len);


function testAddBorder

img = ones(1, 5);
imgb = padarray(img, [0 1]);

len = imLength(img);
len2 = imLength(imgb);
assertEqual(len, len2);

function testCalib

img = [0 0 1 1 1 1 1 0];

len = imLength(img, .4);
exp = 2;
assertEqual(exp, len);


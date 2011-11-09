function test_suite = test_imEuler1dEstimate(varargin) %#ok<STOUT>
%TEST_IMEULER1DESTIMATE  One-line description here, please.
%
%   output = test_imEuler1dEstimate(input)
%
%   Example
%   test_imEuler1dEstimate
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function testHoriz %#ok<*DEFNU>

img = logical([0 1 1 1 0 0]);
exp = 1;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([0 1 1 0 1 0]);
exp = 2;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([0 0 1 1 1 1]);
exp = .5;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([1 1 1 0]);
exp = .5;
assertEqual(exp, imEuler1dEstimate(img));


img = logical([1 1 1 1 1 1]);
exp = 0;
assertEqual(exp, imEuler1dEstimate(img));


function testVertical

img = logical([0 1 1 1 0 0])';
exp = 1;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([0 1 1 0 1 0]');
exp = 2;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([0 0 1 1 1 1]');
exp = .5;
assertEqual(exp, imEuler1dEstimate(img));

img = logical([1 1 1 0]');
exp = .5;
assertEqual(exp, imEuler1dEstimate(img));


img = logical([1 1 1 1 1 1]');
exp = 0;
assertEqual(exp, imEuler1dEstimate(img));


function test_suite = test_imConvexify(varargin) %#ok<STOUT>
%TEST_IMCONVEXIFY  One-line description here, please.
%
%   output = test_imConvexify(input)
%
%   Example
%   test_imConvexify
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

initTestSuite;

function test_2d %#ok<*DEFNU>

% two points in image
img = false([6 6]);
img(2, 2) = true;
img(2, 4) = true;

% convex image should be equal to a line
exp = false([6 6]);
exp(2, 2:4) = true;

cvx = imConvexify(img);
assertEqual(exp, cvx);

% we add two points
img(4, 2) = true;
img(4, 4) = true;

% convex image should be equal to a square
exp = false([6 6]);
exp(2:4, 2:4) = true;

cvx = imConvexify(img);
assertEqual(exp, cvx);

function test_3d

% two points in image
img = false([6 6 6]);
img(2, 2, 2) = true;
img(2, 2, 4) = true;

% convex image should be equal to a line
exp = false([6 6 6]);
exp(2, 2, 2:4) = true;

cvx = imConvexify(img);
assertEqual(exp, cvx);


% we add two points
img(2, 4, 2) = true;
img(2, 4, 4) = true;

% convex image should be equal to a square
exp = false([6 6 6]);
exp(2, 2:4, 2:4) = true;

cvx = imConvexify(img);
assertEqual(exp, cvx);

function tests = test_imDistance(varargin)
% Test suite for function imDistance.
%
%   Test case for the file imDistance
%
%   Example
%   test_imDistance
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-11-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function test_Simple(testCase) %#ok<*DEFNU>
% Test with image dimension and points coords
dim = [10 15];
img = imDistance(dim, [2 3;5 8;3 6]);
assertEqual(testCase, dim, size(img));

function test_PeriodicEdge(testCase)
% Test with image dimension and points coords
dim = [10 15];
img = imDistance(dim, [2 3;5 8;3 6], 'periodic');
assertEqual(testCase, dim, size(img));


function test_removeEdge(testCase)
% Test with image dimension and points coords
dim = [100 100];
img = imDistance(dim, [10 10;10 90;90 10;90 90;50 50], 'remove');
assertEqual(testCase, dim, size(img));


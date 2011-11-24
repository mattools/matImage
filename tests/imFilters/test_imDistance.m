function test_suite = test_imDistance(varargin) %#ok<STOUT>
%TEST_IMDISTANCE  Test case for the file imDistance
%
%   Test case for the file imDistance

%   Example
%   test_imDistance
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

initTestSuite;

function test_Simple %#ok<*DEFNU>
% Test with image dimension and points coords
dim = [10 15];
img = imDistance([10 15], [2 3;5 8;3 6]);
assertEqual(dim([2 1]), size(img));

function test_PeriodicEdge
% Test with image dimension and points coords
dim = [10 15];
img = imDistance([10 15], [2 3;5 8;3 6], 'periodic');
assertEqual(dim([2 1]), size(img));


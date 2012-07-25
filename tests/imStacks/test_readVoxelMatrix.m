function test_suite = test_readVoxelMatrix(varargin) %#ok<STOUT>
%TEST_READVOXELMATRIX  Test case for the file readVoxelMatrix
%
%   Test case for the file readVoxelMatrix

%   Example
%   test_readVoxelMatrix
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

initTestSuite;

function test_Simple %#ok<*DEFNU>
% Test call of function without argument

fName = fullfile('images', 'densityMap1.vm');
img = readVoxelMatrix(fName);

assertFalse(isempty(img));

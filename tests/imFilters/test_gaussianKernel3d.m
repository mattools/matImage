function testSuite = test_gaussianKernel3d(varargin)
%TEST_GAUSSIANKERNEL3D  One-line description here, please.
%
%   output = test_gaussianKernel3d(input)
%
%   Example
%   test_gaussianKernel3d
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-11,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

testSuite = buildFunctionHandleTestSuite(localfunctions);

function test_scalarSize %#ok<*DEFNU>

k = gaussianKernel3d(3, 2);

assertEqual([3 3 3], size(k));
assertElementsAlmostEqual(1, sum(k(:)));

function test_vectorSize

k = gaussianKernel3d([7 7 5], 3);

assertEqual([7 7 5], size(k));
assertElementsAlmostEqual(1, sum(k(:)));
 
function test_vectorSigma

k = gaussianKernel3d([7 7 5], [2 2 1]);

assertEqual([7 7 5], size(k));
assertElementsAlmostEqual(1, sum(k(:)));
 
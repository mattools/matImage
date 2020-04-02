function tests = test_gaussianKernel3d(varargin)
% Test suite for function gaussianKernel3d.
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

tests = functiontests(localfunctions);


function test_scalarSize(testCase) %#ok<*DEFNU>

k = gaussianKernel3d(3, 2);

assertEqual(testCase, [3 3 3], size(k));
assertEqual(testCase, 1, sum(k(:)), 'AbsTol', 1e-10);

function test_vectorSize(testCase)

k = gaussianKernel3d([7 7 5], 3);

assertEqual(testCase, [7 7 5], size(k));
assertEqual(testCase, 1, sum(k(:)), 'AbsTol', 1e-10);
 
function test_vectorSigma(testCase)

k = gaussianKernel3d([7 7 5], [2 2 1]);

assertEqual(testCase, [7 7 5], size(k));
assertEqual(testCase, 1, sum(k(:)), 'AbsTol', 1e-10);
 
function test_suite = test_imOrientedBox(varargin) %#ok<STOUT>
%TEST_IMORIENTEDBOX  One-line description here, please.
%
%   output = test_imOrientedBox(input)
%
%   Example
%   test_imOrientedBox
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-11-25,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

initTestSuite;

function test_LabelImage_smallLabels %#ok<DEFNU>

lbl = [0 0 0 0 0 0; ...
0 1 0 2 2 0;...
0 0 0 0 0 0; ...
0 3 0 4 4 0; ...
0 3 0 4 4 0; ...
0 0 0 0 0 0];
obox = imOrientedBox(lbl);

assertEqual([4 5], size(obox));

assertEqual([1;2;2;2], obox(:,3));


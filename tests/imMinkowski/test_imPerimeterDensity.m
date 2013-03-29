function test_suite = test_imPerimeterDensity(varargin) %#ok<STOUT>
%TEST_IMPERIMETERDENSITY  Test case for the file imPerimeterDensity
%
%   Test case for the file imPerimeterDensity

%   Example
%   test_imPerimeterDensity
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-03-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

initTestSuite;

function test_Simple %#ok<*DEFNU>
% Test call of function without argument

img = [ ...
    1 1 1 0 0 0 0 ; ...
    1 1 0 0 1 1 0 ; ...
    0 0 0 1 1 1 0 ; ...
    0 1 0 1 1 0 0 ; ...
    0 1 1 0 0 0 1 ; ...
    0 1 0 0 0 1 1 ; ...
] > 0;

pd = imPerimeterDensity(img);
assertEqual([1 1], size(pd));
assertTrue(pd < 1);

function test_Ndirs %#ok<*DEFNU>
% Test call of function without argument

img = [ ...
    1 1 1 0 0 0 0 ; ...
    1 1 0 0 1 1 0 ; ...
    0 0 0 1 1 1 0 ; ...
    0 1 0 1 1 0 0 ; ...
    0 1 1 0 0 0 1 ; ...
    0 1 0 0 0 1 1 ; ...
] > 0;

pd2 = imPerimeterDensity(img, 2);
assertEqual([1 1], size(pd2));
assertTrue(pd2 < 1);

pd4 = imPerimeterDensity(img, 4);
assertEqual([1 1], size(pd4));
assertTrue(pd4 < 1);




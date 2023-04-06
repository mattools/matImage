function tests = test_imPerimeterDensity(varargin) 
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

tests = functiontests(localfunctions);

function test_Simple(testCase)
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
assertEqual(testCase, [1 1], size(pd));
assertTrue(testCase, pd < 1);


function test_Ndirs(testCase)
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
assertEqual(testCase, [1 1], size(pd2));
assertTrue(testCase, pd2 < 1);

pd4 = imPerimeterDensity(img, 4);
assertEqual(testCase, [1 1], size(pd4));
assertTrue(testCase, pd4 < 1);




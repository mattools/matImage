function test_suite = test_imFeretDiameter(varargin) %#ok<STOUT>
%TEST_IMFERETDIAMETER Test suite for function imFeretDiameter 
%
%   usage:
%   test_imFeretDiameter
%
%   Example
%   test_imHistogram
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-09-10,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function test_square %#ok<*DEFNU>

img = zeros(100, 100, 'uint8');
img(31:60, 21:80) = 1;

fd00 = imFeretDiameter(img, 0);
assertElementsAlmostEqual(60, fd00);

fd90 = imFeretDiameter(img, 90);
assertElementsAlmostEqual(30, fd90);

function test_square_ThetaArray

img = zeros(100, 100, 'uint8');
img(31:60, 21:80) = 1;

fd = imFeretDiameter(img, [0 45 90]);
assertEqual([1 3], size(fd));
assertElementsAlmostEqual(60, fd(1));
assertElementsAlmostEqual(30, fd(3));

function test_square_LabelImage

img = [ ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 0 0 0 0 0 0 0 0; ...
    0 1 0 4 4 4 4 4 0 0; ...
    0 1 0 4 0 0 0 4 0 0; ...
    0 1 0 4 0 6 0 4 0 0; ...
    0 1 0 4 0 0 0 4 0 0; ...
    0 1 0 4 4 4 4 4 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 2 2 2 2 2 2 2 2 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
];

fd = imFeretDiameter(img, [0 15 30 45 60 75 90]);
assertEqual([4 7], size(fd));

[fd labels] = imFeretDiameter(img, [0 15 30 45 60 75 90]);
assertEqual([1 2 4 6]', labels);
assertEqual([4 7], size(fd));

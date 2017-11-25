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

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
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

[fd, labels] = imFeretDiameter(img, [0 15 30 45 60 75 90]);
assertEqual([1 2 4 6]', labels);
assertEqual([4 7], size(fd));


% The folowing are test functions provided by Jasper Vijverberg, 
% and adapted to formatting already used in matImage

function test_image_without_particle_is_returned_as_empty
img = zeros(100, 100, 'uint8');
theta = linspace(0, 180, 201);
fd = imFeretDiameter(img, theta);
assertEqual(true, isempty(fd));

function test_image_with_one_pixel_in_2_by_1_returns_correct_diameters
img = zeros(2,1,'uint8');
img(1,1) = 1;
theta = linspace(0, 180, 201);
fd = imFeretDiameter(img, theta);

assertEqual(1.0, min(fd(1,:)))
assertElementsAlmostEqual(sqrt(2), max(fd(1,:)), 'relative', 1.01);

function test_one_pixel_particle_is_evaluated_correctly
img = zeros(3,3,'uint8');
img(2,2) = 1;
theta = linspace(0, 180, 201);
fd = imFeretDiameter(img, theta);

assertEqual(1.0, min(fd(1,:)))
assertElementsAlmostEqual(sqrt(2), max(fd(1,:)), 'relative', 1.01);

function test_max_feretDiameter_of_rectangle_is_value_of_diagonal
img = zeros(100, 100, 'uint8');
img(41:60, 21:80) = 1;
theta = linspace(0,180,61);
fd = imFeretDiameter(img, theta);

diagonalLength = sqrt(20^2 + 60^2);
assertElementsAlmostEqual(diagonalLength, max(fd(1,:)), 'relative', 1.01);

function test_min_feretDiameter_of_rectangle_is_value_of_short_side
img = zeros(100, 100, 'uint8');
img(41:60, 21:80) = 1;
theta = linspace(0,180,61);
fd = imFeretDiameter(img, theta);
assertElementsAlmostEqual(20, min(fd(1,:)), 'relative', 1.01);

function test_particle_in_corner_is_evaluated_correctly
img = zeros(10, 10, 'uint8');
img(1:3, 1:3) = 1;
theta = linspace(0,180,61);
fd = imFeretDiameter(img, theta);
assertElementsAlmostEqual(3, min(fd(1,:)), 'relative', 1.01);
assertElementsAlmostEqual(sqrt(18), max(fd(1,:)), 'relative', 1.01);

function test_horseshoe_shaped_particle_is_measured_correctly
img = zeros(10, 10, 'uint8');
img(4:6, 4:6) = 1;
img(5, 4:5) = 0; % make it horseshoe shaped
theta = linspace(0,180,61);
fd = imFeretDiameter(img, theta);
assertElementsAlmostEqual(3, min(fd(1,:)), 'relative', 1.01);
assertElementsAlmostEqual(sqrt(18), max(fd(1,:)), 'relative', 1.01);

function test_L_shaped_particle_is_measured_correctly
img = zeros(10, 10, 'uint8');
img(4:6, 4:6) = 1;
img(4:5, 4:5) = 0;
theta = linspace(0,180,61);
fd = imFeretDiameter(img, theta);
assertElementsAlmostEqual(3, min(fd(1,:)), 'relative', 1.01); % minimal diameter is the short side
assertElementsAlmostEqual(sqrt(18), max(fd(1,:)), 'relative', 1.01); % maximum is the diagonal

function tests = test_imRAG(varargin)
%TEST_IMRAG  One-line description here, please.
%   output = test_imRAG(input)
%
%   Example
%   test_imRAG
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-03-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

tests = functiontests(localfunctions);


function testBasic(testCase)

img = [...
    1 1 1 0 2 2 ; ...
    1 1 1 0 2 2 ; ...
    0 0 0 0 2 2 ; ...
    3 3 0 0 0 0 ; ...
    3 3 0 4 4 4 ; ...
    3 3 0 4 4 4 ];

rag = imRAG(img);

expected = [1 2;1 3;2 4;3 4];
assertEqual(testCase, rag, expected);


function testWithInnerRegion(testCase) %#ok<*DEFNU>

img = zeros(9, 9);
img(1:6, 1:6) = 1;
img(2:5, 2:5) = 0;
img(3:4, 3:4) = 2;
img(1:6, 8:9) = 3;
img(8:9, 1:6) = 4;
img(8:9, 8:9) = 5;

rag = imRAG(img);

assertEqual(testCase, 5, size(rag, 1));
expected = [1 2;1 3;1 4;3 5;4 5];
assertEqual(testCase, rag, expected);


function testMissingLabels(testCase)

img = zeros(9, 9);
img(1:6, 1:6) = 10;
img(2:5, 2:5) = 0;
img(3:4, 3:4) = 20;
img(1:6, 8:9) = 30;
img(8:9, 1:6) = 40;
img(8:9, 8:9) = 50;

rag = imRAG(img);

assertEqual(testCase, 5, size(rag, 1));
expected = [1 2;1 3;1 4;3 5;4 5]*10;
assertEqual(testCase, rag, expected);


function testThreeD(testCase)

img = zeros(9,9,9);
l1 = 1:4; l2 = 6:9;
img(l1, l1, l1) = 1;
img(l1, l2, l1) = 2;
img(l2, l1, l1) = 3;
img(l2, l2, l1) = 4;
img(l1, l1, l2) = 5;
img(l1, l2, l2) = 6;
img(l2, l1, l2) = 7;
img(l2, l2, l2) = 8;

rag = imRAG(img);

assertEqual(testCase, 12, size(rag, 1));


function testCentroids(testCase)

img = zeros(5, 6);
img(1:2, 1:2) = 1;
img(1:3, 4:6) = 2;
img(4, 1:2) = 3;
img(5, 1:6) = 3;

[n, rag] = imRAG(img);

% check RAG
ragTh = [1 2;1 3;2 3];
assertEqual(testCase, rag, ragTh);

% check position of centroids
c1 = [1.5 1.5];
c2 = [5 2];
c3 = [3 4.75];
assertEqual(testCase, n(1,:), c1, 'AbsTol', 0.1);
assertEqual(testCase, n(2,:), c2, 'AbsTol', 0.1);
assertEqual(testCase, n(3,:), c3, 'AbsTol', 0.1);


function testCentroids3D(testCase)

img = zeros(9,9,9);
l1 = 1:4; l2 = 6:9;
img(l1, l1, l1) = 1;
img(l1, l1, l2) = 2;
img(l1, l2, l1) = 3;
img(l1, l2, l2) = 4;
img(l2, l1, l1) = 5;
img(l2, l1, l2) = 6;
img(l2, l2, l1) = 7;
img(l2, l2, l2) = 8;

[n, e] = imRAG(img);

assertEqual(testCase, 12, size(e, 1));
assertEqual(testCase, [2.5 2.5 2.5], n(1,:), 'AbsTol', 0.1);


function testNoGap(testCase)

img = [...
    1 1 1 2 2 ; ...
    1 1 1 2 2 ; ...
    3 3 0 2 2 ; ...
    3 3 4 4 4 ; ...
    3 3 4 4 4 ];

rag = imRAG(img, 0);

exp = [1 2;1 3;2 4;3 4];
assertEqual(testCase, rag, exp);


function testNoGap3d(testCase)

img = cat(3, ...
    [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4],  ...
    [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4],  ...
    [5 5 6 6; 5 5 6 6; 7 7 8 8; 7 7 8 8],  ...
    [5 5 6 6; 5 5 6 6; 7 7 8 8; 7 7 8 8]);
exp = [1 2;1 3;1 5;2 4;2 6;3 4;3 7;4 8;5 6;5 7;6 8;7 8];

rag = imRAG(img, 0);

assertEqual(testCase, rag, exp);


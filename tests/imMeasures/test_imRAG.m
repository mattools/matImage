function test_suite = test_imRAG(varargin) %#ok<STOUT>
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
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-03-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;

function testBasic

img = [...
    1 1 1 0 2 2 ; ...
    1 1 1 0 2 2 ; ...
    0 0 0 0 2 2 ; ...
    3 3 0 0 0 0 ; ...
    3 3 0 4 4 4 ; ...
    3 3 0 4 4 4 ];
exp = [1 2;1 3;2 4;3 4];
rag = imRAG(img);
assertEqual(exp, rag);


function testWithInnerRegion %#ok<*DEFNU>

img = zeros(9, 9);
img(1:6, 1:6) = 1;
img(2:5, 2:5) = 0;
img(3:4, 3:4) = 2;
img(1:6, 8:9) = 3;
img(8:9, 1:6) = 4;
img(8:9, 8:9) = 5;

rag = imRAG(img);
assertEqual(5, size(rag, 1));
expected = [1 2;1 3;1 4;3 5;4 5];
assertElementsAlmostEqual(expected, rag);


function testMissingLabels

img = zeros(9, 9);
img(1:6, 1:6) = 10;
img(2:5, 2:5) = 0;
img(3:4, 3:4) = 20;
img(1:6, 8:9) = 30;
img(8:9, 1:6) = 40;
img(8:9, 8:9) = 50;

rag = imRAG(img);
assertEqual(5, size(rag, 1));
expected = [1 2;1 3;1 4;3 5;4 5]*10;
assertElementsAlmostEqual(expected, rag);

function testThreeD

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
assertEqual(12, size(rag, 1));

function testCentroids

img = zeros(5, 6);
img(1:2, 1:2) = 1;
img(1:3, 4:6) = 2;
img(4, 1:2) = 3;
img(5, 1:6) = 3;

c1 = [1.5 1.5];
c2 = [5 2];
c3 = [3 4.75];
eTh = [1 2;1 3;2 3];

[n e] = imRAG(img);
assertElementsAlmostEqual(eTh, e);

assertElementsAlmostEqual(c1, n(1,:));
assertElementsAlmostEqual(c2, n(2,:));
assertElementsAlmostEqual(c3, n(3,:));

function testCentroids3D

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

[n e] = imRAG(img);
assertEqual(12, size(e, 1));

assertElementsAlmostEqual([2.5 2.5 2.5], n(1,:));

function testNoGap

img = [...
    1 1 1 2 2 ; ...
    1 1 1 2 2 ; ...
    3 3 0 2 2 ; ...
    3 3 4 4 4 ; ...
    3 3 4 4 4 ];
exp = [1 2;1 3;2 4;3 4];
rag = imRAG(img, 0);
assertEqual(exp, rag);

function testNoGap3d

img = cat(3, ...
    [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4],  ...
    [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4],  ...
    [5 5 6 6; 5 5 6 6; 7 7 8 8; 7 7 8 8],  ...
    [5 5 6 6; 5 5 6 6; 7 7 8 8; 7 7 8 8]);
exp = [1 2;1 3;1 5;2 4;2 6;3 4;3 7;4 8;5 6;5 7;6 8;7 8];
rag = imRAG(img, 0);
assertEqual(exp, rag);


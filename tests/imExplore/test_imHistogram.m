function tests = test_imHistogram(varargin)
%TEST_IMHISTOGRAM  One-line description here, please.
%
%   output = test_imHistogram(input)
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

tests = functiontests(localfunctions);

function test_cameraman(testCase) %#ok<*DEFNU>

img = imread('cameraman.tif');
h = imHistogram(img);

assertEqual(testCase, 256, length(h));
assertEqual(testCase, numel(img), sum(h));


function test_cameraman_nbins(testCase)

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, 256);
assertEqual(testCase, h0, h);


function test_cameraman_xlims(testCase)

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, [0 255]);
assertEqual(testCase, h0, h);

function test_cameraman_xbins(testCase)

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, linspace(0, 255, 256));
assertEqual(testCase, h0, h);


function test_cameraman_display(testCase) %#ok<INUSD>

img = imread('cameraman.tif');
figure;
imHistogram(img);
close;


function test_cameraman_float(testCase)

img = imread('cameraman.tif');
h0 = imHistogram(img);

img = double(img)/255;
h = imHistogram(img, [0 1]);

assertEqual(testCase, numel(img), sum(h));
assertEqual(testCase, h0, h);


function test_cameraman_roi(testCase)

img = imread('cameraman.tif');
mask = img<80;
h1 = imHistogram(img, mask);
h2 = imHistogram(img, ~mask);

assertEqual(testCase, 256, length(h1));
assertEqual(testCase, 256, length(h2));
assertEqual(testCase, numel(img), sum(h1)+sum(h2));


function test_peppers(testCase)

img = imread('peppers.png');
h = imHistogram(img);

assertEqual(testCase, [256 3], size(h));
assertEqual(testCase, numel(img), sum(h(:)));


function test_peppers_display(testCase) %#ok<INUSD>

img = imread('peppers.png');
figure;
imHistogram(img);
close;


function test_peppers_roi(testCase)

img = imread('peppers.png');
hsv = rgb2hsv(img);
mask = hsv(:,:,1)<.7 | hsv(:,:,1)>.9;

h1 = imHistogram(img, mask);
h2 = imHistogram(img, ~mask);

assertEqual(testCase, 256, size(h1, 1));
assertEqual(testCase, 256, size(h2, 1));
assertEqual(testCase, numel(img), sum(h1(:))+sum(h2(:)));


function test_brainMRI(testCase)

info = analyze75info('brainMRI.hdr');
X = analyze75read(info);
h = imHistogram(X);
assertEqual(testCase, numel(X), sum(h(:)));


function test_brainMRI_roi_bins(testCase)

info = analyze75info('brainMRI.hdr');
X = analyze75read(info);

h = imHistogram(X, X>0, 1:88);

assertEqual(testCase, 88, length(h));


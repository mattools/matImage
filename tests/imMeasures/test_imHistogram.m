function test_suite = test_imHistogram(varargin) %#ok<STOUT>
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

initTestSuite;

function test_cameraman %#ok<*DEFNU>

img = imread('cameraman.tif');
h = imHistogram(img);

assertEqual(256, length(h));
assertEqual(numel(img), sum(h));


function test_cameraman_nbins

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, 256);
assertEqual(h0, h);


function test_cameraman_xlims 

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, [0 255]);
assertEqual(h0, h);

function test_cameraman_xbins 

img = imread('cameraman.tif');
h0 = imHistogram(img);
h = imHistogram(img, linspace(0, 255, 256));
assertEqual(h0, h);


function test_cameraman_display

img = imread('cameraman.tif');
figure;
imHistogram(img);
close;


function test_cameraman_float

img = imread('cameraman.tif');
h0 = imHistogram(img);

img = double(img)/255;
h = imHistogram(img, [0 1]);

assertEqual(numel(img), sum(h));
assertEqual(h0, h);


function test_cameraman_roi

img = imread('cameraman.tif');
mask = img<80;
h1 = imHistogram(img, mask);
h2 = imHistogram(img, ~mask);

assertEqual(256, length(h1));
assertEqual(256, length(h2));
assertEqual(numel(img), sum(h1)+sum(h2));


function test_peppers

img = imread('peppers.png');
h = imHistogram(img);

assertEqual([256 3], size(h));
assertEqual(numel(img), sum(h(:)));


function test_peppers_display %#ok<*DEFNU>

img = imread('peppers.png');
figure;
imHistogram(img);
close;


function test_peppers_roi

img = imread('peppers.png');
hsv = rgb2hsv(img);
mask = hsv(:,:,1)<.7 | hsv(:,:,1)>.9;

h1 = imHistogram(img, mask);
h2 = imHistogram(img, ~mask);

assertEqual(256, size(h1, 1));
assertEqual(256, size(h2, 1));
assertEqual(numel(img), sum(h1(:))+sum(h2(:)));


function test_brainMRI

info = analyze75info('brainMRI.hdr');
X = analyze75read(info);
h = imHistogram(X);
assertEqual(numel(X), sum(h(:)));

function test_brainMRI_roi_bins

info = analyze75info('brainMRI.hdr');
X = analyze75read(info);
h = imHistogram(X, X>0, 1:88);

assertEqual(88, length(h));


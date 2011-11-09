function test_suite = test_imAreaEstimate(varargin) %#ok<STOUT>
% Test function for function testImAreaEstimate
%   output = testImAreaEstimate(input)
%
%   Example
%   testImEuler2d
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-04-22,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

initTestSuite;

function testSquare %#ok<*DEFNU>

img = false(10, 10);
img(3:3+4, 4:4+4) = true;

a = imAreaEstimate(img);
assertEqual(25, a);


function testDelta
% Test with a non uniform resolution

img = false(10, 10);
img(3:3+2, 4:4+3) = true;
delta = [3 5];
expectedArea = 3*delta(1) * 4*delta(2); 

a = imAreaEstimate(img, delta);
assertEqual(expectedArea, a);

function testDividedImage
% compute on an image, cut imag in 4, then check sum of results

img = false(10, 10);
img(2:7, 3:6) = true;

% area estimate on whole image
at = imAreaEstimate(img);

% area estimate in 4 image parts
a1 = imAreaEstimate(img(1:5, 1:5));
a2 = imAreaEstimate(img(1:5, 5:10));
a3 = imAreaEstimate(img(5:10, 1:5));
a4 = imAreaEstimate(img(5:10, 5:10));
as = a1+a2+a3+a4;

assertEqual(at, as);


function testLabelImage

lbl = bwlabel(imread('coins.png') > 100);
a = imArea(lbl);
ae = imAreaEstimate(lbl);

assertEqual(10, length(ae));
assertEqual(a, ae);

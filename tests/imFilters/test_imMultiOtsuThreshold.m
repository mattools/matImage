function tests = test_imMultiOtsuThreshold
% Test suite for the file imMultiOtsuThreshold.
%
%   Test suite for the file imMultiOtsuThreshold
%
%   Example
%   test_imMultiOtsuThreshold
%
%   See also
%     imMultiOtsuThreshold

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-01-29,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

img = imread('cameraman.tif');

classes = imMultiOtsuThreshold(img, 3);

assertEqual(testCase, size(classes), size(img));


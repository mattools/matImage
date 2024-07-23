function e = imJointEntropy(img1, img2, varargin)
%IMJOINTENTROPY Joint entropy between two images
%
%   H12 = imJointEntropy(IMG1, IMG2)
%   Computes the joint entropy between two images. The joint entropy is a
%   measure of the disorder integrated over all couple of values.
%   The joint entropy is greater than the entropy of each individual image,
%   and is lower to the sum of the entropies of each image.
%
%   H12 = imJointEntropy(IMG1, IMG2, N1, N2)
%   H12 = imJointEntropy(IMG1, IMG2, BINS2, BINS2)
%   Computes the joint histogram using either N1-by-N2 bins, or the bins
%   specified by BINS1 and BINS2.
%
%   Example
%     % compute joint entropy of an image and a shifted copy
%     img = imread('cameraman.tif');
%     img2 = circshift(img, [2 3]);
%     H12 = imJointEntropy(img, img2)
%     H12 = 
%         11.9922
%
%     % Joint entropy with fewer bins
%     imJointEntropy(img, img2, 16, 16)
%     ans =
%         5.2506
%
%   See also
%     imEntropy, imMutualInformation, imJointHistogram
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% first compute histogram
h = imJointHistogram(img1, img2, varargin{:});

% keep only positive values, and normalize by 1 to have density
h = h(h > 0);
h = h / sum(h(:));

% compute entropy
e = -sum(h .* log2(h));

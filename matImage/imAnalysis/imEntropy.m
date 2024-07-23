function e = imEntropy(img, varargin)
%IMENTROPY Compute entropy of an image
%
%   H = imEntropy(IMG)
%   Computes the entropy of the image IMG.
%   The entropy is computed as:
%     H  = -sum(P .* log2(P));
%   where P is the density probability that image takes a given value.
%
%   Note that the computation of the entropy depends on the way the
%   histogram is computed. This should not be a concern for uint8 images,
%   but can give results inconsistent with imMutualInformation for double
%   images.
%
%   H = imEntropy(IMG, N)
%   H = imEntropy(IMG, BINS)
%   Computes the histogram using N bins, or the bins specified by BINS. 
%
%
%   Example
%     % compute entropy on a sample image
%     img = imread('rice.png');
%     H = imEntropy(img)
%     H =
%         7.0115
%   
%     % entropy is independent of pixel ordering
%     img2 = circshift(img, [30 40]);
%     H = imEntropy(img2)
%     H =
%         7.0115
%
%     % entropy computed on an histogram with fewer bins
%     imEntropy(img, 16)
%     ans =
%         3.1158
%
%   See also
%     imJointEntropy, imMutualInformation, imHistogram
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% first compute histogram
h = imHistogram(img, varargin{:});

% keep only positive values, and normalize by 1 to have density
h(h==0) = [];
h = h / sum(h);

% compute entropy
e = -sum(h .* log2(h));


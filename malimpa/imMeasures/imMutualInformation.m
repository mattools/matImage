function mi = imMutualInformation(img1, img2)
%IMMUTUALINFORMATION  Mutual information between two images
%
%   MI = imMutualInformation(IMG1, IMG2)
%   Computes the mutual information between two images. 
%   The mutual information can be related to entropy and joint entropy:
%     MI = H1 + H2 - H12
%   where H1 and H2 are the entropies computed on images IMG1 and IMG2, and
%   H12 is the joint entropy of images IMG1 and IMG2.
%
%   The mutual information between two independant images corresponds to
%   the sum of the entropies computed for each image. The mutual
%   information of an image with itself equals the entropy of this image.
%   
%   Example
%   % compute mutual information between an image and a shifted copy of
%   % itself
%     img = imread('cameraman.tif');
%     img2 = circshift(img, [2 3]);
%     MI = imMutualInformation(img, img2)
%     img3 = circshift(img, [5, 7]);
%     MI3 = imMutualInformation(img, img2)
%
%   % Check that we get same results by computing entropies (could be wrong
%   % when computed on double images)
%     img1 = imread('rice.png');
%     img2 = circshift(img1, [3, 4]);
%     imMutualInformation(img1, img2)
%     ans =
%         1.0551
%     h1 = imEntropy(img1);
%     h2 = imEntropy(img2);
%     h12 = imJointEntropy(img1, img2);
%     h1 + h2 - h12
%     ans =
%         1.0551

%   See also
%   imJointEntropy, imJointHistogram, imEntropy
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% joint histogram, and reduced hisograms
hist12  = imJointHistogram(img1, img2);
hist1   = sum(hist12, 2);
hist2   = sum(hist12, 1);

% normalisation of histograms
hist12  = hist12(hist12 > 0) / sum(hist12(:));
hist1   = hist1(hist1 > 0) / sum(hist1(:));
hist2   = hist2(hist2 > 0) / sum(hist2(:));

% entropy of each image
h12 = -sum(hist12 .* log2(hist12));
h1  = -sum(hist1  .* log2(hist1));
h2  = -sum(hist2  .* log2(hist2));

% compute mutual information
mi = h1 + h2 - h12;

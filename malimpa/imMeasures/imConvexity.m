function [cv labels] = imConvexity(img)
%IMCONVEXITY Convexity of particles in label image
%
%   CV = imConvexity(BIN)
%   CV = imConvexity(LBL)
%   Computes the convexity of the binary image BIN, or of the label image
%   LBL. The result is a scalar in the case of binary image, and a column
%   vector in the case of a label image.
%
%   The convexity (also known as solidity) is defined by the ratio of
%   particle volume over the volume of the convex hull of the particle.
%
%   [CV LABELS] = imConvexity(LBL)
%   Also returns the labels for which the convexity has been computed.
%
%
%   Example
%   % compute convexity on a binary image
%     img = imread('circles.png');
%     imConvexity(img)
%     ans =
%         0.6062
%
%   % Compute convexity of rice grains
%     % read image, remove background, threshold and compute labels
%     img = imread('rice.png');
%     bin = imtophat(img, ones(25, 25)) > 50;
%     lbl = bwlabel(imopen(bin, [0 1 0;1 1 1;0 1 0]), 4);
%     % remove border labels
%     lbl0 = unique([unique(lbl([1 end], :)) ; unique(lbl(:, [1 end]))]);
%     lbl(ismember(lbl, lbl0)) = 0;
%     % Compute convexity
%     [conv labels] = imConvexity(lbl);
%     % Display convexity of each particle (note that some labels are not
%     % computed, as they were removed)
%     stem(labels, conv)
%     % the particle with low convexity corresponds to two touching grains
%
%   See also
%     imConvexImage
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% determine the unique values in image (only one in case of binary image)
if islogical(img)
    labels = 1;
else
    % extract the set of labels, and remove label for background
    labels = unique(img(:));
    labels(labels==0) = [];
end

% allocate memory for result
nLabels = length(labels);
cv = zeros(nLabels, 1);

% compute convexity of each particule
for i = 1:nLabels
    imgConv = imConvexImage(img==labels(i));
    cv(i) = sum(img(:)==labels(i)) / sum(imgConv(:));
end

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
%     img = imread('circles.png');
%     imConvexity(img)
%     ans =
%         0.6062
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
    imgConv = imConvexImage(img==i);
    cv(i) = sum(img(:)==i) / sum(imgConv(:));
end

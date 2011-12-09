function [cv labels] = imConvexity(img)
%IMCONVEXITY Convexity of particles in label image
%
%   CV = imConvexity(IMG)
%
%   Example
%   imConvexity
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% extract the set of labels, and remove label for background
labels = unique(img(:));
labels(labels==0) = [];

nLabels = length(labels);

% allocate memory for result
cv = zeros(nLabels, 1);

% iterate on particules
for i = 1:nLabels
    imgConv = imConvexImage(img==i);
    cv(i) = sum(img(:)==i) / sum(imgConv(:));
end

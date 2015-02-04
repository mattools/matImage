function [res, labels] = imRegionFun(img, lbl, op)
%IMREGIONFUN Apply a function to each region of a label image
%
%   RES = imRegionFun(IMG, LBL, OP)
%   For each label of the label image LBL, extract the set of pixels in
%   image IMG, and apply the operation defined by OP.
%
%   Example
%     % comptue segmentation of rice grains
%     img = imread('rice.png');
%     grad = imGradient(img);
%     wat = imImposedWatershed(grad, 10, 4);
%     lbl = imKillBorders(wat);
%     lbl = bwlabel(imAttributeOpening(lbl, 'Area', @gt, 10), 4);
%     figure; imshow(imOverlay(img, imBoundary(lbl>0)));
%     % compute histogram of average gray values
%     grays = imRegionFun(img, lbl, @mean);
%     figure; hist(grays, 20);
%
%   See also
%   

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-02-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% get unique labels (without background)
labels = unique(lbl);
labels(labels == 0) = [];

% allocate memory for result
res = zeros(length(labels), 1);

% iterate on labels
for i = 1:length(labels)
    value = feval(op, double(img(lbl==labels(i))));
    res(i) = value;
end


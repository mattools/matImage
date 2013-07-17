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

% identify the labels in image
if ~islogical(img)
    labels = imFindLabels(img);
else
    % binary images have only one label
    labels = 1;
end

% allocate memory for result
nLabels = length(labels);
cv = zeros(nLabels, 1);

dim = size(img);
nd = length(dim);

% Compute the convexity of each label considered as binary image
% The computation is performed on a subset of the image for reducing
% memory footprint.
props = regionprops(img, 'BoundingBox');
for i = 1:nLabels
    label = labels(i);
    box = props(label).BoundingBox;
    
    % convert bounding box to image extent, in x, y (and z) direction
    % and crop image of current label, keeping a background border
    if nd == 2
        % case of planar images
        i0 = ceil(box([2 1]));
        i1 = i0 + box([4 3]) - 1;
        bin = false(box([4 3]) + 2);
        bin(2:end-1, 2:end-1) = img(i0(1):i1(1), i0(2):i1(2)) == label;
        
    elseif nd == 3
        % case of 3D images
        i0 = ceil(box([2 1 3]));
        i1 = i0 + box([5 4 6]) - 1;
        bin = false(box([5 4 6]) + 2);
        bin(2:end-1, 2:end-1, 2:end-1) = ...
            img(i0(1):i1(1), i0(2):i1(2), i0(3):i1(3)) == label;
    end
    
    % call the computation of convexity on current cropped image
    imgConv = imConvexImage(bin);
    cv(i) = sum(bin(:)) / sum(imgConv(:));
end




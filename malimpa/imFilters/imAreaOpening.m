function [bin inds] = imAreaOpening(lbl, areaMin, varargin)
%IMAREAOPENING Remove all regions smaller than a given area
%
%   LBL2 = imAreaOpening(LBL)
%
%   Example
%   % Remove rice grains smaller than a given size
%     img = imread('rice.png');
%     bin = imtophat(img, ones(30, 30)) > 50;
%     lbl = bwlabel(bin, 4);
%     bin2 = imAreaOpening(lbl, 120);
%     imshow(imOverlay(img, bin2));
%
%   See also
%   regionprops, imLargestRegion, imKillBorders, imAttributeOpening
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% in case of binary image, compute labels
if islogical(lbl)
    lbl = labelmatrix(bwconncomp(lbl, varargin{:}));
end

% compute area of each label
nLabels = max(lbl(:));
areas = zeros(nLabels, 1);
for i = 1:nLabels
    areas(i) = sum(sum(sum(lbl==i)));
end

% find index of largest regions
inds = find(areas > areaMin);

% keep as binary
bin = ismember(lbl, inds);

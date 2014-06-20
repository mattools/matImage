function [lbl inds] = imAreaOpening(img, areaMin, varargin)
%IMAREAOPENING Remove all regions smaller than a given area
%
%   LBL2 = imAreaOpening(LBL, AREAMIN)
%   Computes the area of each particle in label image LBL, and keep only
%   the particles whose area is greater or equal to the given threshold.
%   Returns another label image.
%
%   BIN2 = imAreaOpening(BIN, AREAMIN)
%   BIN2 = imAreaOpening(BIN, AREAMIN, CONN)
%   If BIN is a binary image, connected components are labelised first.
%   The connectivity can be specified. The result is a binary image.
%
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
if islogical(img)
    lbl = labelmatrix(bwconncomp(img, varargin{:}));
else
    lbl = img;
end

% initialisations
nLabels = max(lbl(:));
areas = zeros(nLabels, 1);

% compute area of each label
for i = 1:nLabels
    areas(i) = sum(sum(sum(lbl==i)));
end

% find index of small regions
inds = find(areas < areaMin);

% remove small regions
lbl(ismember(lbl, inds)) = 0;

% keep same output type as input
if islogical(img)
    lbl = lbl > 0;
end
function [lbl, inds] = imSizeOpening(img, minCount, varargin)
%IMSIZEOPENING Remove small regions within binary or label image.
%
%   LBL2 = imSizeOpening(LBL, SIZEMIN)
%   Computes the "size" of each region within the label map LBL, and keeps
%   only the regions whose area is greater or equal to the given threshold.
%   Returns another label image.
%
%   BIN2 = imSizeOpening(BIN, SIZEMIN)
%   BIN2 = imSizeOpening(BIN, SIZEMIN, CONN)
%   If BIN is a binary image, performs a connected components labeling
%   prior to size opening, and converts the result into a binary image.
%   The connectivity can be specified.
%
%
%   Example
%   % Remove rice grains smaller than a given size
%     img = imread('rice.png');
%     bin = imtophat(img, ones(30, 30)) > 50;
%     lbl = bwlabel(bin, 4);
%     bin2 = imSizeOpening(lbl, 120);
%     imshow(imOverlay(img, bin2));
%
%   See also
%   regionprops, imLargestRegion, imKillBorderRegions, imAttributeOpening
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-09-15,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.


% in case of binary image, compute labels
if islogical(img)
    lbl = labelmatrix(bwconncomp(img, varargin{:}));
else
    lbl = img;
end

% Initializations
nLabels = max(lbl(:));

% compute size of each region
histo = histogram(single(lbl), 'BinLimits', [0 double(nLabels)], 'BinMethod', 'integers');
counts = histo.Values(2:end);

% find index of small regions
inds = find(counts < minCount);

% remove small regions
lbl(ismember(lbl, inds)) = 0;

% keep same output type as input
if islogical(img)
    lbl = lbl > 0;
end
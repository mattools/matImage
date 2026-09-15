function [lbl, inds] = imAreaOpening(img, areaMin, varargin)
%IMAREAOPENING Remove all regions smaller than a given area.
%
%   Deprecated, use 'imSizeOpening' instead.
%
%   LBL2 = imAreaOpening(LBL, AREAMIN)
%   Computes the area of each region within the label map LBL, and keep
%   only the regions whose area is greater or equal to the given threshold.
%   Returns another label image.
%
%   BIN2 = imAreaOpening(BIN, AREAMIN)
%   BIN2 = imAreaOpening(BIN, AREAMIN, CONN)
%   If BIN is a binary image, connected components are labeled first.
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
%   regionprops, imLargestRegion, imKillBorderRegions, imAttributeOpening
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-07-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


warning('MatImage:deprecated', ...
    'function imAreaOpening is obsolete, use imSizeOpening instead');

% in case of binary image, compute labels
if islogical(img)
    lbl = labelmatrix(bwconncomp(img, varargin{:}));
else
    lbl = img;
end

% Initializations
nLabels = max(lbl(:));

% compute size of each region
histo = histogram(lbl, 'BinLimits', [0 nLabels], 'BinMethod', 'integers');
counts = histo.Values(2:end);

% find index of small regions
inds = find(counts < areaMin);

% remove small regions
lbl(ismember(lbl, inds)) = 0;

% keep same output type as input
if islogical(img)
    lbl = lbl > 0;
end
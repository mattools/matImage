function [res, inds] = imSizeOpening(img, minCount, varargin)
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
%   CC2 = imSizeOpening(CC, SIZEMIN)
%   Performs size opening on a CC struct as returned by the 'bwconncomp'
%   function, and returns a CC struct.
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
    lbl = bwconncomp(img, varargin{:});
else
    lbl = img;
end

% special case of image provided as "CC" struct
if isstruct(lbl)
    if ~isfield(lbl, "PixelIdxList")
        error("MatImage:imSizeOpening", "If input is a struct, it must contain a 'PixelIdxList' field");
    end

    counts = cellfun(@length, lbl.PixelIdxList);
    inds = find(counts >= minCount);
    res = struct( ...
        'Connectivity', lbl.Connectivity, ...
        'ImageSize', lbl.ImageSize, ...
        'NumObjects', length(inds), ...
        'PixelIdxList', {lbl.PixelIdxList(inds)});

    % keep same data type as input
    if islogical(img)
        res = cc2bw(res);
    end

    return;
end

% Initializations
nLabels = max(lbl(:));

% compute size of each region
histo = histogram(single(lbl), 'BinLimits', [0 double(nLabels)], 'BinMethod', 'integers');
counts = histo.Values(2:end);

% find index of small regions
inds = find(counts < minCount);

% remove small regions
res = lbl;
res(ismember(lbl, inds)) = 0;

% keep same output type as input
if islogical(img)
    res = res > 0;
end
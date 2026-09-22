function [res, indMax] = imLargestRegion(img, varargin)
% Keep the largest region within a binary or label image.
% 
%   REG = imLargestRegion(LBL)
%   Finds the largest region in label map LBL, and returns the binary
%   image corresponding to this region. Can be used to select automatically
%   the most prominent region in a segmentation or labeling result.
%
%   [REG, IND] = imLargestRegion(LBL)
%   Also returns the index of the largest region in the original image.
%
%   REG = imLargestRegion(BIN)
%   REG = imLargestRegion(BIN, CONN)
%   Finds the largest connected region in the binary image IMG. A labeling
%   of the image is performed prior to the identification of the largest
%   label. The connectivity can be specified.
%
%   CC2 = imLargestRegion(CC)
%   Performs identification of the largest region on a CC struct as
%   returned by the 'bwconncomp' function. Returns the result as a new CC
%   struct. 
%
%
%   Example
%     % Find the binary image corresponding to the largest label
%     lbl = [...
%         1 1 0 2 2 2 ;...
%         1 0 0 0 2 2 ;...
%         0 3 0 2 2 0 ;...
%         0 3 3 0 0 0 ;...
%         0 0 0 0 4 0];
%     big = imLargestRegion(lbl)
%     big = 
%         0   0   0   1   1   1 
%         0   0   0   0   1   1 
%         0   0   0   1   1   0 
%         0   0   0   0   0   0 
%         0   0   0   0   0   0
%
% 
%   % Keep the largest region in the result of a binary segmentation
%     img = imread('rice.png');
%     bin = imtophat(img, ones(30, 30)) > 50;
%     bin2 = imLargestRegion(bin, 4);
%     imshow(imOverlay(img, bin2));
%
%   See also
%     regionprops, imKillBorderRegions, imSizeOpening, imAttributeOpening
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-07-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% in case of binary image, compute labels
if islogical(img)
    % result is given as a CC-struct
    lbl = bwconncomp(img, varargin{:});
else
    lbl = img;
end

% special case of image provided as "CC" struct
if isstruct(lbl)
    if ~isfield(lbl, "PixelIdxList")
        error("MatImage:imLargestRegion", ...
            "If input is a struct, it must contain a 'PixelIdxList' field");
    end

    counts = cellfun(@length, lbl.PixelIdxList);
    indMax = find(counts == max(counts), 1, "first");
    res = struct( ...
        'Connectivity', lbl.Connectivity, ...
        'ImageSize', lbl.ImageSize, ...
        'NumObjects', length(indMax), ...
        'PixelIdxList', {lbl.PixelIdxList(indMax)});

    % keep same data type as input
    if islogical(img)
        res = cc2bw(res);
    end

    return;
end


% compute area/volume of each label
nLabels = max(lbl(:));
areas = zeros(nLabels, 1);
for i = 1:nLabels
    areas(i) = sum(sum(sum(lbl==i)));
end

% find index of largest regions
[dum, indMax] = max(areas); %#ok<ASGLU>

% keep as binary
res = lbl == indMax;

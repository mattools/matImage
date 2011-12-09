function img = imMergeLabels(img, lbls, varargin)
%IMMERGELABELS Merge regions in a labeled image
%
%   Usage:
%   LBL2 = imMergeLabels(IMG, LABELS);
%   IMG is a label image, LABELS are the labels of the regions to be
%   merged. IMG can be 2D or 3D.
%   The indices of regions are set to the same value, and the boundary
%   between the regions is also merged to the new region, preserving
%   topology of adjacent regions.
%   The function uses morphologial operation, processing time can be
%   consuming.
%
%   LBL2 = imMergeLabels(IMG, LABELS, SE);
%   Specify the structuring element used for morphological detection of the
%   boundary.
%
%   Example:
%   lbl = [1 1 0 3 3;1 1 0 3 3;1 0 2 0 3;0 2 2 2 0];
%   lbl2 = imMergeLabels(lbl, [1 2])
%   lbl2 =
%        1     1     0     3     3
%        1     1     0     3     3
%        1     1     1     0     3
%        1     1     1     1     0
%
%   See Also
%   imMergeCells (old)
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-08-07
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"

dim = size(img);

% define morphological filter
se = [0 1 0;1 1 1;0 1 0];
if length(dim)>2
    se = cross3d;
end

% use input morphological filter
if ~isempty(varargin)
    se = varargin{1};
end

% convert all merged indices to the same index
bin1 = ismember(img, lbls);
img(bin1) = lbls(1);

% define a mask based on the dilation of remaining regions
bin2 = imdilate(~bin1 & img~=0, se);

% close boundary between the merged regions
bin1 = imclose(bin1, se);

% compute final image
img(bin1 & ~bin2) = lbls(1);

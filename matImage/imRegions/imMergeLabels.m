function img = imMergeLabels(img, lbls, varargin)
%IMMERGELABELS Merge regions in a labeled image
%
%   Deprecated: replaced by the "imMergeRegions" function.
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
%     imMergeRegions
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-08-07
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% simply call the new function
img = imMergeRegions(img, lbls, varargin{:});

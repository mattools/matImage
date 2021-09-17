function res = mergeRegions(lbl, varargin)
%MERGEREGIONS Merge regions of labeled image, using inclusion criteria
%
%   Deprecated: replaced by "imMergeEnclosedRegions"
%
%   Merge regions in an image. Criterion is a inclusion criterion: if a
%   region is mostly within the convex image of a neighbor region, then the
%   two region merge.
%
%	See Also
%	imMergeEnclosedRegions
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 14/01/2004
%

%   HISTORY
%   17/08/2004 create as independant function, and merge 2D and 3D cases

res = imMergeEnclosedRegions(lbl, varargin{:});

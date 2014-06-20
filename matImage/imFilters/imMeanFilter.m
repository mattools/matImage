function res = imMeanFilter(img, se, varargin)
%IMMEANFILTER Compute mean value in the neighboorhood of each pixel
%
%   RES = imMeanFilter(IMG, SE)
%   Computes the mean filter of image IMG, using structuring element SE.
%   The goal of this function is to provide the same interface as for
%   other image filters (imopen, imerode ...), and to allow the use of 
%   mean filter with user-defined structuring element. 
%   This function can be used for directional filtering.
%
%
%   RES = imMeanFilter(IMG, SE, PADOPT) 
%   also specify padding option. PADOPT can be one of X (numeric value),
%   'symmetric', 'replicate', 'circular' (see imfilter for details). 
%   Default is 'replicate'.
%
%   See Also: 
%   imMedianFilter, imDirectionalFilter, imfilter
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   2004-02-17 add support for 'strel' objects.
%   2004-02-20 add PADOPT option, and documentation.
%   2011-11-05 rename from imMean to imMeanFilter

% transform STREL object into single array
if strcmp(class(se), 'strel')
    se = getnhood(se);
end

% get Padopt option
padopt = 'replicate';
if ~isempty(varargin)
    padopt = varargin{1};
end

% perform filtering
res = imfilter(img, se ./ sum(se(:)), padopt);

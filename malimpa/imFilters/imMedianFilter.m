function res = imMedianFilter(img, se, varargin)
%IMMEDIANFILTER Compute median value in the neighboorhood of each pixel
%
%   RES = imMedianFilter(IMG, SE)
%   Compute the median filter of image IMG, using structuring element SE.
%   The goal of this function is to provide the same interface as for
%   other image filters (imopen, imerode ...), and to allow the use of 
%   median filter with user-defined structuring element. 
%   This function can be used for directional filtering.
%
%
%   RES = imMedianFilter(IMG, SE, PADOPT) 
%   also specify padding option. PADOPT can be one 'zeros' or 'symmetric'
%   (see ordfilt2 for details). Default value is 'symmetric'.
%
%   Example
%     img = imread('rice.png');
%     img2 = imMedianFilter(img, ones(5, 5));
%     imshow(img2);
%
%   See Also: 
%   imMeanFilter, imDirectionalFilter, medfilt2, ordfilt2
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   2004-02-17 add support for 'strel' objects.
%   2004-02-20 add 'padopt' option, and documentation
%   2011-11-05 rename from immedian to imMedianFilter
%   2013-10-10 change default behaviour of padopt to 'replicate', add
%       example

% transform STREL object into single array
if isa(se, 'strel')
    se = getnhood(se);
end

% get padopt option.
padopt = 'symmetric';
if ~isempty(varargin)
    padopt = varargin{1};
end

% perform filtering
order = ceil(sum(se(:)) / 2);
res = ordfilt2(img, order, se, padopt);

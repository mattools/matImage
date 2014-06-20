function res = immedian(img, filtre, varargin)
%IMMEDIAN Compute median value in the neighboorhood of each pixel
%
%   RES = immedian(IMG, SE)
%   Compute the median filter of image IMG, using structuring element SE.
%   The goal of this function is to provide the same interface as for
%   other image filters (imopen, imerode ...), and to allow the use of 
%   median filter with user-defined structuring element. 
%   This function can be used for directional filtering.
%
%
%   RES = immedian(IMG, SE, PADOPT) also specify padding option. PADOPT can
%   be either 'zeros' or 'SYMMETRIC', see medfilt2 or ordfilt2 for details.
%
%   See Also: IMMEAN, IMDIRFILTER, MEDFILT2, ORDFILT2
%
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   17/02/2004: add support for 'strel' objects.
%   20/02/2004: add 'padopt' option, and documentation
%   2011-11-05 deprecate

warning('imael:deprecatedFunction', ...
    'function "immedian" has been deprecated and replaced by "imMedianFilter"');


% transform STREL object into single array
if strcmp(class(filtre), 'strel')
    filtre = getnhood(filtre);
end

% get padopt option.
padopt = 'zeros'; % default for standard median filtering in matlab
if ~isempty(varargin)
    padopt = varargin{1};
end

% perform filtering
order = ceil(sum(filtre(:))/2);
res = ordfilt2(img, order, filtre, padopt);

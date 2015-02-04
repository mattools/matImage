function res = immean(img, filtre, varargin)
%IMMEAN Compute mean value in the neighboorhood of each pixel
%
%   RES = immean(IMG, SE)
%   Compute the mean filter of image IMG, using structuring element SE.
%   The goal of this function is to provide the same interface as for
%   other image filters (imopen, imerode ...), and to allow the use of 
%   mean filter with user-defined structuring element. 
%   This function can be used for directional filtering.
%
%
%   RES = immean(IMG, SE, PADOPT) also specify padding option. PADOPT can
%   be one of X (numeric value), 'symmetric', 'replicate', 'circular', see
%   imfilter for details. Default is 'replicate'.
%
%   See Also : IMMEDIAN, IMDIRFILTER, MEDFILT2, ORDFILT2
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   17/02/2004 : add support for 'strel' objects.
%   20/02/2004 : add PADOPT option, and documentation.
%   2011-11-05 deprecate

warning('imael:deprecatedFunction', ...
    'function "immedian" has been deprecated and replaced by "imMedianFilter"');


% transform STREL object into single array
if strcmp(class(filtre), 'strel') %#ok<STISA>
    filtre = getnhood(filtre);
end

% get Padopt option
padopt = 'replicate';
if ~isempty(varargin)
    padopt=varargin{1};
end

% perform filtering
res = imfilter(img, filtre./sum(filtre(:)), padopt);

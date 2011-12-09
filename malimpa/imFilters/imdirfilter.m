function res = imdirfilter(img, varargin)
%IMDIRFILTER Apply and combine several directional filters
%
%   Deprecated, use "imDirectionlFilter" instead.
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   17/02/2004 debug, added some doc, manage different types of images
%   26/02/2007 cleanup code
%   03/10/2007 update doc
%   19/08/2009 fix bug in parsing arguments
%   18/06/2010 fix initialization for 'min' operator, update doc
%   02/12/2011 deprecated and replace by imDirectionalFilter

warning('imael:deprecated', ...
    'function "imdirfilter" has been replaced by "imDirectionalFilter"');

res = imDirectionalFilter(img, varargin{:});

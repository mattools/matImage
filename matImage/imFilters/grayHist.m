function ghist = grayHist(img, varargin)
%GRAYHIST Compute frequencies of configurations in binary images
%
%  
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/10/2004.
%

%   HISTORY 
%   16/02/2005 : rewrite using grayFilter

gray = grayFilter(img, varargin{:});
nd = length(size(img));
ghist = hist(gray(:), 0:(power(2, power(2, nd))-1));

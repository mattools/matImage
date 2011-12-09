function res = cv(data, varargin)
%CV  Computes coefficient of variation
%
%   CV = cv(DATA)
%   compute coefficient of variation using formula :
%   CV = 100xSTD(DATA)/TH;
%   value TH is an estimate of the mean.
%
%   CV = cv(DATA, DIM)
%   Works along the specified dimensions
%
%   CV = cv(DATA, DIM, TH)
%   Specifies the expected value.
%
%   Example
%   cv
%
%   See also
%   std, sem, mean
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2006-03-28
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   21/05/2007 adapt to multidimensional arrays


dim = 1;
if ~isempty(varargin)
    dim = varargin{1};
    varargin(1) = [];
end

if isempty(varargin)
    res = 100*std(data, 0, dim)./mean(data); 
else
    res = 100*std(data, 1, dim)./varargin{1}; 
end

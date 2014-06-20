function res = sem(data, varargin)
%SEM computes standard error of the mean
%
%   SEM = sem(DATA)
%   compute standard error of the mean using formula :
%   SEM = std(DATA)/sqrt(size(DATA, 1));
%
%   SEM = sem(DATA, DIM)
%   works in the specified dimension
%
%   SEM = sem(DATA, DIR, VALUE)
%   provides the true value of the expected value. In this case, normalizes
%   computation of STD by N instead of normalizing by N-1.
%
%   Example
%   
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-05-21
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

dir = 1;
if ~isempty(varargin)
    dir = varargin{1};
    varargin(1) = [];
end

if size(data, 1)==1
    data = data';
end

if isempty(varargin)
    res = std(data, 0, dir)/sqrt(size(data, dir));
else
    res = std(data, 1, dir)/sqrt(size(data, dir));
end

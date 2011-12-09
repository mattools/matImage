function div = div2struct(data, varargin)
%DIV2STRUCT  One-line description here, please.
%   output = div2struct(input)
%
%   Example
%   div2struct
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-06-08
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


% get input parameters
if length(varargin)==2
    ind = varargin{1};
    var = varargin{2};
else
    ind = 1:size(data, 1);
    var = 1:size(data, 2);
end

% ensure 'ind' is a cell array of strings
if isnumeric(ind)
    num = ind(:);
    ind = cell(length(num), 1);
    for i=1:length(num)
        ind{i} = num2char(ind(i));
    end
elseif ischar(ind)
    str = ind;
    ind = cell(length(num), 1);
    for i=1:size(str, 1)
        ind{i} = strtrim(str(i,:));
    end
end

% ensure 'var' is a cell array of strings
if isnumeric(ind)
    num = ind(:);
    ind = cell(length(num), 1);
    for i=1:length(num)
        ind{i} = num2char(ind(i));
    end
elseif ischar(ind)
    str = ind;
    ind = cell(length(num), 1);
    for i=1:size(str, 1)
        ind{i} = strtrim(str(i,:));
    end
end




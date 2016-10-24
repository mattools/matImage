function div = div2struct(data, varargin)
%DIV2STRUCT Convert a DIV data structure to 
%
%   output = div2struct(input)
%
%   Example
%   div2struct
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-06-08
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


% get row and column names
if length(varargin) == 2
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
    for i = 1:length(num)
        ind{i} = num2char(ind(i));
    end
elseif ischar(ind)
    ind = cellstr(ind);
end

% ensure 'var' is a cell array of strings
if isnumeric(var)
    num = var(:);
    var = cell(length(num), 1);
    for i=1:length(num)
        var{i} = num2char(var(i));
    end
elseif ischar(var)
    var = cellstr(var);
end

% create final DIV structure
div.d = data;
div.i = ind;
div.v = var;



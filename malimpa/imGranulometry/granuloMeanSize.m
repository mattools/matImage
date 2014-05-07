function res = granuloMeanSize(tab, xi)
%GRANULOMEANSIZE Compute geometric mean of granulometric curve
%
%   output = granuloMeanSize(input)
%
%   Example
%   granuloMeanSize
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-05-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.

data = tab;
rowNames = cellstr(num2str((1:size(tab, 1))'));
if isa(tab, 'Table')
    data = tab.data;
    rowNames = tab.rowNames;
end

gm = exp(sum(bsxfun(@times, log(xi), data / 100), 2));
res = Table(gm, 'colNames', {'gmean'}, 'rowNames', rowNames);
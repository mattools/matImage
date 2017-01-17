function gm = granuloMeanSize(tab, xi)
%GRANULOMEANSIZE Compute geometric mean of granulometric curve
%
%   GLMS = granuloMeanSize(TAB, XI)
%   Compute grey level mean size from a granulometric curve by using
%   geometric mean.
%   
%   Example
%     % Compute granulometric curve by opening with square structuring
%     % element on rice image 
%     img = imread('rice.png');
%     gr = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     diams = 2*(1:20) + 1;
%     plot(diams, gr);
%     xlabel('Strel diameter (pixel)'); ylabel('Percentage of Variations');
%     glms = granuloMeanSize(gr, diams)
%     glms = 
%         7.7274
%
%   See also
%     imGranulometry, imGranulo, imGranuloByRegion

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2014-05-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.

% extract data
data = tab;
% rowNames = cellstr(num2str((1:size(tab, 1))'));

% in case data are provided as Table, extract numerical data
if isa(tab, 'Table')
    data = tab.data;
%     rowNames = tab.rowNames;
end

% compute geometric mean
gm = exp(sum(bsxfun(@times, log(xi), data / 100), 2));

% % create new data table with result
% res = Table(gm, 'colNames', {'gmean'}, 'rowNames', rowNames);


function gm = granuloMeanSize(tab, xi, dim)
% Compute geometric mean of granulometric curve.
%
%   GLMS = granuloMeanSize(TAB, XI)
%   Compute grey level mean size from a granulometric curve by using
%   geometric mean.
%   
%   Example
%     % Compute granulometric curve by opening with square structuring
%     % element on rice image 
%     img = imread('rice.png');
%     [gr, diams] = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     plot(diams, gr);
%     xlabel('Strel diameter (pixel)'); ylabel('Percentage of Variations');
%     glms = granuloMeanSize(gr, diams)
%     glms = 
%         7.7274
%
%   See also
%     imGranulometry, imGranulo, imGranuloByRegion, granuloMean
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2014-05-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRAE - Cepia Software Platform.

% extract data
data = tab;
   
% in case data are provided as Table, extract numerical data
if isa(tab, 'Table')
    data = tab.Data;
    xi = str2num(char(tab.ColNames'))'; %#ok<ST2NM>
    dim = 2;
end

if  ~isa('dim', 'var')
    % by default, use the last non-singleton dimension
    dim = find(size(data) > 1, 1, 'last');
end

% reshape the xi array in the DIM direction
dims = ones(1, ndims(data));
dims(dim) = length(xi);
xi = reshape(xi, dims);

% normalize data such that sum along DIM equals 1
data = bsxfun(@rdivide, data, sum(data, dim));
% data = data / 100;

% compute geometric mean
gm = exp(sum(bsxfun(@times, data, log(xi)), dim));

% if input is a table, create new data table with result
if isa(tab, 'Table')
    gm = Table(gm, {'gmean'}, tab.RowNames);
end


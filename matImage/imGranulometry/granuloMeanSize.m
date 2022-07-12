function gm = granuloMeanSize(tab, varargin)
% Compute geometric mean of granulometric curve.
%
%   GLMS = granuloMeanSize(TAB, XI)
%   Compute grey level mean size from a granulometric curve by using
%   geometric mean.
%   
%   GLMS = granuloMeanSize(TAB)
%   Assumes the size vector XI to be equal to 1:NS, where NS is the size of
%   the input array in the last non-singleton dimension.
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
%         14.7251
%
%   See also
%     imGranulometry, imGranulo, imGranuloByRegion, granuloMean
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2014-05-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRAE - Cepia Software Platform.


%% Process input arguments

% extract data
data = tab;
xi = [];

% in case data are provided as Table, extract numerical data
if isa(tab, 'Table')
    data = tab.Data;
    xi = str2num(char(tab.ColNames'))'; %#ok<ST2NM>
end

% process user-specified strel sizes
if ~isempty(varargin)
    if ~isempty(varargin{1})
        xi = varargin{1};
    end
    varargin(1) = [];
end

% find processing dimension
dim = find(size(data) > 1, 1, 'last');
if ~isempty(varargin)
    dim = varargin{1};
end


%% Initializations

% compute default xi in case none was specified
if isempty(xi)
    xi = 1:size(data, dim);
end

% check xi was correclty initialized
if size(xi, dim) ~= size(data, dim)
    newDim = ones(1, ndims(data));
    newDim (dim) = length(xi);
    xi = reshape(xi, newDim);
end


%% Main processing

% compute geometric mean
gm = exp(sum(bsxfun(@times, log(xi), data / 100), dim));

% if input is a table, create new data table with result
if isa(tab, 'Table')
    gm = Table(gm, {'gmean'}, tab.RowNames);
end


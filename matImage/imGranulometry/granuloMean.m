function grmean = granuloMean(tab, xi)
%GRANULOMEAN Compute arithmetic mean of granulometric curve(s)
%
%   GRMEAN = granuloMean(GR, XI)
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
% Created: 2017-08-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.

% extract data
data = tab;

% in case data are provided as Table, extract numerical data
if isa(tab, 'Table')
    data = tab.data;
end

% compute arithmetic mean
grmean = sum(bsxfun(@times, xi, data / 100), 2);



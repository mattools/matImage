function res = imQuantile(img, q, varargin)
%IMQUANTILE Computes value that threshold a given proportion of pixels
%
%   RES = imQuantile(IMG, Q)
%
%   Example
%     % compute the median value in an imag by two different ways
%     img = imread('cameraman.tif');
%     imQuantile(img, .5)
%     ans = 
%         144
%     imMedian(img)
%     ans = 
%         144
%
%   See also
%     imHistogram, imMedian
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-05-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


if q < 0 || q > 1
    error('Requires a quantile value between 0 and 1');
end

% compute cumulative histogram
[h, x] = imHistogram(img);
cs = cumsum(h);

% iterate for all quantiles to compute
res = zeros(size(q));
for i = 1:length(q)
    % find index of quantile
    qi = sum(h) * q(i);
    ind = find(cs > qi, 1, 'first');

    % coonvert to grey level
    res(i) = x(ind);
end
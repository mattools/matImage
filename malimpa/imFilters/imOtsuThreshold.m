function [bin value] = imOtsuThreshold(img, varargin)
%IMOTSUTHRESHOLD Threshold an image using Otsu method
%
%   BIN = imOtsuThreshold(IMG)
%   Automatically computes threshold for segmenting image IMG, based on
%   Otsu's method, and returns the binary result.
%
%   [BIN VALUE] = imOtsuThreshold(IMG)
%   Also returns the threshold value.
%
%   Example
%   % Compute 
%     img = imread('coins.png');
%     figure; imshow(img);
%     bin = imOtsuThreshold(img);
%     figure; imshow(bin);
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-01-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute normalized histogram
h = imHistogram(img, varargin{:})';
h = h / sum(h);

% number of gray levels
L = 256;

% just a vector of indices
li = 1:L;

% average value within image
mu = sum(h .* li);

% allocate memory
sigmab = zeros(1, L);
sigmaw = zeros(1, L);

for t = 1:256
    % linear indices for each class
    ind0 = 1:t;
    ind1 = t+1:L;
    
    % probabilities associated with each class
    p0 = sum(h(ind0));
    p1 = sum(h(ind1));
    
    % average value of each class
    mu0 = sum(h(ind0) .* li(ind0)) / p0;
    mu1 = sum(h(ind1) .* li(ind1)) / p1;
    
    % inner variance of each class
    var0 = sum( h(ind0) .* (li(ind0) - mu0) .^ 2) / p0;
    var1 = sum( h(ind1) .* (li(ind1) - mu1) .^ 2) / p1;
    
    % between (inter) class variance
    sigmab(t) = p0 * (mu0 - mu) ^ 2 + p1 * (mu1 - mu) ^ 2;
    
    % within (intra) class variance
    sigmaw(t) = p0 * var0 + p1 * var1;
end

% compute threshold value
[mini ind] = min(sigmaw); %#ok<ASGLU>
value = ind - 1;

% threshold image
bin = img > value;

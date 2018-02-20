function [value, segImg] = imOtsuThreshold(img, varargin)
%IMOTSUTHRESHOLD Threshold an image using Otsu method
%
%   VALUE = imOtsuThreshold(IMG)
%   Automatically computes threshold value for segmenting image IMG, based
%   on Otsu's method. The principle of Otsu method is to maximize the
%   inter-class variance, or equivalently, to minimize the sum of within
%   class variances.
%
%   ... = imOtsuThreshold(IMG, ROI)
%   Computes Otsu threshold value using only pixels in the specified region
%   of interest (ROI).
%   ROI is a binary image the same size as the input image.
%   
%   [VALUE, SEGIMG] = imOtsuThreshold(...)
%   Also returns the segmented image as a binary image containing TRUE for
%   foreground pixels.
%
%   Example
%     % Compute Otsu threshold value on coins image, and display resulting
%     % segmented image.
%     img = imread('coins.png');
%     figure; imshow(img);
%     thresh = imOtsuThreshold(img);
%     figure; imshow(img >= thresh);
%
%
%   See also
%   imHistogram, imMaxEntropyThreshold, imContours, watershed, graythresh
%

%
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-01-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute normalized histogram
[h, levels] = imHistogram(img, varargin{:});
h = h' / sum(h);

% number of gray levels
nLevels = length(levels);

% average value within whole image
mu = sum(h .* levels);

% vector of thresholds to consider (size is number of graylevels minus one)
threshInds = 2:nLevels;

% allocate memory
sigmab = zeros(1, nLevels - 1);
sigmaw = zeros(1, nLevels - 1);

for i = 1:length(threshInds)
    % index of current threshold in histogram values, from 2 to L
    t = threshInds(i);
    
    % linear indices for each class
    ind0 = 1:(t-1); % background
    ind1 = t:nLevels;     % foreground, including threshold
    
    % probabilities associated with each class
    p0 = sum(h(ind0));
    p1 = sum(h(ind1));
    
    % average value of each class
    mu0 = sum(h(ind0) .* levels(ind0)) / p0;
    mu1 = sum(h(ind1) .* levels(ind1)) / p1;
    
    % inner variance of each class
    var0 = sum( h(ind0) .* (levels(ind0) - mu0) .^ 2) / p0;
    var1 = sum( h(ind1) .* (levels(ind1) - mu1) .^ 2) / p1;
    
    % between (inter) class variance
    sigmab(i) = p0 * (mu0 - mu) ^ 2 + p1 * (mu1 - mu) ^ 2;
    
    % within (intra) class variance
    sigmaw(i) = p0 * var0 + p1 * var1;
end

% compute threshold value
[mini, ind] = min(sigmaw); %#ok<ASGLU>
value = levels(ind + 1);

if nargout > 1
    segImg = img >= value;
end
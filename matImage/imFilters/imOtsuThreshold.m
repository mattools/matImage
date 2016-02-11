function value = imOtsuThreshold(img, varargin)
%IMOTSUTHRESHOLD Threshold an image using Otsu method
%
%   VALUE = imOtsuThreshold(IMG)
%   Automatically computes threshold value for segmenting image IMG, based
%   on Otsu's method. The principle of Otsu method is to maximize the
%   inter-class variance, or equivalently, to minimize the sum of within
%   class variances.
%
%
%   ... = imOtsuThreshold(IMG, ROI)
%   Computes Otsu threshold value using only pixels in the specified region
%   of interest (ROI).
%   ROI is a binary image the same size as the input image.
%   
%
%   Example
%     % Compute Otsu threshodl value on coins image, and display segmented
%     % resulting image.
%     img = imread('coins.png');
%     figure; imshow(img);
%     thresh = imOtsuThreshold(img);
%     figure; imshow(img > thresh);
%
%   Note
%   Only implemented for grayscale image coded on uint8.
%
%
%   See also
%   imHistogram, imMaxEntropyThreshold, imContours, watershed
%

%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
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
[mini, ind] = min(sigmaw); %#ok<ASGLU>
value = ind - 1;


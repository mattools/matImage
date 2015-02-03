function res = imCannyEdgeDetector(img, varargin)
%IMCANNYEDGEDETECTOR Edge detection using Canny-Deriche method
%
%   EDG = imCannyEdgeDetector(IMG)
%   Compute an edge image from gray-scale image IMG.
%   Works for 2D grayscale images.
%
%   EDG = imCannyEdgeDetector(IMG, THRESHOLD)
%   specify low and high treshold values as a 1-by-2 row vector. Default
%   values are [0.05, 0.15], and corresponds to the fraction of gray scale
%   value of the gradient norm.
%
%   EDG = imCannyEdgeDetector(IMG, THRESHOLD, SIGMA)
%   Also specify the smoothing factor used to filter the image before
%   computing the gradient. Default value is 1.4.
%
%   Example
%     img = imread('peppers.png');
%     img = rgb2gray(img);
%     edg = imCannyEdgeDetector(img);
%     imshow(log(edg+1), []);
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-02-03,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

%% Process input options

% relative thresholds
relativeThresholds = [.05 .15];
if ~isemtpy(varargin)
    relativeThresholds = varargin{1};
    varargin(1) = [];
end

% width of gaussian kernel
sigma = 1.4;
if ~isemtpy(varargin)
    sigma = varargin{1};
end


%% Gradient computation

% gaussian filtering
filterSize = ceil(sigma) * 2 + 1;
imgf = imGaussianFilter(img, [filterSize filterSize], sigma);

% compute gradient components
[gx, gy] = imGradient(imgf);

% convert to polar representation
norm = hypot(gx, gy);
angle = atan2(gy, gx);

% compute octant corresponding to gradient main direction
% 0 -> vertical edge
% 1 -> upper-diagonal edge in image coord
% 2 -> horizontal edge
% 3 -> lower-diagonal edge in image coord
octant = mod(round(angle * 4 / pi) + 4, 4);


%% Non maxima suppression

% identify maxima in the direction perpendicular to the gradient
marker = false(size(img));
for i = 2:size(img, 1)-1
    for j = 2:size(img, 2)-1
        switch octant(i, j)
            case 0, marker(i,j) = norm(i,j) >= max(norm(i,j-1), norm(i,j+1));
            case 1, marker(i,j) = norm(i,j) >= max(norm(i+1,j+1), norm(i-1,j-1));
            case 2, marker(i,j) = norm(i,j) >= max(norm(i+1,j), norm(i-1,j));
            case 3, marker(i,j) = norm(i,j) >= max(norm(i+1,j-1), norm(i-1,j+1));
            otherwise
                warning(['Could not process octant number ' num2str(octant(i,j))]);
        end
    end
end

% remove non maxima pixels
norm = norm .* marker;


%% Hysteresis thresholding

% hysteresis thresholding
maxValue = max(norm(:));
bin1 = norm >= maxValue * relativeThresholds(2);
bin2 = norm >= maxValue * relativeThresholds(2);
rec = imreconstruct(bin1, bin2, 8);

% combine image of gradient norm with marker image of relevant maxima
res = norm .* rec;



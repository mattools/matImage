function [res, bg, rmse] = imNormalizeBackground(img, varargin)
%IMNORMALIZEBACKGROUND Normalize image by removing background estimate
%
%   IMG2 = imNormalizeBackground(IMG, BIN)
%   IMG is a grayscale image, and BIN is a basic segmentation of the
%   structure of interest. 
%   The function first computes an estimate of the background over the
%   whole image, then subtract this estimate from the original image, and
%   returns the result.
%
%   [IMG2 BG] = imNormalizeBackground(IMG)
%   Also returns the estimated background image.
%
%   [IMG2 BG RMSE] = imNormalizeBackground(IMG)
%   Also returns the root of the mean squared error. The lowest is the
%   best.
%
%   IMG2 = imNormalizeBackground(IMG)
%   Uses Otsu threshold for estimating first segmentation.
%
%   Example
%   % Segment rice grains using simple background normalisation
%     img = imread('rice.png');
%     img2 = imNormalizeBackground(img, img>150);
%     figure;
%     subplot(2,1,1); imHistogram(img); title('Original');
%     subplot(2,1,2); imHistogram(img2); title('Corrected');
%     % binarise corrected image
%     bin = imOtsuThreshold(img2);
%     figure;
%     imshow(imOverlay(img, imBoundary(bin)));
%
%   % Iterate the process of 1) segmenting and 2) estimating background
%     img = imread('rice.png');
%     bin1 = img > 150;
%     img2 = imNormalizeBackground(img, bin1);
%     bin2 = imOtsuThreshold(img2);
%     img3 = imNormalizeBackground(img, bin2);
%     figure; 
%     subplot(1, 2, 1); imshow(img); title('Original');
%     subplot(1, 2, 2); imshow(img3); title('Corrected');
%     figure; 
%     subplot(1, 2, 1); imHistogram(img); title('Original');
%     subplot(1, 2, 2); imHistogram(img3); title('Corrected');
%
%   % The same for coins
%     img = imread('coins.png');
%     img2 = imNormalizeBackground(img, img>100);
%     subplot(1, 2, 1); imshow(img); title('Original');
%     subplot(1, 2, 2); imshow(img2); title('Corrected');
%     % binarise corrected image
%     bin = imOtsuThreshold(img2);
%     figure;
%     imshow(imOverlay(img, imBoundary(bin)));
%
%   See also
%     imOtsuThreshold, imtophat
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-08-01,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


%% Pre-processing

% in case of color image, process each band separatly
if ndims(img) > 2 && size(img, 3) == 3 %#ok<ISMAT>
    [r, g, b] = imSplitBands(img);
    [r, bgR, rmseR] = imNormalizeBackground(r, varargin{:});
    [g, bgG, rmseG] = imNormalizeBackground(g, varargin{:});
    [b, bgB, rmseB] = imNormalizeBackground(b, varargin{:});
    res = imMergeBands(r, g, b);
    bg  = imMergeBands(bgR, bgG, bgB);
    rmse = [rmseR ; rmseG ; rmseB];
    return;
end

% if no segmentation is provided, try Otsu
if nargin < 2
    bin = imOtsuThreshold(img);
else
    bin = varargin{1};
end

% keep a small gard area around structure
se = ones(3, 3);
bin2 = imdilate(bin, se);


%% Background model fitting

% location of background pixels
[y, x] = find(~bin2);

% Compute the problem matrix for polynomial fitting
n = length(x);
A = [x.^2 x.*y y.^2 ...     % degree 2
    x y ...                 % degree 1
    ones(n, 1)];            % constant

% estimate parameters
theta = A \ double(img(~bin2));

% compute global error
rmse = sqrt(mean((A * theta - double(img(~bin2))).^2));

% clean up memory
clear A;
clear x;
clear y;


%% Background estimation

% generate whole image grid
lx = 1:size(img, 2);
ly = 1:size(img, 1);
[x, y] = meshgrid(lx, ly);

% compute the matrix, with all positions
X = [x(:).^2 x(:).*y(:) y(:).^2 x(:) y(:) ones(size(x(:)))];

% compute background estimate
dim = [size(img, 1), size(img, 2)];
bg = reshape(double(X * theta), dim);

% compute "normalized" image (remove background)
moy = mean(img(~bin2));
res = uint8(double(img) - bg + moy);

% convert bg to uint8
bg = uint8(bg);


function [res, bgFit, rmse] = imNormalizeBackground(img, varargin)
%IMNORMALIZEBACKGROUND Normalize image by removing background estimate.
%
%   IMG2 = imNormalizeBackground(IMG, BGMASK)
%   IMG is a grayscale image, and BIN is a basic segmentation of the
%   structure of interest. 
%   The function first computes an estimate of the background over the
%   whole image, then subtract this estimate from the original image, and
%   returns the result.
%
%   IMG2 = imNormalizeBackground(IMG)
%   Estimates the background mask by using Otsu threshold on the original
%   image, and uses the resulting binary mask for background fitting.
%
%   [IMG2, BGFIT] = imNormalizeBackground(IMG)
%   Also returns the estimated background image.
%
%   [IMG2, BGFIT, RMSE] = imNormalizeBackground(IMG, ...)
%   Also returns the root of the mean squared error. The lowest is the
%   best.
%
%   IMG2 = imNormalizeBackground(, 'maxDegree', MAXDEG)
%   Specifies the maximum degree of polynomials individual coefficients.
%   Supported values are 2 and 3.
%
%
%   Examples
%   % Segment rice grains using simple background normalization
%     img = imread('rice.png');
%     img2 = imNormalizeBackground(img, img>150);
%     figure;
%     subplot(2,1,1); imHistogram(img); title('Original');
%     subplot(2,1,2); imHistogram(img2); title('Corrected');
%     % binarize corrected image
%     bin = img2 > imOtsuThreshold(img2);
%     figure;
%     imshow(imOverlay(img, imBoundary(bin)));
%
%   % Iterate the process of 1) segmenting and 2) estimating background
%     img = imread('rice.png');
%     bin1 = img > 150;
%     img2 = imNormalizeBackground(img, bin1);
%     bin2 = img2 > imOtsuThreshold(img2);
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
%     % binarize corrected image
%     bin = mg2 > imOtsuThreshold(img2);
%     figure;
%     imshow(imOverlay(img, imBoundary(bin)));
%
%   See also
%     imOtsuThreshold, imtophat
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2012-08-01,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2026 INRAE.


%% Case of color image

% in case of color image, process each band separately
if ndims(img) > 2 && size(img, 3) == 3 %#ok<ISMAT>
    [r, g, b] = imSplitBands(img);
    [r, bgR, rmseR] = imNormalizeBackground(r, varargin{:});
    [g, bgG, rmseG] = imNormalizeBackground(g, varargin{:});
    [b, bgB, rmseB] = imNormalizeBackground(b, varargin{:});
    res = imMergeBands(r, g, b);
    bgFit  = imMergeBands(bgR, bgG, bgB);
    rmse = [rmseR ; rmseG ; rmseB];
    return;
end


%% Parse input arguments

% if no segmentation is provided, try Otsu
if nargin < 2
    bgmask = img < imOtsuThreshold(img);
else
    bgmask = varargin{1};
    varargin(1) = [];
end

% retrieve optional parameters (max degree)
maxDegree = 2;
if length(varargin) > 1
    pname = varargin{1};
    if strcmpi(pname, 'maxDegree')
        maxDegree = varargin{2};
        if ~isnumeric(maxDegree) || ~isscalar(maxDegree)
            error('max degree must be a numeric scalar');
        end
    else
        errro('Unknown parameter name: %s', pname);
    end
end


%% Pre-processing

% keep a small guard area around structure
se = ones(3, 3);
bgmask2 = imerode(bgmask, se);


%% Background model fitting

% location of background pixels
[y, x] = find(bgmask2);

% reduce value range
dims = [size(img, 1), size(img, 2)];
x = (x - dims(1)/2) / (dims(1)/2);
y = (y - dims(2)/2) / (dims(2)/2);

% Compute the problem matrix for polynomial fitting
n = length(x);
switch maxDegree
    case 2
        A = [x.^2 x.*y y.^2 ...     % degree 2
            x y ...                 % degree 1
            ones(n, 1)];            % constant
    case 3
        A = [x.^3 x.^2.*y x.*y.^2 y.^3 ...  % degree 3
            x.^2 x.*y y.^2 ...      % degree 2
            x y ...                 % degree 1
            ones(n, 1)];            % constant
    case 4
        A = [...
            x.^4 x.^3.*y x.^2.*y.^2 x.*y.^3 y.^4 ...  % degree 4
            x.^3 x.^2.*y x.*y.^2 y.^3 ...  % degree 3
            x.^2 x.*y y.^2 ...      % degree 2
            x y ...                 % degree 1
            ones(n, 1)];            % constant
    otherwise
        error('Unable to process case of polynomial degree %d', maxDegree);
end

% estimate parameters
theta = A \ double(img(bgmask2));

% compute global error
rmse = sqrt(mean((A * theta - double(img(bgmask2))).^2));

% clean up memory
clear A;
clear x;
clear y;


%% Background estimation

% generate whole image grid
lx = 1:size(img, 2);
ly = 1:size(img, 1);
[x, y] = meshgrid(lx, ly);
x = (x - dims(1)/2) / (dims(1)/2);
y = (y - dims(2)/2) / (dims(2)/2);

% compute the matrix, with all positions
switch maxDegree
    case 2
        X = [x(:).^2 x(:).*y(:) y(:).^2 x(:) y(:) ones(size(x(:)))];
    case 3
        X = [x(:).^3 x(:).^2.*y(:) x(:).*y(:).^2 y(:).^3 ...
            x(:).^2 x(:).*y(:) y(:).^2 ...
            x(:) y(:) ones(size(x(:)))];
    case 4
        X = [...
            x(:).^4 x(:).^3.*y(:) x(:).^2.*y(:).^2 x(:).*y(:).^3 y(:).^4 ...
            x(:).^3 x(:).^2.*y(:) x(:).*y(:).^2 y(:).^3 ...
            x(:).^2 x(:).*y(:) y(:).^2 ...
            x(:) y(:) ones(size(x(:)))];
    otherwise
end

% compute background estimate
bgFit = reshape(double(X * theta), dims);

% compute "normalized" image (remove background)
moy = mean(img(bgmask2));
res = cast(double(img) - bgFit + moy, like=img);

% cast background image to class of original image
bgFit = cast(bgFit, like=img);


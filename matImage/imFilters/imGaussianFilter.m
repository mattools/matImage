function res = imGaussianFilter(img, kernelSize, sigma, varargin)
%IMGAUSSIANFILTER Apply gaussian filter to an image, using separability
%
%   IMGF = imGaussianFilter(IMG, SIZE, SIGMA)
%   Applies gaussian filtering on input image IMG with kernel size defined
%   by SIZE and SIGMA.
%   IMG is the input image, 
%   SIZE is the size of the convolution kernel, either as a scalar, or as a
%   1-by-ND row vector containging size in the X, Y, and eventually z
%   direction. Default is 3.
%   SIGMA is the width of the kernel, either as a scalar (the same sigma
%   will be used in each direction), or as a row vector containing sigmax,
%   sigmay, and eventually sigmaz. Default is SIZE/2.
%
%   IMGF = imGaussianFilter(IMG, SIZE, SIGMA, OPTIONS)
%   Apply the same kind of options than for imfilter.
%
%   The function works for 2D or 3D images, for grayscale or color images.
%   In case of color images, the filtering is repeated for each channel of
%   the image.
%
%
%   Example
%     % Gaussian filter of a grayscale image
%     img = imread('cameraman.tif');
%     imgf = imGaussianFilter(img, 11, 4);
%     % is equivalent, but is in general faster, that:
%     imgf2 = imfilter(img, fspecial('gaussian', 11, 4));
%
%     % Using anisotropic filtering
%     img = imread('cameraman.tif');
%     imgf = imGaussianFilter(img, [13 5], [4 2]);
%     figure; subplot(121); imshow(img); subplot(122); imshow(imgf);
% 
%     % Gaussian filtering of a color image
%     img = imread('peppers.png');
%     imgf = imGaussianFilter(img, [5 5], [2 2]);
%     imshow(imgf)
%
%   Note that there can be slight differences due to rounding effects. To
%   minimize them, it is possible to use something like:
%   imgf3 = uint8(imGaussianFilter(single(img), 11, 4));
%
%   See also
%   gaussianKernel3d, imfilter, fspecial
%
%   Requires
%   imfilter in the image processing toolbox
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-11-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Dispatch processing in case of color images

% compute image dimension
nd = ndims(img);

% case of color images

if isColorImage(img)
    res = img;
    if nd == 3
        for i = 1:3
            % filter each channel of the 2D image
            res(:,:,i) = imGaussianFilter(img(:,:,i), ...
                kernelSize, sigma, varargin{:});
        end
    else
        for i = 1:3
            % filter each channel of the 3D image
            res(:,:,i,:) = imGaussianFilter(img(:,:,i,:), ...
                kernelSize, sigma, varargin{:});
        end
    end
    return;
    
end


%% Process input arguments

% process kernel size
if nargin < 2
    kernelSize = 3;
end
if length(kernelSize) == 1
    kernelSize = repmat(kernelSize, 1, nd);
end

% process filter sigma
if nargin < 3
    sigma = kernelSize / 2;
end
if length(sigma) == 1
    sigma = repmat(sigma, 1, nd);
end


%% Main processing

% init result
res = img;

% process each direction
for i = 1:nd
    % compute spatial reference
    refSize = (kernelSize(i) - 1) / 2;
    s0 = floor(refSize);
    s1 = ceil(refSize);
    lx = -s0:s1;
    
    % compute normalized kernel
    sigma2 = 2 * sigma(i) .^ 2;
    h = exp(-(lx.^2 / sigma2));
    h = h / sum(h);
    
    % reshape
    newDim = [ones(1, i-1) kernelSize(i) ones(1, nd-i)];
    newDim = newDim([2 1 3:nd]);
    
    h = reshape(h, newDim);
    
    % apply filtering along one direction
    res = imfilter(res, h, varargin{:});
end


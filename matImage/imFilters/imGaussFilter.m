function res = imGaussFilter(img, kernelSize, sigma, varargin)
%IMGAUSSFILTER Apply gaussian filter to an image, using separability
%
%   Deprecated. Use imGaussianFilter instead.
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

warning('malimpa:deprecated', ...
    'imGaussFilter is deprecated, use imGaussianFitler instead');

%% Dispatch processing in case of color images

% compute image dimension
nd = ndims(img);

% case of color images
if size(img, 3)==3 && size(img,1)~=3 && size(img, 2)~=3
    res = img;
    if nd==3
        for i=1:3
            % filter each channel of the 2D image
            res(:,:,i) = imGaussFilter(img(:,:,i), ...
                kernelSize, sigma, varargin{:});
        end
    else
        for i=1:3
            % filter each channel of the 3D image
            res(:,:,i,:) = imGaussFilter(img(:,:,i,:), ...
                kernelSize, sigma, varargin{:});
        end
    end
    return;
    
end


%% Process input arguments

% process kernel size
if nargin<2
    kernelSize = 3;
end
if length(kernelSize)==1
    kernelSize = repmat(kernelSize, 1, nd);
end

% process filter sigma
if nargin<3
    sigma = 3;
end
if length(sigma)==1
    sigma = repmat(sigma, 1, nd);
end


%% Main processing

% init result
res = img;

% process each direction
for i=1:nd
    % compute spatial reference
    refSize = (kernelSize(i) - 1) / 2;
    s0 = floor(refSize);
    s1 = ceil(refSize);
    lx = -s0:s1;
    
    % compute normalized kernel
    sigma2 = 2*sigma(i).^2;
    h = exp(-(lx.^2 / sigma2));
    h = h/sum(h);
    
    % reshape
    newDim = [ones(1, i-1) kernelSize(i) ones(1, nd-i)];
    newDim = newDim([2 1 3:nd]);
    
    h = reshape(h, newDim);
    
    % apply filtering along one direction
    res = imfilter(res, h, varargin{:});
end


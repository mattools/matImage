function varargout = gaussianKernel3d(size, sigma, varargin)
%GAUSSIANKERNEL3D Create a 3D Gaussian kernel for image filtering
%
%   K = gaussianKernel3d(SIZE, SIGMA)
%   SIZE is either a scalar or a 1-by-3 row vector. SIGMA is the standard
%   deviation of gaussian function. SIZE must contain odd values. SIZE and
%   SIGMA vectors are given in XYZ order (not the matlab indexing order).
%   The kernel is normalised such that the sum of its values equals 1.
%
%   [KX KY KZ] = gaussianKernel3d(SIZE, SIGMA)
%   Returns the elementary linear kernels for each direction of the 3D
%   image. This can be used for decomposing the 3D Gaussian filtering. Each
%   kernel is normalised such that the sum of its values equals 1. Note
%   that the function 'imGaussianFilter' encapsulates the whole processing. 
%
%   Examples
%     % Basic 3D kernel:
%     K0 = gaussianKernel3d(3, 2);
%
%     % Larger kernel with non equal sizes:
%     K = gaussianKernel3d([7 7 5], 3);
%   
%     % Create the same kernel using separate linear kernels:
%     [KX KY KZ] = gaussianKernel3d([7 7 5], 3);
%     K2 = bsxfun(@times, KY * KX, KZ);   % create 3D kernel
%     sum(abs(K(:) - K2(:)) > 1e-15)      % number of significant differences
%     ans =
%         0
%
%   Note: it is faster to use the function 'imGaussianFilter', that uses
%   separability of the Gaussian kernel.
%   
%   See also
%   imGaussianFilter, fspecial, imfilter
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2013-02-25 add possibility to get separated kernels


%% Process input

% ensure size is a vector of length 3
if length(size) == 1
    size = [size size size];
end

% ensure sigma is a vector of length 3
if length(sigma) == 1
    sigma = [sigma sigma sigma];
end


%% Pre-processing

% create basis along each direction
nx = round((size(1)-1) / 2);
ny = round((size(2)-1) / 2);
nz = round((size(3)-1) / 2);

% compute reference for each axis
lx = -nx:nx;
ly = -ny:ny;
lz = -nz:nz;

% normalise kernel width
sigma2 = sigma .* sigma;
sx2 = sigma2(1) * .5;
sy2 = sigma2(2) * .5;
sz2 = sigma2(3) * .5;


%% Compute kernel(s)

if nargout == 1
    % Computes a single 3D kernel
    
    % create 3D grid
    [x, y, z] = meshgrid(lx, ly, lz);
    
    % compute gaussian function for each point of the grid
    h = exp(-(x.^2 / sx2)) .* exp(-(y.^2 / sy2)) .* exp(-(z.^2 / sz2));
    
    % normalize intensity
    h = h / (sum(h(:)));

    varargout = {h};
    
else
    % computes kernel for each direction, for applying separability
    hx = reshape(exp(-(lx.^2 / sx2)), [1 length(lx) 1]);
    hy = reshape(exp(-(ly.^2 / sy2)), [length(ly) 1 1]);
    hz = reshape(exp(-(lz.^2 / sz2)), [1 1 length(lz)]);

    % normalize intensities
    hx = hx / sum(hx(:));
    hy = hy / sum(hy(:));
    hz = hz / sum(hz(:));
    
    varargout = {hx, hy, hz};

end
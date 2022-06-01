function [kx, ky, kz] = gradientKernels3d(sigma)
% Create kernels for computing gradient within 3D images.
%
%   KX = gradientKernels3d(SIGMA)
%   [KX, KY, KZ] = gradientKernels3d(SIGMA)
%   Generates the gradient kernel(s) used for computing gradients within 3D
%   images.
%   This is a low-level function that is called by the functions that
%   compute gradients.
%   
%
%   Example
%   [kx, ky, kz] = gradientKernels3d(2);
%
%   See also
%     gradientKernels, imGradientFilter, orientedGaussianKernel
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.

if sigma == 0
    % Default 3D case: normalization of 2 classical sobel matrices
    base = [1 2 1]' * [1 2 1];
    base = base / sum(base(:))/2;
    kx = permute(cat(3, base, zeros(3, 3), -base), [2 3 1]);
    
else
    % compute size according to sigma
    Nx = ceil((3*sigma));
    lx = -Nx:Nx;
    % smoothing vectors
    ky = exp(-((lx / sigma) .^2) * .5);
    kz = permute(ky, [3 1 2]);
    % derivative vector
    kx = -(lx / sigma) .* ky;
    
    % combine vectors into a 3D (smoothed) derivation matrix
    n = length(lx);
    tmp = zeros(n, n , n);
    for i = 1:n
        tmp(:,:,i) = kz(i) * ky' * kx;
    end
    kx = tmp;
    
    % normalize
    kx = kx / sum(kx(kx > 0));
end

% optional kernel for gradient in Y-direction
if nargout > 1
    ky = permute(kx, [2 3 1]);
    kz = permute(kx, [3 1 2]);
end

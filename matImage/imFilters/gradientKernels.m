function [kx, ky] = gradientKernels(sigma)
% Create kernels for computing gradient within 2D images.
%
%   KX = gradientKernels(SIGMA)
%   [KX, KY] = gradientKernels(SIGMA)
%   Generates the gradient kernel(s) used for computing gradients within 2D
%   images.
%   This is a low-level function that is called by the functions that
%   compute gradients.
%   
%
%   Example
%   [kx, ky] = gradientKernels(2);
%
%   See also
%     imGradient, imGradientFilter, orientedGaussianKernel
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.

if nargin == 0 || sigma == 0
    % Default case: normalised sobel matrix
    kx = fspecial('sobel')' / 8;
    
else
    % compute size according to sigma
    Nx = ceil((3*sigma));
    lx = -Nx:Nx;
    ky = exp(-((lx / sigma) .^2) * .5);
    kx = -(lx / sigma) .* ky;
    kx = ky' * kx;
    kx = kx / sum(kx(kx > 0));
end

% optional kernel for gradient in Y-direction
if nargout > 1
    ky = kx';
end

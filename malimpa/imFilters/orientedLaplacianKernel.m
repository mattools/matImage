function h = orientedLaplacianKernel(size, sigma, theta)
%ORIENTEDLAPLACIANKERNEL Oriented Laplacian kernel for directional filtering
%
%   H = orientedLaplacianKernel(SIZE, SIGMA, THETA)
%   THETA is in degrees, SIGMA is either a scalar or a 1-by-2 row vector.
%   (first value corresponds to the length, second to the width). 
%
%   Example
%     lap = orientedLaplacianKernel([21 21], [5 3], 20);
%     surf(lap);
%
%   See also
%     imDirectionalFilter, orientedGaussianKernel, imfilter

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-05-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% ensure size is a vector
if length(size) == 1
    size = [size size];
end

% ensure sigma is a vector
if length(sigma) == 1
    sigma = [3*sigma sigma];
end

% compute reference for each axis
nx = round((size(1) - 1) / 2);
ny = round((size(2) - 1) / 2);

% create 3D grid
[x y] = meshgrid(-nx:nx, -ny:ny);

% precompute angles
cot = cosd(-theta);
sit = sind(-theta);

% Apply rotation by -theta
x2 = x * cot - y * sit;
y2 = x * sit + y * cot;

% compute gaussian kernel in current direction
h1 = exp(-(x2 / sigma(1)).^2 / 2);

% compute laplacian in orthogonal direction
h2 = (1 - (y2 / sigma(2)) .^2) .* exp(-(y2 / sigma(2)) .^2 / 2);

% compute gaussian function for each point of the grid
h = h1 .* h2;

% normalize intensities
h = h / (sum(h(h>0)));


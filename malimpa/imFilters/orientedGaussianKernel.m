function h = orientedGaussianKernel(size, sigma, theta)
%ORIENTEDGAUSSIANKERNEL Oriented Gaussian kernel for directional filtering
%
%   H = orientedGaussianKernel(SIZE, SIGMA, THETA)
%   THETA is in degrees.
%
%   Example
%     orientedGaussianKernel
%
%   See also
%     imDirectionalFilter, orientedLaplacianKernel, imfilter

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-12-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% ensure size is a vector
if length(size) == 1
    size = [size size];
end

% ensure sigma is a vector
if length(sigma) == 1
    sigma = [sigma sigma];
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

% compute gaussian function for each point of the grid
sx2 = 2 * sigma(1) ^ 2;
sy2 = 2 * sigma(2) ^ 2;
h = exp(-(x2.^2 / sx2)) .* exp(-(y2.^2 / sy2));

% normalize intensities
h = h / (sum(h(:)));


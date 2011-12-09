function h = gaussianKernel3d(size, sigma)
%GAUSSIANKERNEL3D Create a 3D gaussian kernel for image filtering
%
%   K = gaussianKernel3d(SIZE, SIGMA)
%   SIZE is either a scalar or a 1-by-3 row vector. SIGMA is the standard
%   deviation of gaussian function.
%
%   Example
%   K = gaussianKernel3d(3, 2);
%   K = gaussianKernel3d([7 7 5], 3);
%
%   Note: it is faster to use the function 'imGaussFilter', that uses
%   separability of the gaussian kernel.
%   
%   See also
%   imGaussFilter, fspecial, imfilter
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


% ensure size is a vector
if length(size)==1
    size = [size size size];
end

% ensure sigma is a vector
if length(sigma)==1
    sigma = [sigma sigma sigma];
end

% compute reference for each axis
nx = round((size(1)-1)/2);
ny = round((size(2)-1)/2);
nz = round((size(3)-1)/2);

% create 3D grid
[x y z] = meshgrid(-nx:nx, -ny:ny, -nz:nz);

% compute gaussian function for each point of the grid
sigma2 = sigma.*sigma;

%h = exp(-(x.^2 + y.^2 + z.^2)/(2*sigma2));
sx2 = sigma2(1);
sy2 = sigma2(2);
sz2 = sigma2(3);
h = exp(-(x.^2 / 2/sx2)) .* exp(-(y.^2 / 2/sy2)) .* exp(-(z.^2 / 2/sz2));

% normalize intensity
h = h/(sum(h(:)));


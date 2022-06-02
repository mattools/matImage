function grads = imLocalGradient(img, pos, sigma)
% Compute gradient for chosen locations within image.
%
%   The aim of this function is to compute gradient within images at
%   specified positions without requiring to compute the whole gradient
%   image. This greatly saves memory when image is large and number of
%   position is small.
%
%   GRAD = imLocalGradient(IMG, POS)
%   Evaluates the gradient within the image IMG at the specified position
%   POS. The result GRAD is a 1-by-2 row vector containing gradient along
%   the x and y diections.
%   If POS is a N-by-2 array of coordinates, the result is a N-by-2 array
%   of vector components.
%
%   GRAD = imLocalGradient(IMG, POS, SIGMA)
%   Also specifies the sigma parameter for computing gradient.
%
%   Example
%     imLocalGradient
%
%   See also
%     imGradientFilter, imLaplacian, gradientKernels, gradientKernels3d
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.


%% Input arguments

% process optional inputs
if nargin == 2
    sigma = 2;
end

% compute output dimensions from input arguments
nPos = size(pos, 1);
nd = ndims(img);

% allocate memory for result
grads = zeros(nPos, nd);


%% Main processing

if nd == 2
    % create gradient kernels
    [kx, ky] = gradientKernels(sigma);
    
    % computation will be performed using point-wise multiplication, so we need
    % to use the symetric kernels
    kx = kx(end:-1:1, end:-1:1);
    ky = ky(end:-1:1, end:-1:1);
    
    % size of the kernels along each dimension
    ks1 = size(kx, 1);
    ks2 = size(kx, 2);
    kr1 = floor((ks1 - 1) / 2);
    kr2 = floor((ks2 - 1) / 2);
    
    % iterate over position
    for iPos = 1:nPos
        % position in array indexing (position is x,y indexing)
        pos1 = round(pos(iPos, 2));
        pos2 = round(pos(iPos, 1));
        
        % clamp indexing of sub-image
        inds1 = max(min(pos1-kr1:pos1+kr1, size(img, 1)), 1);
        inds2 = max(min(pos2-kr2:pos2+kr2, size(img, 2)), 1);
        
        % extract region to process (using replication of borders if necessary)
        sub = double(img(inds1, inds2));
        
        % evaluate gradient by multiplying with gradient kernels
        gx = sub .* kx;
        gy = sub .* ky;
        grads(iPos, :) = [sum(gx(:)) sum(gy(:))];
    end
    
else
    % create gradient kernels
    [kx, ky, kz] = gradientKernels3d(sigma);
    
    % computation will be performed using point-wise multiplication, so we need
    % to use the symetric kernels
    kx = kx(end:-1:1, end:-1:1, end:-1:1);
    ky = ky(end:-1:1, end:-1:1, end:-1:1);
    kz = kz(end:-1:1, end:-1:1, end:-1:1);
    
    % size of the kernels along each dimension
    ks1 = size(kx, 1);
    ks2 = size(kx, 2);
    ks3 = size(kx, 3);
    kr1 = floor((ks1 - 1) / 2);
    kr2 = floor((ks2 - 1) / 2);
    kr3 = floor((ks3 - 1) / 2);
    
    % iterate over position
    for iPos = 1:nPos
        % position in array indexing (position is x,y indexing)
        pos1 = round(pos(iPos, 2));
        pos2 = round(pos(iPos, 1));
        pos3 = round(pos(iPos, 3));
        
        % clamp indexing of sub-image
        inds1 = max(min(pos1-kr1:pos1+kr1, size(img, 1)), 1);
        inds2 = max(min(pos2-kr2:pos2+kr2, size(img, 2)), 1);
        inds3 = max(min(pos3-kr3:pos3+kr3, size(img, 3)), 1);
        
        % extract region to process (using replication of borders if necessary)
        sub = double(img(inds1, inds2, inds3));
        
        % evaluate gradient by multiplying with gradient kernels
        gx = sub .* kx;
        gy = sub .* ky;
        gz = sub .* kz;
        grads(iPos, :) = [sum(gx(:)) sum(gy(:)) sum(gz(:))];
    end        
end

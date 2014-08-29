function varargout = imHessian(img, sigma, varargin)
%IMHESSIAN Compute coefficients of Hessian matrix for each pixel
%
%   For 2D images:
%   [DXX, DXY, DYY] = imHessian(IMG, SIGMA)
%   For 3D images:
%   [DXX, DYY, DZZ, DXY, DXZ, DYZ] = imHessian(IMG, SIGMA)
%
%   Example
%     % compute Hessian coefficients on coins image
%     img = imread('coins.png');
%     [Dxx, Dxy, Dyy] = imHessian(double(img), 2);
%     figure; subplot(2, 2, 1); imshow(img);
%     subplot(2, 2, 2); imshow(Dxx, [-60 60]);
%     subplot(2, 2, 3); imshow(Dyy, [-60 60]);
%     subplot(2, 2, 4); imshow(Dxy, [-60 60]);
%
%   See also
%     imGradient, imLaplacian, imEigenValues, imfilter

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% use default sigma
if nargin < 2
    sigma = 1; 
end


if ndims(img) == 2 %#ok<ISMAT>
    % Compute kernel coordinates
    nx = round(sigma * 3);
    [x, y] = meshgrid(-nx:nx, -nx:nx);

    % Create kernels for 2nd derivatives filters
    smoothing = exp( -(x.^2 + y.^2) / (2*sigma^2)) / (2*pi*sigma^4);
    hxx = (x.^2/sigma^2 - 1) .* smoothing;
    hxy = (x .* y)           .* smoothing;
    hyy = hxx';

    % compute second derivatives
    Dxx = imfilter(img, hxx, varargin{:});
    Dxy = imfilter(img, hxy, varargin{:});
    Dyy = imfilter(img, hyy, varargin{:});
    varargout = {Dxx, Dxy, Dyy};
    
elseif ndims(img) == 3
    % Use smoothing, and succession of finite differences
    if sigma ~= 0
        img = imGaussianFilter(img, sigma);
    end
    
    Dx = gradient3d(img, 'x');
    Dy = gradient3d(img, 'y');
    Dz = gradient3d(img, 'z');
    Dxx = gradient3d(Dx, 'x');
    Dyy = gradient3d(Dy, 'y');
    Dzz = gradient3d(Dz, 'z');
    Dxy = gradient3d(Dx, 'y');
    Dxz = gradient3d(Dx, 'z');
    Dyz = gradient3d(Dy, 'z');
    
    varargout = {Dxx, Dyy, Dzz, Dxy, Dxz, Dyz};

else
    error('Requires a 2D or 3D image');
end

function grad = gradient3d(img, dir)

grad = img;
switch dir
    case {1, 'y'}
        grad(1,:,:) = img(2,:,:) - img(1,:,:);
        grad(2:end-1,:,:) = img(3:end,:,:) - img(1:end-2,:,:);
        grad(end,:,:) = img(end,:,:) - img(end-1,:,:);
    case {2, 'x'}
        grad(:,1,:) = img(:,2,:) - img(:,1,:);
        grad(:,2:end-1,:) = img(:,3:end,:) - img(:,1:end-2,:);
        grad(:,end,:) = img(:,end,:) - img(:,end-1,:);
    case {3, 'z'}
        grad(:,:,1) = img(:,:,2) - img(:,:,1);
        grad(:,:,2:end-1) = img(:,:,3:end) - img(:,:,1:end-2);
        grad(:,:,end) = img(:,:,end) - img(:,:,end-1);
end
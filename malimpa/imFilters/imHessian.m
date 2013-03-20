function [gxx gxy gyy] = imHessian(img, varargin)
%IMHESSIAN Compute coefficients of Hessian matrix for each pixel
%
%   [GXX GXY GYY] = imHessian(IMG, SIGMA)
%
%   Example
%     % compute Hessian coefficients on coins image
%     img = imread('coins.png');
%     [gxx gxy gyy] = imHessian(img, 2);
%     figure; subplot(2, 2, 1); imshow(img);
%     subplot(2, 2, 2); imshow(gxx, [-60 60]);
%     subplot(2, 2, 3); imshow(gyy, [-60 60]);
%     subplot(2, 2, 4); imshow(gxy, [-60 60]);
%
%   See also
%     imGradient, imLaplacian, imEigenValues, imfilter
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% use default sigma
if nargin < 2
    sigma = 1; 
end

% Compute kernel coordinates
nx = round(sigma * 3);
[x y] = meshgrid(-nx:nx, -nx:nx);

% Create kernels for 2nd derivatives filters
hxx = (x.^2/sigma^2 - 1) .* exp( -(x.^2 + y.^2) / (2*sigma^2)) / (2*pi*sigma^4);
hxy = (x .* y)           .* exp( -(x.^2 + y.^2) / (2*sigma^2)) / (2*pi*sigma^6);
hyy = hxx';

% compute second derivatives
gxx = imfilter(img, hxx, varargin{:});
gxy = imfilter(img, hxy, varargin{:});
gyy = imfilter(img, hyy, varargin{:});

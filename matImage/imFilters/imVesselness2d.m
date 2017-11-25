function [V, B, S] = imVesselness2d(img, varargin)
%IMVESSELNESS2D Vesselness of cuvilinear structures from Frangi paper
%
%   V = imVesselness2d(IMG)
%   Apply vesselness filter to grayscale or intensity image IMG. 
%
%   [V, B, S] = imVesselness2d(IMG)
%   Also return the "Blobness" and "Structureness" arrays, as defined by
%   Frangi.
%
%   ... = imVesselness2d(IMG, SIGMA)
%   Specifies the scale of the curvilinear structures to enhance. If SIMGA
%   is an array, returns an array of images with dimensions M-by-N-by-P,
%   where M and N are size of image, and P is size of SIGMA array.
%
%   Example
%     img = imread('coins.png');
%     bnd = imdilate(img, ones(3,3)) - imerode(img, ones(3,3));
%     V = imVesselness2d(bnd);
%     figure;
%     subplot(1, 2, 1); imshow(bnd);
%     subplot(1, 2, 2); imshow(V);
%
%
%   See also
%     imHessian, imEigenValues, imGradientFilter
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2014-08-18,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% some default values
sigma = 1;
beta = .5;
c = 5;

% parse input arguments
if ~isempty(varargin)
    sigma = varargin{1};
    varargin(1) = [];
end
if ~isempty(varargin)
    beta = varargin{1};
    varargin(1) = [];
end
if ~isempty(varargin)
    c = varargin{1};    
end

% process multi-scale version of the filter
if length(sigma) > 1
    nSigmas = length(sigma);
    dim = size(img);
    V = zeros([dim nSigmas]);
    B = zeros([dim nSigmas]);
    S = zeros([dim nSigmas]);
    
    for i = 1:nSigmas
        [V(:,:,i), B(:,:,i), S(:,:,i)] = imVesselness2d(img, sigma(i), beta, c);
    end
    
    return;
end

% compute second derivatives
[gxx, gxy, gyy] = imHessian(double(img), sigma);

% compute eigen values of hessian matrix. 
% They are sorted such that |lambda1| < |lambda2|
s2 = sigma ^ 2;
[lambda1, lambda2] = imEigenValues(gxx*s2, gxy*s2, gyy*s2);

% combine eigen values to compute so-called "blobness" and "structureness"
B = lambda1 ./ lambda2;
S = hypot(lambda1, lambda2);

% restrict analysis to bright structures over dark background
mask = lambda2 <= 0;

% compute vesselness using eq 15 of Frangi paper
V = exp(-B.^2 / 2 / beta^2) .* (1 - exp(-S.^2 / 2 / c^2)) .* mask;

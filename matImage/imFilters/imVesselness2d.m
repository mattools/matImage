function V = imVesselness2d(img, varargin)
%IMVESSELNESS2D Vesselness of cuvilinear structures from Frangi paper
%
%   VESSELNESS = imVesselness2d(IMG)
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
% e-mail: david.legland@nantes.inra.fr
% Created: 2014-08-18,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% some default values
sigma = 1;
beta = .5;
c = .5;

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

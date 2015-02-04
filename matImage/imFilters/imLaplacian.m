function lap = imLaplacian(img, varargin)
%IMLAPLACIAN  Discrete Laplacian of an image
%
%   LAP = imLaplacian(IMG)
%
%   Example
%     % Laplacian of a smoothed circle image
%     img  = imread('circles.png');
%     imgf = imGaussianFilter(double(img));
%     lap = imLaplacian(imgf);
%     imshow(lap, [-.3 .3]);
%     colormap jet
%
%   See also
%   imGaussianFilter, imMorphoLaplacian
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-01-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% first order gradient
[gx, gy] = imGradient(img, varargin{:});

% second order gradient
[gx2, gxy] = imGradient(gx, varargin{:}); %#ok<ASGLU>
[gxy, gy2] = imGradient(gy, varargin{:}); %#ok<ASGLU>

lap = gx2 + gy2;

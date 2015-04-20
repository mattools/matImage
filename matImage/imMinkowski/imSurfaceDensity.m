function [sd, labels] = imSurfaceDensity(img, varargin)
%IMSURFACEDENSITY Surface area density of a 3D binary structure
%
%   Sv = imSurfaceDensity(IMG)
%   Estimate surface area density (ratio of surface area over volume of the
%   region of interest) from a binary image IMG.
%   The intersection of the structure with the bounds of the image is not
%   taken into account for the computation, making it possible to use ot
%   for continuous structures observed through a representative window.
%
%   Example
%     % estimate surface area density of a system of balls with constant
%     % radius and randomly shifted positions
%     % first generate ball centers
%     cx = 10:20:90; cy = 10:20:90; cz = 10:20:90;
%     [cx, cy, cz] = meshgrid(cx, cy, cz);
%     % add some randomness to centers
%     cx = cx + rand(size(cx));
%     cy = cy + rand(size(cy));
%     cz = cz + rand(size(cz));
%     % compute the discretization grid
%     lx = 1:100; ly = 1:100; lz = 1:100;
%     [x, y, z] = meshgrid(lx, ly, lz);
%     img = false(100, 100, 100);
%     % discretize the system of ball
%     for i = 1:numel(cx)
%         bin = hypot(hypot(x-cx(i), y-cy(i)), z-cz(i)) < 8;
%         img = img | bin;
%     end
%     % measured surface area density
%     imSurfaceDensity(img)
%     ans =
%         0.1033
%     % compare with theoretical surface area density
%     % (relative error is around 3-4 percents)
%     svth = numel(cx) * 4*pi*8*8 / (100^3)
%     svth =
%         0.1005
%
%
%   See also
%     imSurface, imSurfaceEstimate, imSurfaceLut
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    sd = zeros(length(labels), 1);
    for i=1:length(labels)
        sd(i) = imSurfaceDensity(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% check image resolution
delta = [1 1 1];
if ~isempty(varargin)
    var = varargin{end};
    if length(var)==3
        delta = varargin{end};
    end
end

% component area in image
s = imSurfaceEstimate(img, varargin{:});

% total volume of image (without edges)
refVol = prod(size(img)-1)*prod(delta);

% compute area density
sd = s / refVol;

function [breadth, labels] = imMeanBreadthDensity(img, varargin)
% Mean breadth density of a 3D binary structure.
%
%   MV = imMeanBreadthDensity(IMG)
%   Estimate mean breadth density (ratio of mean breadth over volume of the
%   region of interest) from a binary image IMG. 
%   The intersection of the structure with the bounds of the image is not
%   taken into account for the computation, making it possible to use ot
%   for continuous structures observed through a representative window.
%
%   MV = imMeanBreadthDensity(IMG, RESOL)
%   Also specifies the resolution of input image.
%
%   MV = imMeanBreadthDensity(IMG, RESOL, NDIRS)
%   Also specifies the number of directions for computation. Can be either
%   3 or 13 (the default).
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
%     imMeanBreadthDensity(img)
%     ans =
%         0.0021
%     % compare with theoretical mean breadth density
%     % mb_th = ball_number * single_ball_diameter / box_volume.
%     % (relative error can be around 3-4 percents)
%     mbth = numel(cx) * 2*8 / (100^3)
%     svth =
%         0.0020
%
%   See also
%     imMeanBreadth, imSurfaceAreaDensity, imMeanBreadthLut
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2015-04-20,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRAE - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    breadth = zeros(length(labels), 1);
    for i = 1:length(labels)
        breadth(i) = imMeanBreadthDensity(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% Process user input arguments
delta = [1 1 1];
nDirs = 13;
while ~isempty(varargin)
    var = varargin{1};
    if ~isnumeric(var)
        error('option should be numeric');
    end
    
    % option is either connectivity or resolution
    if isscalar(var)
        nDirs = var;
    else
        delta = var;
    end
    varargin(1) = [];
end

% component area in image
breadth = imMeanBreadthEstimate(img, delta, nDirs);

% total volume of image (without edges)
refVol = prod(size(img)-1) * prod(delta);

% compute area density
breadth = breadth / refVol;

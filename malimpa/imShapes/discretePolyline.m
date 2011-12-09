function img = discretePolyline(varargin)
%DISCRETEPOLYLINE discretize a planar polyline
%
%   IMG = discretePolyline(DIM, POINTS, DIST)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   POINTS is a Nx2 array containing coordinate of polyline vertices.
%   DIST is the distance between the polyline and the pixel in image
%   Returns an image containing a discrete approximation of the polyline.
%
%   IMG = discretePolyline(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-05-16
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY

%% process input parameters

% extract coordinate of image voxels
[lx ly varargin] = parseGridArgs(varargin{:});

% coordinate of polyline vertices
poly = varargin{1};

% distance between pixel and polyline
dist = 1;
if length(varargin)>1
    dist = varargin{2};
end

%% compute discrete version of the polyline

[x y] = meshgrid(lx, ly);
img = reshape(distancePointPolyline([x(:), y(:)], poly)<dist, size(x));


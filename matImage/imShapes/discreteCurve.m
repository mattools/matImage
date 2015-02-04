function img = discreteCurve(varargin)
%DISCRETECURVE Discretize a planar curve
%
%   IMG = discreteCurve(DIM, CURVE, WIDTH)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   CURVE is a series of points describing the curve
%   WIDTH is the max distance between pixel centers and points of the
%   curve.
%
%   IMG = discreteCurve(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%   Example
%   % creates a ring
%   circle = circleAsPolygon([25 25 15], 120);
%   img = discreteCurve([1 1 50;1 1 50], circle, 3);
%   imshow(img);
%

% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2007-03-19
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   19/06/2007: update doc
%   04/03/2009: use meshgrid
%   29/05/2009: use more possibilities for specifying grid

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% get polyline vertex coordinates
curve = varargin{1};
varargin(1) = [];

% determines width of the polyline
width = 2;
if ~isempty(varargin)
    width = varargin{1};
end

try
    % try with vectorized version (greedy !!!)
    dist = reshape(minDistancePoints([x(:) y(:)], curve), size(x));
catch
    % if not enough memory, use loop instead
    dist = zeros(size(x));
    for i = 1:length(lx)
        dist(:, i) = minDistancePoints([x(:,i) y(:,i)], curve);
    end        
end

% create image : simple threshold over 2 dimensions
img = abs(dist) < width;



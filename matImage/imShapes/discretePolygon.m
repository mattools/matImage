function img = discretePolygon(varargin)
%DISCRETEPOLYGON Discretize a planar polygon
%
%   IMG = discretePolygon(DIM, POINTS)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   POINTS is a N-by-2 array containing coordinate of polygon vertices.
%   Returns an image containing a discrete approximation of the polygon.
%
%   IMG = discretePolygon(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%  See Also
%  imShapes, discretePolyline

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-05-16
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/03/2009: use meshgrid
%   29/05/2009: use more possibilities for specifying grid

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% process input parameters
if length(varargin)==1
    var = varargin{1};
    px = var(:,1);
    py = var(:,2);
    
elseif length(varargin)==2
    px = varargin{1};
    py = varargin{2};
end

% compute discrete version of the polygon
img = inpolygon(x, y, px, py);


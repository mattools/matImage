function img = discreteEllipse(varargin)
%DISCRETEELLIPSE Discretize a planar ellipse
%
%   IMG = discreteEllipse(DIM, CENTER, SIDE)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   CENTER is the center of the ellipse
%   SIDE is the length of the 2 semi-axis of the ellipse
%   Bounding box of ellipse has SIDE(1)x2 width, and side(2)x2 height.
%
%   IMG = discreteEllipse(DIM, CENTER, SIDE, THETA)
%   Also specify spherical angle of the normal of a face of the ellipse.
%   THETA is the angle with the horizontal, in degrees, counted
%   counter-clockwise in direct basis (and clockwise in image basis).
%
%   IMG = discreteEllipse(DIM, ELLIPSE)
%   send parameters in a row vector, where ELLIPSE contains at least the
%   center coordinate, and possibly the other parameters.
%
%   IMG = discreteDisc(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%   Example
%   img = discreteEllipse([1 1 100;1 1 100], [50 50], [30 10]);
%   img = discreteEllipse([1 1 100;1 1 100], [50 50 30 10]);
%   img = discreteEllipse(1:100, 1:100, [50 50 30 10 30]);
%
%   See also
%   imShapes, discreteDisc, discteteEllipsoid, drawEllipse
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-05-16
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/01/2007: concatenate transforms before applying them, update doc
%   04/03/2009: use meshgrid
%   29/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size
%   2011-03-30 use degrees


% compute coordinate of image pixels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% default parameters
center = [lx(ceil(end/2)) ly(ceil(end/2))];
side    = center;
theta   = 0;

% process input parameters
if length(varargin)==1
    % parameters are bundled in the first argument
    var = varargin{1};
    center = var(:,1:2);
    if size(var, 2)>3
        side = var(:,3:4);
    end
    if size(var, 2)>4
        theta = var(:,5);
    end
    
elseif ~isempty(varargin)
    % parameters are given as separate arguments
    center = varargin{1};
    if length(varargin)>1
        side = varargin{2};
    end
    if length(varargin)>2
        theta = varargin{3};
    end
end

% case of circular ellipses
if length(side)==1
    side = [side side];
end

% transforms voxels according to ellipse position and size
tra     = createTranslation(-center);
rot     = createRotation(-deg2rad(theta));
sca     = createScaling(1./side);
[x, y]  = transformPoint(x, y, sca*rot*tra);

% create image : simple threshold over 2 dimensions
img = x.*x + y.*y <= 1;



function img = discreteHalfPlane(varargin)
%DISCRETEHALFPLANE Discretize a half plane
%
%   A Halfplane is the set of point delimited by a straight line.
%   Only the points located 'on the left' of the line belong to the
%   halfplane.
%
%   IMG = discreteHalfPlane(DIM, LINE)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   LINE is a 1x4 array of the form [x0 y0 dx dy], x0 and y0 being
%   coordinate of a point belonging to the boundary line, and dx and dy
%   being direction vectors of the boundary line of the halfplane.
%
%   IMG = discreteHalfPlane(DIM, POINT, DIRECTION)
%   POINT is a point belonging to the boundary line
%   DIRECTION is a 2x1 vector containing direction vector of the boundary
%   line.
%
%   IMG = discreteHalfPlane(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%   Example
%   img = discreteHalfPlane([1 1 100;1 1 100], [50 50], 30, 10);
%
%   See Also
%     imShapes, discreteDisc, discreteSquare
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-10-12
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/01/2007: concatenate transforms before applying them
%   04/03/2009: use meshgrid
%   29/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% default parameters
center = [lx(ceil(end/2)) ly(ceil(end/2))];
theta   = 0;

% process input parameters
if length(varargin)==1
    % first argument contains all parameters
    var = varargin{1};
    center = var(1:2);
    theta = atan2(var(4), var(3));
    
elseif ~isempty(varargin)
    % parameters are given as separate arguments
    center = varargin{1};
    var = varargin{2};
    theta = atan2(var(2), var(1));
end

% transforms voxels according to square orientation
tra     = createTranslation(-center);
rot     = createRotation(-theta);
[x, y]  = transformPoint(x, y, rot*tra); %#ok<ASGLU>

% create image : simple threshold over 1 dimension
img = y > -1e-14;


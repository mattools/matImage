function img = discreteRectangle(varargin)
%DISCRETERECTANGLE Discretize a planar rectangle
%
%   IMG = discreteRectangle(DIM, CENTER, SIDE)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   CENTER is the center of the rectangle, with format [xc yc]
%   SIDE is the size of the rectangle, with format [L1 L2]
%
%   IMG = discreteRectangle(DIM, CENTER, SIDE, THETA)
%   Also specify the rotation angle of the rectangle. THETA is the angle
%   with the horizontal, in degrees, counted counter-clockwise in direct
%   basis (and clockwise in image basis). 
%
%   IMG = discreteRectangle(DIM, RECT)
%   send parameters in a row vector, where RECT contains at least the
%   center coordinate, and possibly the other parameters.
%
%   IMG = discreteRectangle(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%   Example
%   % create image of rectangle at center [50 50] and sides 30 and 10.
%   img = discreteRectangle([1 1 100;1 1 100], [50 50], 30, 10);
%   img = discreteRectangle([1 1 100;1 1 100], [50 50 30 10]);
%   % add a rotation by 30 degrees
%   img = discreteRectangle([1 1 100;1 1 100], [50 50 30 10 30]);
%
%   See Also
%   imShapes, discreteSquare, discretePolygon
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-05-16
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   19/06/2007 update doc, fix input processing
%   10/10/2008 update doc, fix input for rectangle given as one vector
%   04/03/2009: use meshgrid
%   29/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size
%   2011-03-30 use degrees

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% default parameters
center = [lx(ceil(end/2)) ly(ceil(end/2))];
side    = center;
theta   = 0;

% process input parameters
if length(varargin)==1
    % all parameters are bundled in first argument
    var = varargin{1};
    center = var(:,1:2);
    if size(var, 2)>3
        side = var(:,3:4);
    end
    if size(var, 2)>4
        theta = var(:,5);
    end
    
elseif ~isempty(varargin)
    % parameters are given in different arguments
    center = varargin{1};
    if length(varargin)>1
        side = varargin{2};
    end
    if length(varargin)>2
        theta = varargin{3};
    end
end

% ensure SIDE has 2 parameters
if length(side)==1
    side = [side side];
end

% transforms voxels according to square orientation and size
tra     = createTranslation(-center);
rot     = createRotation(-deg2rad(theta));
sca     = createScaling(1./side);
[x, y]  = transformPoint(x, y, sca*rot*tra);

% create image : simple threshold over 2 dimensions
img = abs(x)<=.5 & abs(y)<=.5;


function img = discreteParabola(varargin)
%DISCRETEPARABOLA Discretize a planar parabola
%
%   Returns an image formed by all the points of the discrete grid located
%   inside a vertical parabola, defined by its vertex and a scaling 
%   parameter.
%   Such a parabola admits a vertical axis of symetry.
%
%   IMG = discreteParabola(DIM, VERTEX, A)
%   DIM is the size of the image, with the format [x0 dx x1;y0 dy y1]
%   VERTEX is the coordinate of the parabola vertex
%   P is the distance between the vertex and the focus, or between the
%   vertex and the directrix.
%   The algebraic equation of parabola is :
%      (y - YV) = A * (x - XV)^2 
%   A parametric equation of parabola is :
%      x(t) = t + xVertex;
%      y(t) = A*t^2 + yVertex;
%
%   IMG = discreteParabola(DIM, VERTEX, A, THETA)
%   THETA is the angle with the horizontal of tangent vector located at the
%   vertex, in degrees, counted counter-clockwise in direct basis (and
%   clockwise in image basis).
%
%   IMG = discreteParabola(DIM, PARABOLA)
%   send parameters in a row vector, where PARABOLA contains at least the
%   vertex coordinate and the parameter P, and possibly the angle THETA.
%
%   Example
%   img = discreteParabola([1 1 100;1 1 100], [50 50], .5);
%   img = discreteParabola([1 1 100;1 1 100], [50 50 .5]);
%   img = discreteParabola([1 1 100;1 1 100], [50 50 .5 30]);
%
%   
%   % Draw parabola image and a polyline approximation
%     lx = linspace(0, 100, 200);
%     ly = linspace(0, 100, 200);
%     para = [60 10 .1 30]; % vertex at (60,10), param .1, angle 30 degrees
%     img = discreteParabola(lx, ly, para);
%     imshow(img, 'xdata', lx, 'ydata', ly);
%     hold on
%     drawParabola(para, [-100 100], 'linewidth', 2, 'color', 'g');
%
%   See Also
%   imShapes, discreteDisc, discreteEllipse, discreteSquare
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-05-16
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/01/2007: concatenate transforms before applying them
%   04/03/2009: use meshgrid
%   29/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   2011-03-30 use degrees, change meaning of parameter A

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% default parameters
vertex  = [lx(ceil(end/2)) ly(ceil(end/2))];
a       = 1;
theta   = 0;

% process input parameters
if length(varargin)==1
    % all parameters bundled in first argument
    var = varargin{1};
    vertex = var(:,1:2);
    if size(var, 2)>2
        a = var(:,3);
    end
    if size(var, 2)>3
        theta = var(:,4);
    end
    
elseif ~isempty(varargin)
    % parameters given in different arguments
    vertex = varargin{1};
    if length(varargin)>1
        a = varargin{2};
    end
    if length(varargin)>2
        theta = varargin{3};
    end
end

% transforms voxels according to parabola orientation
tra     = createTranslation(-vertex);
rot     = createRotation(-deg2rad(theta));
sca     = createScaling(1, 1/a);
[x, y]  = transformPoint(x, y, sca*rot*tra);

% create image: simple threshold over 2 dimensions
img = x .^ 2 <= y;


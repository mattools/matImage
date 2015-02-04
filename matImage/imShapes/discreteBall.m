function img = discreteBall(varargin)
%DISCRETEBALL Discretize a 3D Ball
%
%   IMG = discreteBall(DIM, CENTER, RADIUS)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%   CENTER is the center of the ball. It's a [1x3] row vector.
%   RADIUS is the radius of the ball. It can be either a scalar (spherical
%   ball) or a 1x3 row vector (isothetic ellipsoid).
%
%   IMG = discreteBall(DIM, BALL)
%   send parameters in a row vector, where BALL contains at least the
%   center coordinate, and possibly the other parameters.
%
%   IMG = discreteBall(LX, LY, LZ, ...);
%   Specifes the voxels coordinates with the three row vectors LX, LY and
%   LZ.
%
%   Example
%   img = discreteBall([1 1 100;1 1 100;1 1 100], [50 50 50], 30);
%   img = discreteBall([1 1 100;1 1 100;1 1 100], [50 50 50 30]);
%   img = discreteBall(1:100, 1:100, 1:100, [50 50 50 30]);
%
%   See also:
%   discreteDisc, discreteEllipsoid
%

% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   26/10/2006 concatenate transforms before applying them.
%   04/03/2009 add possibility for ellipsoid, use meshgrid
%   30/04/2009 update transforms
%   29/05/2009 use more possibilities for specifying grid
%   22/01/2010 fix auto center with odd image size
%   27/07/2010 add support for multiple balls, split discreteEllipsoid
%   29/09/2010 remove code corresponding to discreteEllipsoid


%% Extract image dimension

% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z]  = meshgrid(lx, ly, lz);


%% default parameters

% default center
center  = [lx(ceil(end/2)) ly(ceil(end/2)) lz(ceil(end/2))];

% default radius
radius  = center;


%% Extract ball parameters

% process input parameters
if length(varargin) == 1
    var = varargin{1};
    
    if size(var, 2) == 4
        % center of the ball
        center = var(:,1:3);
        radius = var(:,4);
    else
        error('Sphere parameter must have 4 columns');
    end
    
elseif ~isempty(varargin)
    center = varargin{1};
    if length(varargin) > 1
        radius = varargin{2};
    end
end

% ensure inputs have same size
if size(radius, 1)==1
    radius = repmat(radius, [size(center, 1) 1]);
end
if size(center, 1)==1
    center = repmat(center, [size(radius, 1) 1]);
end


%% Compute discrete image

nBalls = size(center, 1);
if nBalls == 1
    % case of a single ball
    
    % transforms voxels according to ball orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center),...
        createScaling3d(1./radius) );
    [x, y, z] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img = x.*x + y.*y + z.*z < 1;
    return;
end

% process a collection of balls

img = false(size(x));

for i = 1:nBalls
    % transforms voxels according to ball orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center(i,:)),...
        createScaling3d(1./radius(i,:)) );
    [xt, yt, zt] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img(xt.*xt + yt.*yt + zt.*zt < 1) = 1;
end

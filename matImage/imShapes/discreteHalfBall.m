function img = discreteHalfBall(varargin)
%DISCRETEHALFBALL discretize a 3D half-ball
%
%   IMG = discreteHalfBall(LX, LY, LZ, HBALL)
%   Creates a 3D image of a half-ball, given coordinates of voxel centers
%   in LX, LY and LZ, and parameters of the shape in HBALL.
%   
%   HBALL has following format:
%   [XC YC ZC R THETA PHI]
%   where (XC YX ZC) is the ball center, R is the ball radius, and (THETA,
%   PHI) is the orientation of the half-ball top.
%   THETA is the colatitude, in degrees, and PHI is the azimut, in degrees.
%
%   IMG = discreteHalfBall(LX, LY, LZ, CENTER, SIDE, THETA, PHI)
%   Specify parameters in separate arguments (obsolete syntax).
%
%   IMG = discreteHalfBall(DIM, HBALL)
%   Specifies image size with a 3-by-3 array, with format:
%   DIM = [x0 dx x1;y0 dy y1;z0 dz z1]
%
%
%   Example
%   % Half-ball with spherical cap towards positive Z
%   img = discreteHalfBall(1:100, 1:100, 1:100, [50 50 50 40]);
%   figure;
%   isosurface(img, .5); axis equal;
%
%   % Half-ball with spherical cap towards angle [30 45]
%   img = discreteHalfBall(1:100, 1:100, 1:100, [50 50 50  40  30 45]);
%   figure;
%   isosurface(img, .5); axis equal;
%
%   See Also
%   imShapes, discreteBall, discreteHalfPlane

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-21
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   2010-10-21 create from discreteCube and discreteBall

% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z] = meshgrid(lx, ly, lz);

% default parameters
center  = [lx(ceil(end/2)) ly(ceil(end/2)) lz(ceil(end/2))];
radius  = center;
theta   = 0; phi = 0;

% process input parameters
if length(varargin) == 1
    var = varargin{1};
    center = var(:,1:3);
    if size(var, 2) > 3
        radius = var(:,4);
    end
    if size(var, 2) > 4
        theta = var(:,5);
    end
    if size(var, 2) > 5
        phi = var(:,6);
    end

elseif ~isempty(varargin)
    center = varargin{1};
    if length(varargin) > 1
        radius = varargin{2};
    end
    if length(varargin) > 2
        theta = varargin{3};
    end
    if length(varargin) > 3
        phi = varargin{4};
    end
end

if length(radius) == 1
    radius = [radius radius radius];
end

% compute coordinate of image voxels in half-ball reference system
trans = composeTransforms3d(...
    createTranslation3d(-center),...
    createRotationOz(-deg2rad(phi)),...
    createRotationOy(-deg2rad(theta)),...
    createScaling3d(1./radius));
[x, y, z] = transformPoint3d(x, y, z, trans);

% create image: simple threshold over 3 dimensions, and test z axis
img = ((x.*x + y.*y + z.*z) < 1) & (z>0);

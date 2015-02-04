function img = discreteCube(varargin)
%DISCRETECUBE discretize a 3D cube
%
%   IMG = discreteCube(LX, LY, LZ, CUBE)
%   Creates a 3D image of a cube, given coordinates of voxel centers in LX,
%   LY and LZ, and parameters of the shape in CUBE.
%
%   CUBE has the format: 
%   [XC YC ZC SIDE], with (XC YC ZC) being the coordinates of the center,
%   and SIDE being the side length of the cube.
%
%   Oriented cubes are represented as follow:
%   [XC YC ZC SIDE THETA PHI PSI], with (THETA, PHI) being the angle of the
%   normal of the cube (THETA is colatitude, PHI is longitude), and PSI is
%   rotation of the cube around the normal. All angles are in degrees.
%
%   IMG = discreteCube(DIM, ...)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%
%   IMG = discreteCube(DIM, CENTER, SIDE, THETA, PHI)
%   Also specify spherical angle of the normal of a face of the cube. THETA
%   is the angle from the vertical, and PHI is the angle from the 0x axis,
%   both between 0 and 360. 
%
%   IMG = discreteCube(DIM, CENTER, SIDE, THETA, PHI, PSI)
%   Also consider 'roll' of the cube around its normal axis. PSI is an
%   angle given in degrees between 0 and 360.
%
%   IMG = discreteCube(DIM, CUBE)
%   send parameters in a row vector, where CUBE contains at least the
%   center coordinate, and possibly the other parameters.
%
%   Example
%   img = discreteCube(1:100, 1:100, 1:100, [50 50 50 30 10 60 45]);
%   img = discreteCube([1 1 100;1 1 100;1 1 100], [50 50 50], 30, 10);
%   img = discreteCube([1 1 100;1 1 100;1 1 100], [50 50 50 30 10]);
%
%   See Also
%   discreteBall, discreteEllipsoid, discreteCylinder
%

% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   03/11/2006: concatenate transforms, add doc for PSI
%   04/03/2009: use meshgrid
%   30/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size
%   2011-06-21 use degrees for angles

% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z] = meshgrid(lx, ly, lz);

% default parameters
center  = [lx(ceil(end/2)) ly(ceil(end/2)) lz(ceil(end/2))];
side    = center;
theta   = 0; phi = 0; psi=0;

% process input parameters
if length(varargin)==1
    var = varargin{1};
    center = var(:,1:3);
    if size(var, 2)>3
        side = var(:,4);
    end
    if size(var, 2)>4
        theta = var(:,5);
    end
    if size(var, 2)>5
        phi = var(:,6);
    end
    if size(var, 2)>6
        psi = var(:,7);
    end
    
elseif ~isempty(varargin)
    center = varargin{1};
    if length(varargin)>1
        side = varargin{2};
    end
    if length(varargin)>2
        theta = varargin{3};
    end
    if length(varargin)>3
        phi = varargin{4};
    end
    if length(varargin)>4
        psi = varargin{5};
    end
end

if length(side) == 1
    side = [side side side];
end

% compute coordinate of image voxels in cube reference system
trans = composeTransforms3d(...
    createTranslation3d(-center),...
    createRotationOz(-deg2rad(phi)),...
    createRotationOy(-deg2rad(theta)), ...
    createRotationOz(-deg2rad(psi)));
[x, y, z] = transformPoint3d(x, y, z, trans);

% create image: simple threshold over 3 dimensions
img = abs(x) <= side(1)/2 & abs(y) <= side(2)/2 & abs(z) <= side(3)/2;

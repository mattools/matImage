function img = discreteTorus(varargin)
%DISCRETETORUS Discretize a 3D Torus
%
%   IMG = discreteTorus(LX, LY, LZ, TORUS)
%   Creates a 3D image of a torus, given coordinates of voxel centers in
%   LX, LY and LZ, and parameters of the shape in TORUS.
%
%   TORUS has the format:
%   [XC YC ZC R1 R2 THETA PHI]
%   where (XC YC ZC) is the torus center, R1 is the main radius of the
%   torus, R2 is the radius of a torus section, and (THETA PHI) is the
%   3D angle of the torus normal vector. THETA is the angle from the
%   vertical (between 0 and 180 degrees) and PHI is the angle from the 0x
%   axis, between 0 and 360. 
%
%   IMG = discreteTorus(DIM, TORUS)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%
%   IMG = discreteTorus(..., CENTER, R1, R2, THETA, PHI)
%   Specifies torus parameters as separate values (deprecated).
%
%   Example
%   % draw isosurface of a discretized torus
%     img = discreteTorus(1:100, 1:100, 1:100, [50 50 50 30 10 30 45]);
%     figure; isosurface(img, .5);
%     axis equal;
%
%   See also
%   discreteEllipsoid, discreteBall, discreteCube
%   drawTorus
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/03/2009: use meshgrid
%   30/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size
%   2011-06-21 use angles in degrees


% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z] = meshgrid(lx, ly, lz);

% default parameters
center  = [lx(ceil(end/2)) ly(ceil(end/2)) lz(ceil(end/2))];
r1      = 30; 
r2      = 20;
theta   = 60; 
phi     = 60;

% process input parameters
if length(varargin)==1
    var = varargin{1};
    center = var(:,1:3);
    if size(var, 2)>3
        r1 = var(:,4);
    end
    if size(var, 2)>4
        r2 = var(:,5);
    end
    if size(var, 2)>5
        theta = var(:,6);
    end
    if size(var, 2)>6
        phi = var(:,7);
    end
    
elseif ~isempty(varargin)
    center = varargin{1};
    if length(varargin)>1
        r1 = varargin{2};
    end
    if length(varargin)>2
        r2 = varargin{3};
    end
    if length(varargin)>3
        theta = varargin{4};
    end
    if length(varargin)>4
        phi = varargin{5};
    end
end

% transforms voxels according to torus orientation
trans = composeTransforms3d(...
    createTranslation3d(-center),...
    createRotationOz(-deg2rad(phi)),...
    createRotationOy(-deg2rad(theta)));
[x, y, z] = transformPoint3d(x, y, z, trans);

% convert coordinates to cylindrical
[theta, r, z] = cart2pol(x, y, z); %#ok<ASGLU>

% create image: all the pixels with distance less than r2 to the great
% circle
img = hypot(r-r1, z) < r2;


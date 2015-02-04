function img = discreteReuleauxRevol(varargin)
%DISCRETEREULEAUXREVOL Discretize the revolution of a Reuleaux triangle
%
%   A Reuleaux triangle is formed by 3 circle arcs, and has the property to
%   have a constant width whatever the  orientation.
%   In 3 dimension, the surface of revolution obtained by rotating a
%   Reuleaux triangle around one of its axis of symetry has also a constant
%   width. The resulting shape looks like a hazelnut.
%
%   IMG = discreteReuleauxRevol(LX, LY, LZ, REULEAUX)
%   REULEAUX is the domaine enclosed by the revolution of a Reuleaux
%   triangle around one of its axis. REULEAUX is defined by:
%   [XC YC ZC R THETA PHI]
%   where (XC, YC, ZC) is the geometric centroid the triangle, R is the
%   radius of the circle arcs, and THETA and PHI define the orientation of
%   the Reuleaux Apex: THETA is the colatitude, between 0 and 180 degrees,
%   and PHI is the azimut, between 0 and 360 degrees.
%
%   IMG = discreteReuleauxRevol(LX, LY, LZ, REULEAUX, D)
%   Use the dilation of a Reuleaux shape by a ball of radius D. The
%   constant diameter of the resulting shape equals R + 2*D.
%
%   IMG = discreteReuleauxRevol(DIM, ...)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%
%   Examples
%   % Display oriented reuleaux triangle revolution
%     reuleaux = [50 50 50  60  30 40];
%     img = discreteReuleauxRevol(1:100, 1:100, 1:100, reuleaux);
%     figure();
%     isosurface(img, .5); 
%     axis equal;
%
%   % The same, with a little bit dilation
%     reuleaux = [50 50 50  60  30 40]
%     img2 = discreteReuleauxRevol(1:100, 1:100, 1:100, reuleaux, 10);
%     figure();
%     isosurface(img2, .5); 
%     axis equal;
%
%   % Alternative syntax
%     img = discreteReuleauxRevol([1 1 100;1 1 100;1 1 100], reuleaux);
%
%   See Also
%   discreteEllipsoid, discreteTorus, discreteBall
%

%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/01/2007: concatenate transforms before transforming points
%   04/03/2009: use meshgrid
%   30/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid


% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z] = meshgrid(lx, ly, lz);

% parameters of Revolved Reuleaux triangle
reul    = varargin{1};
center  = reul(1:3);
R       = reul(4);
theta   = deg2rad(reul(5));
phi     = deg2rad(reul(6));
varargin(1) = [];

% extract dilation factor if present
dil = 0;
if ~isempty(varargin)
    dil = varargin{1};
end

% top point of triangle
x1  = 0;
y1  = 0;
z1  = 0;

% the height of the triangle
h   = R * sqrt(3) / 2;
dil2 = dil * sqrt(3) / 2;

% create empty image
img = false(size(x));

% transforms voxels according to shape orientation
trans = composeTransforms3d(...
    createTranslation3d(-center),...
    createRotationOz(-phi),...
    createRotationOy(-theta), ...
    createTranslation3d([0 0 h*2/3]));
[x, y, z] = transformPoint3d(x, y, z, trans);


% distance of the points to the revolution axis
rho = hypot(x-x1, y-y1);

% points above the top of the triangle
ind = find((z <= z1) & (z >= z1-dil));
dist = rho(ind).^2 + (z(ind)-z1).^2;
img(ind) = dist <= dil ^ 2;

% points above the basis of the triangle and below the top
ind  = find(z >= z1-dil2 & z <= (z1+h));
dist = (rho(ind)+R/2).^2 + (z(ind)-z1-h).^2;
img(ind) = dist < (R+dil)^2;

% points around the 2 lower corners
dist = (rho-R/2).^2 + (z-z1-h).^2;
img(dist < dil^2) = 1;
ind  = find(z > z1+h & z <= z1+h+dil2);
dist = rho(ind) ;
img(ind(dist < R/2)) = 1;

% points below the basis of the triangle
ind  = find(z >= z1+h+dil2);
dist = rho(ind).^2 + (z(ind)-z1).^2;
img(ind) = dist < (R+dil)^2;

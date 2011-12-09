function img = discreteEllipsoid(varargin)
%DISCRETEELLIPSOID discretize a 3D ellipsoid
%
%   IMG = discreteEllipsoid(DIM, ELLI)
%   Creates a 3D image of an allispoid, given coordinates of voxel centers
%   in LX, LY and LZ, and parameters of the shape in ELLI.
%
%   ELLI has the format: 
%   [XC YC ZC A B C PHI THETA PSI]
%   where (XC YC ZC) is the ellipsoid center, A, B and C are the lengths of
%   the semi-axes, PHI is the azimut (or 'Yaw') , THETA is the elevation
%   (or 'pitch'), and PSI is the proper rotation (or 'roll') of the
%   ellipsoid. All angles are in degrees.
%   
%   IMG = discreteEllipsoid(DIM, ELLI)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%
%   Example
%     elli = [50 50 50  30 20 10  40 30 20];
%     img = discreteEllipsoid(1:100, 1:100, 1:100, elli);
%     figure;
%     isosurface(img, .5);
%     hold on; axis square;
%     drawEllipsoid(elli, 'FaceColor', 'r');
%
%
%   See also:
%   discreteBall, discreteEllipse, discreteTorus, discreteCube
%   drawEllipsoid
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   27/07/2010 create from discreteBall
%   2011-06-21 use degrees for angles, and changes angle convention

% compute coordinate of image voxels
[lx ly lz varargin] = parseGridArgs3d(varargin{:});
[x y z]  = meshgrid(lx, ly, lz);

% default parameters

% default center
center  = [lx(ceil(end/2)) ly(ceil(end/2)) lz(ceil(end/2))];

% default radius
radius  = center;

% default orientation
theta   = 0; 
phi     = 0; 
psi     = 0;

% process input parameters
if length(varargin)==1
    var = varargin{1};
    % center of the ball
    center = var(:,1:3);
    
    % extract ellipsoid radii
    if size(var, 2)>5
        radius = var(:, 4:6);
    end
    
    % extract orientation of the ellipsoid
    if size(var, 2)>6
        phi = var(:,7);
    end
    if size(var, 2)>7
        theta = var(:,8);
    end
    if size(var, 2)>8
        psi = var(:,9);
    end
    
elseif ~isempty(varargin)
    center = varargin{1};
    if length(varargin)>1
        radius = varargin{2};
    end
    if length(varargin)>2
        phi = varargin{3};
    end
    if length(varargin)>3
        theta = varargin{4};
    end
    if length(varargin)>4
        psi = varargin{5};
    end
end

% ensure all inputs have the same size
N = max(size(center, 1), size(radius, 1));
if size(center, 1)~=N
    center = repmat(center, [N 1]);
end
if size(radius, 1)~=N
    radius = repmat(radius, [N 1]);
end
if size(phi, 1)~=N
    phi = repmat(phi, [N 1]);
end
if size(theta, 1)~=N
    theta = repmat(theta, [N 1]);
end
if size(psi, 1)~=N
    psi = repmat(psi, [N 1]);
end

if size(center, 1)==1
    % case of a single ellipsoid
    
    % transforms voxels according to ellipsoid orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center),...
        createRotationOz(-deg2rad(phi)),...
        createRotationOy(-deg2rad(theta)), ...
        createRotationOx(-deg2rad(psi)), ...
        createScaling3d(1 ./ radius) );
    [x y z] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img = x.*x + y.*y + z.*z < 1;
    return;
end

% process a collection of ellipsoids

img = false(size(x));

for i = 1:size(center, 1)
    % transforms voxels according to ellipsoid orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center(i,:)),...
        createRotationOz(-deg2rad(phi(i))),...
        createRotationOy(-deg2rad(theta(i))), ...
        createRotationOx(-deg2rad(psi(i))), ...
        createScaling3d(1 ./ radius(i,:)) );
    [xt yt zt] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img(xt.*xt + yt.*yt + zt.*zt < 1) = 1;
end

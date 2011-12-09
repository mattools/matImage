function img = discreteCuboid(varargin)
%DISCRETECUBOID discretize a 3D cuboid
%
%   IMG = discreteCuboid(LX, LY, LZ, CUBOID)
%   Creates a 3D image of a cuboid, given coordinates of voxel centers
%   in LX, LY and LZ, and parameters of the shape in CUBOID.
%
%   CUBOID has the format: 
%   [XC YC ZC L W H YAW PITCH ROLL]
%   where (XC YC ZC) is the cuboid center, L, W and H are the length of the
%   cuboid in each main direction, YAW , PITCH ROLL describe orietntation
%   of the cuboid, in degrees. 
%   
%   IMG = discreteCuboid(DIM, CUBOID)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1;z0 dz z1]
%
%   Example
%     cubo = [50 50 50  60 40 20  30 20 10];
%     img = discreteCuboid(1:100, 1:100, 1:100, cubo);
%     figure;
%     isosurface(img, .5);
%     hold on; axis square;
%     drawCuboid(cubo, 'FaceColor', 'r');
%
%
%   See also:
%   discreteBall, discreteEllipse, discreteTorus, discreteCube
%   drawEllipsoid
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-29
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   2011-06-29 create from discreteCube and discreteEllipsoid

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
    
    % extract cuboid lengths
    if size(var, 2) > 5
        sides = var(:, 4:6);
    end
    
    % extract orientation of the cuboid
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
        sides = varargin{2};
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
    sides = repmat(sides, [N 1]);
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

if size(center, 1) == 1
    % case of a single cuboid
    
    % transforms voxels according to cuboid orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center),...
        createRotationOz(-deg2rad(phi)),...
        createRotationOy(-deg2rad(theta)), ...
        createRotationOx(-deg2rad(psi)), ...
        createScaling3d(1 ./ sides) );
    [x y z] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img = abs(x) <= .5 & abs(y) <= .5 & abs(z) <= .5;
    return;
end

% process a collection of cuboids

img = false(size(x));

for i = 1:size(center, 1)
    % transforms voxels according to cuboid orientation
    trans = composeTransforms3d(...
        createTranslation3d(-center(i,:)),...
        createRotationOz(-deg2rad(phi(i))),...
        createRotationOy(-deg2rad(theta(i))), ...
        createRotationOx(-deg2rad(psi(i))), ...
        createScaling3d(1 ./ sides(i,:)) );
    [xt yt zt] = transformPoint3d(x, y, z, trans);

    % create image: simple threshold over 3 dimensions
    img(abs(xt) <= .5 & abs(yt) <= .5 & abs(zt)) = 1;
end

function img = discreteCylinder(varargin)
%DISCRETECYLINDER Discretize a 3D cylinder
%
%   IMG = discreteCylinder(LX, LY, LZ, P1, P2, RADIUS)
%   LX, LY and LZ are row vectors specifying position of vertex centers
%   along each coordinate.
%   P1 is the starting point of the cylinder, given as a 1-by-3 row vector
%   P2 is the ending point of the cylinder, given as a 1-by-3 row vector
%   RADIUS is the cylinder radius.
%
%   IMG = discreteCylinder(LX, LY, LZ, CYLINDER)
%   send parameters in a row vector, where CYLINDER is a 1-by-7 row vector
%   containing coordinates of start point, of end point, and radius:
%   CYLINDER = [X1 Y1 Z1 X2 Y2 Z2 R];
%
%   Example
%     % Compute the union of three mutually orthogonal cylinders
%     p0 = [30 30 30];
%     p1 = [90 30 30];
%     p2 = [30 90 30];
%     p3 = [30 30 90];
%     cyl1 = discreteCylinder(1:100, 1:100, 1:100, [p0 p1 25]);
%     cyl2 = discreteCylinder(1:100, 1:100, 1:100, [p0 p2 25]);
%     cyl3 = discreteCylinder(1:100, 1:100, 1:100, [p0 p3 25]);
%     cylUnion = cyl1 | cyl2 | cyl3;
%     [f v] = isosurface(cylUnion, .5);
%     figure;
%     drawMesh(v, f, 'linestyle', 'none', 'facecolor', 'r');
%     l = light; view([120 20]);
%
%   See also
%   discreteBall, discreteCapsule3d
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-10-21
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   2010-10-21 create from discreteCube


%% Process input arguments

% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
[x, y, z] = meshgrid(lx, ly, lz);

% process input parameters
if length(varargin) == 1
    % input is a 1-by-7 row vector
    var = varargin{1};
    if length(var) ~= 7
        error('Should specify a row vector with 7 inputs');
    end

    % extract first and last point coordinates
    p1 = var(1:3);
    p2 = var(4:6);
    radius = var(7);
    
elseif length(varargin) == 3
    % inputs are P1, P2 and R
    p1 = varargin{1};
    p2 = varargin{2};
    radius = varargin{3};
    
else
    error('wrong number of arguments: should be 1 or 3');
end


%% Transform voxel coordinates

% compute cylinder direction angle
dirVect = p2-p1;

[theta, phi, height] = cart2sph2(dirVect);


% compute coordinate of image voxels in cylinder reference system
% (cylinder pointing upwards)
trans = composeTransforms3d(...
    createTranslation3d(-p1),...
    createRotationOz(-phi),...
    createRotationOy(-theta),...
    createScaling3d(1./[radius radius height]));
[x, y, z] = transformPoint3d(x, y, z, trans);


%% Compute final image

% create image: simple threshold over 3 dimensions, and test z axis
img = ((x.*x + y.*y) < 1) & (z>0) & (z<1);

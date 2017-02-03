function img = discreteSphereEighth(varargin)
%DISCRETESPHEREEIGHTH discretize a 3D sphere eighth
%
%   IMG = discreteSphereEighth(LX, LY, LZ, SPHEIGHTH)
%   Creates a 3D image of a eighth of a sphere.
%
%   Example
%   img = discreteSphereEighth(1:100, 1:100, 1:100, [50 50 50 30 10 60 45]);
%   img = discreteSphereEighth([1 1 100;1 1 100;1 1 100], [50 50 50], 30, 10);
%   img = discreteSphereEighth([1 1 100;1 1 100;1 1 100], [50 50 50 30 10]);
%
%   See Also
%   imShapes, discreteBall, discreteCube
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-03-31
% Copyright 2015 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY

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
    createRotationOz(-deg2rad(psi)),...
    createScaling3d(1 ./ side));
[x, y, z] = transformPoint3d(x, y, z, trans);

% create image: simple threshold over 3 dimensions, and over radius
img = sqrt(x.^2 + y.^2 + z.^2) <= 1 & x >= 0 & x <= 1 & y >=0 & y <= 1 & z >= 0 & z <= 1;

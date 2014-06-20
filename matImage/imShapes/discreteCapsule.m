function img = discreteCapsule(varargin)
%DISCRETECAPSULE Create binary image of a planar capsule
%
%   IMG = discreteCapsule(LX, LY, LZ, capsule)
%   LX, LY and LZ are row vectors specifying position of vertex centers
%   along each coordinate.
%   CAPSULE has the following format: [X1 Y1 Z1 X2 Y2 Z2 R]
%   P1 is the starting point of the capsule, given as a 1-by-3 row vector
%   P2 is the ending point of the capsule, given as a 1-by-3 row vector
%   RADIUS is the capsule radius.
%
%   Example
%   % Display a capsule with radius 15 between points (20,30) and (60,70)
%     caps = [20 30 60 70 15];
%     img = discreteCapsule(1:100, 1:100, caps);
%     figure;
%     imshow(img);
%
%   See also
%   discreteDisc, discreteRectangle, discreteCapsule3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-29
% Copyright 2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY


%% Process input arguments
% compute coordinate of image voxels
[lx ly varargin] = parseGridArgs(varargin{:});
[x y] = meshgrid(lx, ly);

% process input parameters
if length(varargin) == 1
    % input is a 1-by-5 row vector
    var = varargin{1};
    if length(var) ~= 5
        error('Should specify a row vector with 5 inputs');
    end

    % extract first and last point coordinates
    p1 = var(1:2);
    p2 = var(3:4);
    radius = var(5);
    
elseif length(varargin) == 3
    % inputs are P1, P2 and R
    p1 = varargin{1};
    p2 = varargin{2};
    radius = varargin{3};
    
else
    error('Wrong number of arguments: should be 1 or 3');
end


%% Transform pixel coordinates

% direction vector of capsule
dirVect = p2 - p1;

% compute capsule direction angle (in radians)
[theta rho] = cart2pol(dirVect(1), dirVect(2));

% compute coordinate of image voxels in capsule reference system
% (capsule pointing upwards)
trans = ...
    createScaling(1 ./ [radius radius]) * ...
    createRotation(-theta) * ...
    createTranslation(-p1);
[x y] = transformPoint(x, y, trans);

rho2 = rho / radius;


%% Create image

% init image
img = false(size(x));

% rect image
img((abs(y) < 1) & (x >= 0) & (x <= rho2)) = true;

% add a disc at each extremity
img((x.*x + y.*y) < 1) = true;
img(((x-rho2).^2 + y.*y) < 1) = true;

function img = discreteDisk(varargin)
%DISCRETEDISK Create binary image of a disk.
%
%   IMG = discreteDisk(LX, LY, DISK);
%   Compute the discretized image of the disk DISK. LX and LY are two
%   vectors that contain pixel ccordinate in the reference space. DISK is
%   the representation of the disk, in the form [XC YC R], with XC and YC
%   being coordinate of disk center, and R being the radius.
%
%   DISK can also represent a collection of disks, in this case DISK is a
%   N-by-3 array, with each row of the array containing parameter of one
%   disk. 
%
%   IMG = discreteDisk(LX, LY, CENTER, RADIUS);
%   Passes disk arguments as separate parameters. 
%   CENTER is the center of the disk, given as a 1-by-2 row vector. RADIUS
%   is the radius of the disk, given as a scalar.
%
%   IMG = discreteDisk(DIM, ...);
%   send grid coordinate in a 2-by-3 array, each row contains
%   parameterization for a coordinate, in the form [x0 dx xend]. 
%   The resulting vector is created by LX = x0:dx:xend.
%
%
%   Example
%   % gives pixel coordinates as linear vectors
%   img = discreteDisk(1:100, 1:100, [50 50 30]);
%   % gives pixel coordinates as a [x0 dx xend] array.
%   img = discreteDisk([1 1 100;1 1 100], [50 50], 30);
%
%   See also:
%   imShapes, discreteEllipse, discreteSquare, discreteLune, discreteBall
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% compute coordinate of image pixels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% default parameters
center = [lx(ceil(end/2)) ly(ceil(end/2))];
radius = center(1);

% process input parameters
if isscalar(varargin)
    % all parameters bundled in first argument
    var = varargin{1};
    center = var(:,1:2);
    if size(var, 2)>2
        radius = var(:,3);
    end
elseif ~isempty(varargin)
    % parameters are given in different arguments
    center = varargin{1};
    if length(varargin) > 1
        radius = varargin{2};
    end
end

% create initial image
img = false(size(x));

% iterate over disks, and superimpose images
for i = 1:size(center, 1)
    % transforms pixels according to disk position and size
    img = img | ((x - center(i,1)).^2 + (y - center(i,2)).^2) < radius(i)^2;
end

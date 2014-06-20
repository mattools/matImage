function img = discreteDisc(varargin)
%DISCRETEDISC discretize a 3D Disc
%
%   IMG = discreteDisc(LX, LY, DISC);
%   Compute the discretized image of the disc DISC. LX and LY are two
%   vectors that contain pixel ccordinate in the reference space. DISC is
%   the represetnation of the disc, in the form [XC YC R], with XC and YC
%   being coordinate of disc center, and R being the radius.
%
%   DISC can also repreesnt a collection of discs, in this case DISC is a
%   Nx3 array, with each row of the array containing parameter of one disc.
%
%   IMG = discreteDisc(LX, LY, CENTER, RADIUS);
%   Passes disc arguments as separate parameters. 
%   CENTER is the center of the disc, given as a 1x2 row vector. RADIUS is
%   the radius of the disc, given as a scalar.
%
%   IMG = discreteDisc(DIM, ...);
%   send grid coordinate in a 2x3 array, each row contains parametrization
%   for a coordinate, in the form [x0 dx xend]. The resulting vector is
%   created by LX = x0:dx:xend.
%
%
%   Example
%   % gives pixel coordinates as linear vectors
%   img = discreteDisc(1:100, 1:100, [50 50 30]);
%   % gives pixel coordinates as a [x0 dx xend] array.
%   img = discreteDisc([1 1 100;1 1 100], [50 50], 30);
%
%   See also:
%   discreteEllipse, discreteSquare
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   04/01/2007: concatenate transforms before applying them
%   19/06/2007: udpate doc
%   30/09/2008: fix bug in computing radius for 1 input arg
%   04/03/2009: use meshgrid
%   29/04/2009: update transforms
%   29/05/2009: use more possibilities for specifying grid
%   22/01/2010: fix auto center with odd image size
%   16/06/2010: add possibility to give several discs as argument


% compute coordinate of image pixels
[lx ly varargin] = parseGridArgs(varargin{:});
[x y]   = meshgrid(lx, ly);

% default parameters
center = [lx(ceil(end/2)) ly(ceil(end/2))];
radius = center;

% process input parameters
if length(varargin)==1
    % all parameters bundled in first argument
    var = varargin{1};
    center = var(:,1:2);
    if size(var, 2)>2
        radius = var(:,3);
    end
elseif ~isempty(varargin)
    % parameters are given in different arguments
    center = varargin{1};
    if length(varargin)>1
        radius = varargin{2};
    end
end

% For a disc, radius is the same in all directions.
radius  = [radius(:,1) radius(:,1)];

% create initial image
img = false(size(x));

% iterate over discs, and superimpose images
for i=1:size(center, 1)
    % transforms voxels according to disc position and size
    tra     = createTranslation(-center(i,:));
    sca     = createScaling(1./radius(i,:));
    [x2 y2] = transformPoint(x, y, sca*tra);

    % create image: simple threshold over 3 dimensions
    img = img | hypot(x2, y2) < 1;
end
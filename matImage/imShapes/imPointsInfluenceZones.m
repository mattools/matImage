function [map, dist] = imPointsInfluenceZones(varargin)
%IMPOINTSINFLUENCEZONES Maps influence zones of a set of 2D/3D points
%
%   MAP = imPointsInfluenceZones(DIM, POINTS)
%   DIM is a 1-by-2 or 1-by-3 row vector containing dimensions of ouput
%   label map. POINTS is a N-by-2 or N-by-3 array of coordinates.
%
%   MAP = imPointsInfluenceZones(LX, LY, POINTS)
%   MAP = imPointsInfluenceZones(LX, LY, LZ, POINTS)
%   LX and LY and optionnaly LZ are row vectors containing the values of
%   XData, YData, and ZData. The size of MAP if given by:
%   * length(LY)-by-length(LX) in case of 2D points
%   * length(LY)-by-length(LX)-by-length(LZ) in case of 3D points
%
%   [MAP, DIST] = imPointsInfluenceZones(...)
%   Also returns the distance map, containing for each pixel or voxel the
%   distance to the closest point in the input point set.
%
%   Example
%     % Planar example
%     points = rand(20, 2) * 200;
%     map = imPointsInfluenceZones([200 200], points);
%     rgb = label2rgb(map, jet(20), 'w', 'shuffle');
%     figure; imshow(rgb);
%
%     % 3D example
%     dim = [100 100 100];
%     np = 200;
%     points = rand(np, 3) * dim(1);
%     tic; [map, dist] = imPointsInfluenceZones(dim, points); toc
%     rgb = label2rgb3d(map, jet(np+1), 'w', 'shuffle');
%     figure; imshow(rgb(:,:,:,50));
%
%   See also
%     imDistance, imvoronoi2d, imvoronoi3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-05-10,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.


%% Extract input arguments

% checkup on input argument number
if nargin < 2
    error('Requires at least two input arguments');
end

% extraction of image dimensions
var1 = varargin{1};
if size(var1, 1) == 1 && (size(var1, 2) == 2 || size(var1, 2) == 3)
    % first argument contains the size of the output image
    lx = 1:var1(2);
    ly = 1:var1(1);
    if length(var1) == 3
        lz = 1:var1(3);
    end
    varargin(1) = [];
    
elseif size(var1, 1) == 1 && size(varargin{2}, 1) == 1
    % first and second arguments contain vector for each coordinate
    % respectively
    lx = var1;
    ly = varargin{2};
    if size(varargin{3}, 1) == 1
        lz = varargin{3};
        varargin(1:3) = [];
    else
        varargin(1:2) = [];
    end
    
else
    error(['wrong input arguments in ' mfilename]);
end

% extraction of points
points = varargin{1};


%% Initialisations

% number of points
nPoints = size(points, 1);
nd = size(points, 2);

% size of output image
Nx = length(lx);
Ny = length(ly);


%% Generation of distance function

if nd == 2
    % allocate memory for label map
    map = zeros([Ny Nx]);
    % initialize distance map with arbitrarily large distance
    dist = inf * ones([Ny Nx]);
    
    % pixels coordinates
    [x, y] = meshgrid(lx, ly);
    
    % update distance for each point
    for i = 1:nPoints
        % squared distance from each pixel to current point
        di = (x - points(i,1)).^2 + (y - points(i,2)).^2;
        
        % update arrays for current influence zone
        inds = di < dist;
        map(inds) = i;
        dist(inds) = di(inds);
    end
    
    % convert squared distance to Euclidean distance
    dist = sqrt(dist);
    
elseif nd == 3
    % size in third dimension
    Nz = length(lz);
    
    % allocate memory for label map
    map = zeros([Ny Nx Nz]);
    
    % initialize distance map with arbitrarily large distance
    dist = inf * ones([Ny Nx Nz]);
    
    % pixels coordinates
    [x, y, z] = meshgrid(lx, ly, lz);
    
    % update distance for each point
    for i = 1:nPoints
        % distance from each pixel to current point
        di = (x - points(i,1)).^2 + (y - points(i,2)).^2 + (z - points(i,3)).^2;
        
        % update arrays for current influence zone
        inds = di < dist;
        map(inds) = i;
        dist(inds) = di(inds);
    end    
    
    % convert squared distance to Euclidean distance
    dist = sqrt(dist);
end

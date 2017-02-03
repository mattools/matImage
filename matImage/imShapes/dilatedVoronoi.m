function img = dilatedVoronoi(varargin)
%DILATEDVORONOI Simulate a 'thick' voronoi tesselation
%
%   IMG = dilatedVoronoi(LX, LY, GERMS, DIST);
%   compute the image of pixels located at a distance lower than DIST from
%   the edge of a voronoi tessellation using the array GERMS as germs.
%   LX and LY are vectors of pixel coordinates.
%
%   IMG = dilatedVoronoi(DIM, GERMS, DIST);
%   DIM can be either:
%   * a 1-by-2 row vector containing number of pixels in each direction
%   * a 2-by-3 matrix contaning starting position, position increment, and
%       end position for each coordinate
%   
%   Example
%   img = dilatedVoronoi([100 100], rand(2, 30)*100, 5);
%   imshow(img);
%
%   See also
%   imShapes, imvoronoi2d, imVoronoi3d
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/04/2005.
%

%   HISTORY 


% init and extract input information ================================

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});

germs = varargin{1};
d = varargin{2};

% x and y coordinate of each point
[x, y] = meshgrid(lx, ly);

% intialize image with zeros everywhere
img = false([2 2]);
img(length(ly), length(lx)) = 0;

% extract vertices of each edge
[vx, vy] = voronoi(germs(:,1), germs(:,2));

% create line segment for each edges of voronoi tesselation
edges   = [vx(1,:)' vy(1,:)' vx(2,:)' vy(2,:)'];

% For each edge, check points with distance less than parameter d.
for i = 1:length(edges)
    % compute distance
    dist = distancePointEdge([x(:) y(:)], edges(i, :));
    
    % keep only points in image with distance lower than threshold
    img(dist < d)=1;
end





function dist = imDistance3d(varargin)
%IMDISTANCE3D Create distance image from a set of 3D points
%
%   DIST = imDistance3d(DIM, POINTS);
%   Create a distance map of the point given by POINTS, in the image with
%   size given by DIM.
%   DIM is a 1x3 array containing number of voxels in each direction
%   POINTS is a N*3 array of double containing point coordinates
%
%   DIST = imDistance3d(LX, LY, LZ, POINTS)
%   Specify the position of vertices along each axis. See meshgrid for
%   details.
%
%   DIST = imDistance3d(..., N)
%   Use N point randomly and independently created inside the image bounds.
%
%   DIST = imDistance3d(..., EDGE)
%   Also specify edge condition. EDGE can be one of:
%   - 'free': regions touching image borders are removed
%   - 'periodic': copy the set of points to simulate periodic set
%   - 'remove': image edges will be set to distance 0, and neighbor pixels
%       set accordingly.
%
%   TODO: manage different types of distance (now is only euclidian).
%
%   Example
%   img = imDistance3d(1:100, 1:100, 1:100, ...
%       [20 20 10;90 90 90;90 10 10;10 80 80;50 50 50; 90 10 90]);
%   imshow(img(:,:,40), [0 max(max(img(:,:,40)))]);
%
%
%   TODO: manage different types of distance (now is only euclidian).
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/06/2004.
%

%   HISTORY
%   2009/03/04 switch coordinate to comply with (x,y,z) of germs
%   29/05/2009 add possibility to specify grid with meshgrid-like syntax


%% extract input arguments
% ---------------------------------------------

dim = [100 100 100];    % size of image
points = [];            % points array
N = 20;                 % default number of germs
edgecond = 'free';      % edge condition

% extraction of image dimensions
if isempty(varargin)
    % If empty arguments, use default values
    lx = 1:100;
    ly = 1:100;
    lz = 1:100;
else
    var = varargin{1};
    if size(var, 1)>2 && size(var, 2)>2
        % case of a 2x3 matrix with starting position, increment, end
        % position for each coordinate
        lx = var(1,1):var(1,2):var(1,3);
        ly = var(2,1):var(2,2):var(2,3);
        lz = var(3,1):var(3,2):var(3,3);
        varargin(1) = [];
        
    elseif size(var, 1)==1 && size(var, 2)==3
        % first argument contains maximal position for each coordinate
        lx = 1:var(1);
        ly = 1:var(2);
        lz = 1:var(3);
        varargin(1) = [];
    elseif length(varargin)>2
        % first and second arguments contain vector for each coordinate
        % respectively
        lx = varargin{1};
        ly = varargin{2};
        lz = varargin{3};
        varargin(1:3) = [];
    else
        error('wrong arguments in imDistance');
    end
end

% extraction of points, or number of points
if ~isempty(varargin)
    var = varargin{1};

    if length(var)>1
        % use an array of germs
        points = var;
    else
        % generate given number of random points
        N = var;
    end
    varargin(1) = [];
end

% extraction of edge condition
if ~isempty(varargin)
    edgecond = varargin{1};
end



%% initialisations
% ---------------------------------------------

% create array of points, if does not exist
if isempty(points)
    % generation of germs array
    points = zeros(N, 3);
    for i=1:N
        points(i,1) = rand*lx(end) + lx(1);
        points(i,2) = rand*ly(end) + ly(1);
        points(i,3) = rand*lz(end) + lz(1);
    end                        
end

% create periodic conditions if needed
if strcmp(edgecond, 'periodic')
    N = size(points, 1);
    points = repmat(points, [9 1]);
    for i=[1 2 3]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) - dim(1);
    end

    for i=[7 8 9]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) + dim(1);
    end

    for i=[1 4 7]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) - dim(2);
    end

    for i=[3 6 9]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) + dim(2);
    end    
end

N = size(points, 1);


%% Main algorithm
% ---------------------------------------------
% - first create distance function: each pixel get the distance to the
%   closest point
% - then perform watershed  


% generation of distance function

% size in each direction
Nx = length(lx);
Ny = length(ly);
Nz = length(lz);

% fill with default high value
dist = Nx*Ny*Nz*ones([Ny Nx Nz]);

% update with distance to closest point
for p=1:N
    dx = repmat(reshape(lx-points(p, 1), [1 Nx 1]), [Ny 1 Nz]);  
    dy = repmat(reshape(ly-points(p, 2), [Ny 1 1]), [1 Nx Nz]);  
    dz = repmat(reshape(lz-points(p, 3), [1 1 Nz]), [Ny Nx 1]);
    dist = min(dist, hypot(dx, hypot(dy, dz)));
end


% distance from borders of image
if strcmp(edgecond, 'remove')
    d1 = min(repmat(reshape(0:Ny-1, [Ny 1 1]), [1 Nx Nz]), ...
          repmat(reshape(Ny-1:-1:0, [Ny 1 1]), [1 Nx Nz]));
    dist = min(dist, d1);
    
    d1 = min(repmat(reshape(0:Nx-1, [1 Nx 1]), [Ny 1 Nz]), ...
          repmat(reshape(Nx-1:-1:0, [1 Nx 1]), [Ny 1 Nz]));
    dist = min(dist, d1);
    
    d1 = min(repmat(reshape(0:Nz-1, [1 1 Nz]), [Ny Nx 1]), ...
          repmat(reshape(Nz-1:-1:0, [1 1 Nz]), [Ny Nx 1]));
    dist = min(dist, d1);
end

 
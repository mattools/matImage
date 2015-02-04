function img = imvoronoi3d(varargin)
%IMVORONOI3D generate a 3D voronoi image from a set of points
%
%   IMG = imvoronoi3d(DIM, POINTS);
%   specifies the points to use as germs. POINTS is a N*3 array of double,
%   and DIM is a 1*3 row vector containing the size of the resulting image
%   in each direction.
%
%   IMG = imvoronoi3d(DIM, POINTS, BORDER);
%   Also specifies edge condition. BORDER can be one of 'free', 'periodic',
%   'remove'. See imvoronoi2d for explanation.
%
%   IMG = imvoronoi3d(DIM, N);
%   create image of size DIM (3*1 array), using N germs
%   with uniform distribution in the image space.
%
%   IMG = imvoronoi3d;
%   returns a 100*100*100 image with 20 random points as germs.
%
%   See Also
%   imVoronoi2d
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/04/2004.
%

%   HISTORY
%   09/06/2004 : correct bug for counting points
%   29/05/2009 use more possibilities for specifying grid


%% extract input arguments
% ---------------------------------------------

% compute coordinate of image voxels
[lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});

points      = [];       % points array
N           = 20;       % default number of germs
edgecond    = 'free';   % edge condition
conn        = 6;        % 6-connectivity by default in dimension 3

% extraction of points, or number of points
if ~isempty(varargin)
    var = varargin{1};

    if length(var)>1    % use an array of germs
        points = var;
    else                % get number of germs
        N = var;
    end    
end

% extraction of edge condition
if length(varargin)>1
    edgecond = varargin{2};
end


%% initialisations

% size in each direction
Nx = length(lx); 
Ny = length(ly); 
Nz = length(lz); 

% create array of points, if it does not exist
if isempty(points)
    % generation of germs array
    points = zeros(N, 2);
    for i=1:N
        points(i,1) = rand*lx(end) + lx(1);
        points(i,2) = rand*ly(end) + ly(1);
        points(i,3) = rand*lz(end) + lz(1);
    end                        
end

% create periodic conditions if needed
if strcmp(edgecond, 'periodic')
    N = size(points, 1);
    
    width = zeros(1,3);
    width(1) = lx(end)-2*lx(1)+lx(2);
    width(2) = ly(end)-2*ly(1)+ly(2);
    width(3) = lz(end)-2*lz(1)+lz(2);
    
    points = repmat(points, [27 1]);
    for i=[1 2 3 10 11 12 19 20 21]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) - width(2);
    end

    for i=[7 8 9 16 17 18 25 26 27]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) + width(2);
    end

    for i=[1 4 7 10 15 16 19 22 25]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) - width(1);
    end

    for i=[3 6 9 12 15 18 21 24 27]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) + width(1);
    end

     for i=1:9
        points((i-1)*N+1:i*N, 3) = points((i-1)*N+1:i*N, 3) - width(3);
    end

    for i=19:27
        points((i-1)*N+1:i*N, 3) = points((i-1)*N+1:i*N, 3) + width(3);
    end

end


%% Main algorithm
% * first create distance function: each pixel get the distance to the
%   closest point
% * then perform watershed  

% generation of distance function
dist = imDistance3d(dim, points);

% old function : (slower)
%distfunc = zeros(dim);
%for i=1:dim(1)
%    for j=1:dim(2)
%        for k=1:dim(3)
%            mat = points - ones(N,1)*[i j k];
%            distfunc(i, j, k) = min(sqrt(diag(mat*mat')));
%        end
%    end
%end

% use a watershed to generate cells, with 4-connectivity
img = watershed(dist, conn) ~= 0;
   

% ---------------------------------------------
% post processing

% if edge condition is 'remove', kill all cells touching borders
if strcmp(edgecond, 'remove')
    % create border image
    border = false(dim);
    border([1 Ny], :, :) = ones([2 Nx Nz]);
    border(:, [1 Nx], :) = ones([Ny 2 Nz]);
    border(:, :, [1 Nz]) = ones([Ny Nx 2]);
    
    % detect cells touching border
    border = imreconstruct(border&img, img, conn);
    
    % keep only center cells
    img = img & ~border;
end


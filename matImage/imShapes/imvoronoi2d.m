function img = imvoronoi2d(varargin)
%IMVORONOI2D generate a 2D voronoi image from a set of points
%
%   IMG = imvoronoi2d(DIM, POINTS);
%   where DIM is a 1*2 array containing the size of the image, and POINTS
%   is a N*2 array of double containing germs coordinate, build the voronoi
%   image corresponding to given germs.
%
%   IMG = imvoronoi2d(LX, LY, POINTS);
%   Specifes the coordinates of the pixels with the two row vectors LX and
%   LY.
%
%   imvoronoi2d(DIM, POINTS, BORDER)
%   Also specifies edge condition. BORDER can be one of:
%   'free'      does not modify result image
%   'periodic'  consider germs are repeated in each direction 
%   'remove'    remove cells touching borders of image
%
%   IMG = imvoronoi2d(DIM, N);
%   Creates an image of size DIM (1*2 array), using N germs with uniform
%   distribution in the image space. 
%
%   imvoronoi2d without argument return a 100*100 image with 10 random
%   points as germs.
%
%
%   Example:
%   img = imvoronoi2d([100 100], [20 50; 80 30;70 90]);
%   imshow(img);
%
%   See also
%   dilatedVoronoi, parseGridArgs
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/04/2004.
%

%   HISTORY 
%   use faster algorithm for distance function (loop on points and not on
%   pixels).
%   2008/10/10 update doc, code clean up
%   2009/03/04 switch coordinate to comply with (x,y) of germs
%   29/05/2009 use more possibilities for specifying grid


%% extract input arguments
% ---------------------------------------------

% default values
points      = [];       % points array
N           = 20;       % default number of germs
edgecond    = 'free';   % edge condition
conn        = 4;        % 4-connectivity by default in dimension 2

% compute coordinate of image voxels
[lx ly varargin] = parseGridArgs(varargin{:});

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
% ---------------------------------------------

% size in each direction
Ny = length(ly); 
Nx = length(lx); 

% create array of points, if it does not exist
if isempty(points)
    % generation of germs array
    points = zeros(N, 2);
    for i=1:N
        points(i,1) = rand*lx(end) + lx(1);
        points(i,2) = rand*ly(end) + ly(1);
    end                        
end

% create periodic conditions if needed:
% add the same point in each direction, including diagonals
if strcmp(edgecond, 'periodic')
    points = duplicateGerms(lx, ly, points);
end

% total number of points to consider
N = size(points, 1);


%% Main algorithm
% ---------------------------------------------
% - first create distance function: each pixel get the distance to the
%   closest point
% - then perform watershed  

% fill distance with a default value
dist = Nx*Ny*ones([Ny Nx]);

% update distance map with distance to closest point
for p=1:N
    dx = repmat(reshape(lx-points(p, 1), [1 Nx]), [Ny 1]);  
    dy = repmat(reshape(ly-points(p, 2), [Ny 1]), [1 Nx]);  
    dist = min(dist, hypot(dx, dy));
end
  
% use a watershed to generate cells, with 4-connectivity
img = watershed(dist, conn) ~= 0;
   

%% post processing
% ---------------------------------------------

% if edge condition is 'remove', kill all cells touching borders
if strcmp(edgecond, 'remove')
    img = removeBorderRegions(img);
end


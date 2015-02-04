function img = imAWVoronoi(varargin)
%IMAWVORONOI generate Additively Weighted Voronoi Diagram image
%
%   IMG = imAWVoronoi(DIM, N);
%   creates image of size DIM (2*1 array), using N germs
%   with uniform distribution in the image space.
%
%   IMG = imAWVoronoi(DIM, POINTS, RADII);
%   specifies the points to use as germs.
%   POINTS is a N*2 array of double containing positions of germs, and
%   RADII a N*1 array containing radius of each circle.
%
%   IMG = imAWVoronoi(DIM, POINTS, RADII, BORDER);
%   Also specifies edge condition. See imvoronoi2d for explanation.
%
%   IMG = imAWVoronoi(LX, LY, ...);
%   Specifes the pixels coordinates with the two row vectors LX and LY.
%
%   IMG = imAWVoronoi;
%   without argument return a 100*100 image with 10 random
%   points as germs.
%
%   This kind of diagram is also known as Johnson-Mehl Tesselation.
%
%
%   See also
%   imvoronoi2d, imvoronoi3d
%
%
%   Bibliography :
%   A. Okabe, B. Boots and K. Sugihara,
%   Spatial Tesselations, concepts and applications of voronoi diagrams
%   John Wiley & sons, 1992
%   Wiley series in Probability
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/05/2004.
%

%   HISTORY
%   2009/03/04 switch coordinate to comply with (x,y,z) of germs


%% extract input arguments

% default values
points      = [];       % points array
radius      = [];       % radii of circles
N           = 20;       % default number of germs
edgecond    = 'free';   % edge condition
conn        = 4;        % 4-connectivity by default in dimension 2

% compute coordinate of image voxels
[lx, ly, varargin] = parseGridArgs(varargin{:});

% extraction of points, or number of points
if ~isempty(varargin)
    var = varargin{1};

    if length(var)>1    % use an array of germs
        points = var;
    else                % get number of germs
        N = var;
    end
    
    varargin(1) = [];
end

if ~isempty(varargin)
    var = varargin{1};
    if ~ischar(var)
        radius=var;
    end
    varargin(1) = [];
end

% extraction of edge condition
if ~isempty(varargin)
    var = varargin{1};
    if ischar(var)
        edgecond = var;
    end
end


%% initialisations

% create array of points, if does not exist
if isempty(points)
    % generation of germs array
    points = zeros(N, 2);
    for i=1:N
        points(i,1) = rand*dim(1);
        points(i,2) = rand*dim(2);
    end                        
end

% create uniform radii array, if this one does not exist
if isempty(radius)
    radius = ones(size(points, 1), 1);
end

% create periodic conditions if needed
if strcmp(edgecond, 'periodic')
    points = duplicateGerms(lx, ly, points);
end
    
N = size(points, 1);


%% Main algorithm
% * first create distance function: each pixel get the distance to the
%   closest point)
% * then perform watershed  


% generation of distance function
distfunc = zeros(dim);
for i = 1:dim(1)
    for j = 1:dim(2)
        mat = points - ones(N,1) * [j i];
        distfunc(i, j) = min(sqrt(diag(mat*mat'))-radius);
    end
end
    
% use a watershed to generate cells, with 4-connectivity
img = watershed(distfunc, conn) ~= 0;
   

%% post processing
% ---------------------------------------------

% if edge condition is 'remove', kill all cells touching borders
if strcmp(edgecond, 'remove')
    img = removeBorderRegions(img);
end

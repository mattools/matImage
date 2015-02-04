function dist = imDistance(varargin)
%IMDISTANCE Distance map computed from a set of points
%
%   DIST = imDistance(DIM, POINTS);
%   Create a distance map of the point given by POINTS, in the image with
%   size given by DIM = [NY NX].
%   POINTS is a N-by-2 array of double containing point coordinates
%
%   DIST = imDistance(LX, LY, POINTS)
%   Specify the position of vertices along each axis. See meshgrid for
%   details.
%
%   DIST = imDistance(..., N)
%   Use N point randomly and independently created inside the image bounds.
%
%   DIST = imDistance(..., EDGE)
%   Also specify edge condition. EDGE can be one of:
%   - 'free': regions touching image borders are removed
%   - 'periodic': copy the set of points to simulate periodic set
%   - 'remove': image edges will be set to distance 0, and neighbor pixels
%       set accordingly.
%
%   TODO: manage different types of distance (now is only euclidian).
%
%   Example
%   % basic example with integer coordinates
%     img = imDistance([100 100], [10 10;90 90;90 10;10 90;50 50]);
%     imshow(img, [0 max(img(:))]);
%
%   % specify floating coordinates, with periodic edge conditions
%     lx = 1:100;
%     ly = 1:100;
%     pts = [10.2 10.3;90.4 90.5; 10.8 90.8;50.1 50.0]
%     img = imDistance(lx, ly, pts, 'periodic');
%     figure; imshow(img, [0 max(img(:))]);
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/06/2004.
%

%   HISTORY
%   28/06/2004 use faster algorithm
%   22/05/2006 allocate d1 and d2 only once (should be faster)
%   29/05/2009 add possibility to specify grid with meshgrid-like syntax


%% Extract input arguments

% default parameters values
points      = [];       % points array
N           = 20;       % default number of germs
edgecond    = 'free';   % edge condition
lx = 1:100;
ly = 1:100;

% extraction of image dimensions
if ~isempty(varargin)
    var = varargin{1};
    if size(var, 1) > 1 && size(var, 2) > 2
        % case of a 2x3 matrix with starting position, increment, end
        % position for each coordinate
        lx = var(1,1):var(1,2):var(1,3);
        ly = var(2,1):var(2,2):var(2,3);
        varargin(1) = [];
        
    elseif size(var, 1) == 1 && size(var, 2) == 2
        % first argument contains the size of the output image
        lx = 1:var(2);
        ly = 1:var(1);
        varargin(1) = [];
        
    elseif length(varargin) > 1
        % first and second arguments contain vector for each coordinate
        % respectively
        lx = varargin{1};
        ly = varargin{2};
        varargin(1:2) = [];
        
    else
        error('wrong input arguments in imDistance');
    end
end

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

% extraction of edge condition
if ~isempty(varargin)
    edgecond = varargin{1};
end


%% Initialisations

% create array of points, if does not exist
if isempty(points)
    % generation of germs array
    points = zeros(N, 2);
    for i = 1:N
        points(i,1) = rand * lx(end) + lx(1);
        points(i,2) = rand * ly(end) + ly(1);
    end                        
end

% number of points
N = size(points, 1);

% size of output image
Nx = length(lx);
Ny = length(ly);


% create periodic conditions if needed
if strcmp(edgecond, 'periodic')
    % compute size of the box
    wx = lx(end)  + lx(2) - 2*lx(1);
    wy = ly(end)  + ly(2) - 2*ly(1);
    
    points = repmat(points, [9 1]);
    for i = [1 2 3]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) - wx;
    end

    for i = [7 8 9]
        points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) + wx;
    end

    for i = [1 4 7]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) - wy;
    end

    for i = [3 6 9]
        points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) + wy;
    end    
    
    % re-compute number of points
    N = size(points, 1);
end


%% Generation of distance function

% allocate memory
dist = Nx * Ny * ones([Ny Nx]);

% pixels coordinates
[x, y] = meshgrid(lx, ly);

% update distance for each point
for p = 1:N
    dist = min(dist, hypot(x - points(p,1), y - points(p,2)));
end

%old algorithm, slower
%dist = zeros(dim);
%for i=1:dim(1)
    %disp (int2str(x));
    %for j=1:dim(2)
        %mat = points - ones(N,1)*[i j];
        %dist(i, j) = min(sqrt(diag(mat*mat')));
        % end
    %end


%% Optional processing for borders

% distance from borders of image
if strcmp(edgecond, 'remove')
    d1 = min(repmat((1:Ny)'-1, [1 Nx]), repmat((Ny:-1:1)'-1, [1 Nx]));
    dist = min(dist, d1);
    d1 = min(repmat((1:Nx)-1,  [Ny 1]), repmat((Nx:-1:1)-1,  [Ny 1]));
    dist = min(dist, d1);
end


 
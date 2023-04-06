function varargout = imBinaryToGraph(img)
%IMBINARYTOGRAPH Transform a binary image into a graph structure
%
%   [NODES, EDGES] = imBinaryToGraph(IMG);
%   IMG is a binary image, with structure of width 1 pixel (such as the
%   result of sketetonization)
%   NODES is a NN-by-2 array of doubles containing node coordinates
%   EDGES is a NE-by-2 array of integers, containing node indices for
%   each extremity.
%
%   GRAPH = imBinaryToGraph(IMG);
%   Returns the result as a graph structure, containing fields 'nodes' and
%   'edges'.
%
%
%   Example:
%     img = imread('circles.png');
%     skel = bwmorph(img, 'shrink', Inf);
%     [nodes, edges] = imBinaryToGraph(skel);
%     figure; imshow(skel); hold on;
%     drawGraph(nodes, edges);
%
%
%   See Also: 
%     imRAG, drawGraph
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/07/2003.
%

%   HISTORY
%   21/07/2003 uses only one loop to detect nodes and edges
%   26/01/2004 reverse direction of searching pixels in array : faster
%   10/02/2004 documentation
%   11/02/2004 supprime calcul du temps execution
%   18/01/2006 rewrite by using a label for each point, making it working
%   faster


%% Initialisation of node array

% nodes array
[y, x] = find(img > 0);
points = [x y];

% intialize empty edges array.
edges  = zeros(0, 2);


% adapt datasize of label image to the number of points.
n = length(x);
if n < 256
    typ = 'uint8';
elseif n < power(2, 16)
    typ = 'uint16';
elseif n < power(2, 32)
    typ = 'uint32';
else
    typ = 'uint64';
end

% create label image
dim = size(img);
img = zeros(dim, typ);
for i = 1:length(x)
    img(y(i), x(i)) = i;
end


%% detection of adjacent pixels

% first line 
for x = 2:dim(2)
    % continue if no point
    if img(1, x) == 0
        continue;
    end
    
    % check the point to the left
    if img(1, x-1) > 0
        edges = [edges; img(1, x) img(1, x-1)]; %#ok<*AGROW>
    end
end

% normal lines 
for y = 2:dim(1)
    
    % first point of the line 
    if img(y, 1) > 0

        % check point on the top
        if img(y-1,1) > 0
            edges = [edges; img(y, 1) img(y-1,1)];
        end

        % check point on the top-right
        if img(y-1,2) > 0
            edges = [edges; img(y, 1) img(y-1,2)];
        end
    end
    
    % each 'normal' point of the line 
    for x = 2:dim(2)-1
        if ~img(y, x)
            continue;
        end
        
        % check point on the left
        if img(y, x-1) > 0
            edges = [edges; img(y, x) img(y, x-1)];
        end

        % check point on the top-left
        if img(y-1, x-1) > 0
            edges = [edges; img(y, x) img(y-1, x-1)];
        end
        
        % check point on the top
        if img(y-1, x) > 0
            edges = [edges; img(y, x) img(y-1, x)];
        end
        
        % check point on the top-right
        if img(y-1, x+1) > 0
            edges = [edges; img(y, x) img(y-1, x+1)];
        end
        
    end
    
    % last point of the line 
    if img(y, dim(2))

        % check point on the left
        if img(y, dim(2)-1) > 0
            edges = [edges; img(y, dim(2)) img(y, dim(2)-1)];
        end
        
        % check point on the top-left
        if img(y-1, dim(2)-1) > 0
            edges = [edges; img(y, dim(2)) img(y-1, dim(2)-1)];
        end
        
        % check point on the top
        if img(y-1, dim(2)) > 0
            edges = [edges; img(y, dim(2)) img(y-1, dim(2))];
        end
    end
end


%% Format output arguments

% process output depending on how many arguments are needed
if nargout == 1
    out.nodes = points;
    out.edges = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout{1} = points;
    varargout{2} = edges;
end


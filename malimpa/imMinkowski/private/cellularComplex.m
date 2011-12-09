function varargout = cellularComplex(img, varargin)
%CELLULARCOMPLEX create cellular reconstruction of discrete image
%
%   [NODES EDGES FACES] = cellularComplex(IMG)
%   with IMG being a 2D binary image, return the graph constitued by :
%   NODES is the position of each pixel
%   EDGES is a 2 columns array, containing two ends of each edge
%   FACES is one of :
%   - a 4 column arrays, containing indices of each face. In this case, all
%   faces are square.
%   - a cell array, each cell containing an array of vertices indices.
%
%   [NODES EDGES FACES CELLS] = cellularComplex(IMG)
%   with IMG being a 3D binary image, return also the data CELLS, which is
%   a cell array containing indices of faces for each face.
%
%   GRAPH = cellularComplex(IMG)
%   return a structure GRAPH which contains following fields :
%   - nodes
%   - edges
%   - faces
%   - cells (for 3D images)
%
%   [...] = cellularComplex(IMG, CONN)
%   specifies the connectivity to use. For 2D images, it can be 4, 6 (up
%   diagonal in x-y axis) or 8. For 3D images, it can be either 6 or 26.
%
%   Cellular complex reconstruction can be visualized with 
%   drawGraph(NODES, EDGES, FACES)
%   
%   [...] = cellularComplex(IMG, CONN, RESOL)
%   Also specify grid spacing. This changes only the array of vertices.
%
%   Examples
%   img = [1 1 0;1 1 1;0 0 1];
%   [N4, E4, F4] = cellularComplex(img, 4);
%   returns : 
%   N = [1 1;1 2;2 1;2 2;3 2;3 3]
%   E = [1 3;2 4;4 5;1 2;3 4;5 6]
%   F = [1 2 4 3]
%
%   [N8, E8, F8] = cellularComplex(img, 8);
%   returns : 
%   N = [1 1;1 2;2 1;2 2;3 2;3 3]
%   E = [1 3;2 4;4 5;1 2;3 4;5 6;3 5;4 6]
%   F = {[1 2 4 3], [4 5 6], [3 4 5]}
%
%   Show results ;
%   subplot(121); imshow(img); hold on; drawGraph(N4, E4, F4);
%   subplot(122); imshow(img); hold on; drawGraph(N8, E8, F8);
%   
%   See also drawGraph
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2005-11-24
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   23/02/2006 : correct bug : creates more faces than necessary for cells
%   18/04/2006 : add connectivity 6 for 2D.
%   18/04/2006 : add connectivities 14.1 and 14.2 for 3D.

% find number of dimensions of input image
dim = size(img);
nd = length(dim);
if nd==2 && (dim(1)==1 || dim(2)==1)
    nd = 1;
end


% default value for connectivity
if nd==2
    conn = 4;
elseif nd==3
    conn = 6;
end

% process input
if length(varargin)>0
    conn = varargin{1};
end

delta = ones(1, nd);
if length(varargin)>1
    delta = varargin{2};
end

% find number of dimensions
dim = size(img);
nd = length(dim);
if nd==2 && (dim(1)==1 || dim(2)==1)
    nd = 1;
end


% switch dimension
if nd==2
    % shortcuts for image dimension
    N1 = dim(1);
    N2 = dim(2);

    % find vertices. 
    [py px] = find(img);
    nodes = [px py];

    if conn==4
        %%% 2D Image, 4 neighbors

        % faces are square (or rectangle...)
        % edges are isothetic
        edges = zeros(0, 2);
        faces = zeros(0, 4);
        
        % find horizontal edges
        ind = find(img(1:N1, 1:N2-1) & img(1:N1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x+1 y], 'rows'));
            edges = [edges; i1 i2];
        end

        % find vertical edges
        ind = find(img(1:N1-1, 1:N2) & img(2:N1, 1:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x y+1], 'rows'));
            edges = [edges; i1 i2];
        end

        % find faces
        ind = find(img(1:N1-1, 1:N2-1) & img(2:N1, 1:N2-1) & ...
                   img(1:N1-1, 2:N2) & img(2:N1, 2:N2) );
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1], 'rows'));
            i4 = find(ismember(nodes, [x+1 y],  'rows'));
            faces = [faces; i1 i2 i3 i4];
        end

    elseif conn==8
        %%% 2D Image, 8 neighbors

        % faces can be square or triangles
        % edges can be isothetic or diagonals
        edges = zeros(0, 2);
        faces = {};             % contains both squares and triangles
        squares = zeros(0, 4);  % only square faces

        
        % find horizontal edges
        ind = find(img(1:N1, 1:N2-1) & img(1:N1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x+1 y], 'rows'));
            edges = [edges; i1 i2];
        end

        % find vertical edges
        ind = find(img(1:N1-1, 1:N2) & img(2:N1, 1:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x y+1], 'rows'));
            edges = [edges; i1 i2];
        end

        % shortcuts for computations
        im1 = img(1:N1-1, 1:N2-1);
        im2 = img(1:N1-1, 2:N2);
        im3 = img(2:N1, 1:N2-1);
        im4 = img(2:N1, 2:N2);

        % find square faces
        ind = find(im1 & im2 & im3 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1], 'rows'));
            i4 = find(ismember(nodes, [x+1 y],  'rows'));
            faces = {faces{:}, [i1 i2 i3 i4]};
            squares = [squares; i1 i2 i3 i4];
        end
        
        % find triangular face
        % T1
        ind = find(im1 & im2 & im3);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        % T2
        ind = find(im1 & im2 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x+1 y],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        % T3
        ind = find(im1 & im3 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        % T4
        ind = find(im2 & im3 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x+1 y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        
        % find diagonal edges, which do not already belong to a square face
        % diagonal 1
        ind = find(img(1:N1-1, 1:N2-1) & img(2:N1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x+1 y+1], 'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2]), 2)==2)==0
                edges(size(edges, 1)+1, 1:2) = [i1 i2];
            end
        end
        % diagonal 2
        ind = find(img(2:N1, 1:N2-1) & img(1:N1-1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y+1], 'rows'));
            i2 = find(ismember(nodes, [x+1 y], 'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2]), 2)==2)==0
                edges(size(edges, 1)+1, 1:2) = [i1 i2];
            end
        end       

    elseif conn==6
        %%% 2D Image, 6 neighbors

        % faces can be square or triangles
        % edges can be isothetic or diagonals, but only one diagonal is
        % considered
        edges = zeros(0, 2);
        faces = {};             % contains both squares and triangles
        squares = zeros(0, 4);  % only square faces

        
        % find horizontal edges
        ind = find(img(1:N1, 1:N2-1) & img(1:N1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x+1 y], 'rows'));
            edges = [edges; i1 i2];
        end

        % find vertical edges
        ind = find(img(1:N1-1, 1:N2) & img(2:N1, 1:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x y+1], 'rows'));
            edges = [edges; i1 i2];
        end

        % shortcuts for computations
        im1 = img(1:N1-1, 1:N2-1);
        im2 = img(1:N1-1, 2:N2);
        im3 = img(2:N1, 1:N2-1);
        im4 = img(2:N1, 2:N2);

        % find square faces
        ind = find(im1 & im2 & im3 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1], 'rows'));
            i4 = find(ismember(nodes, [x+1 y],  'rows'));
            faces = {faces{:}, [i1 i2 i3 i4]};
            squares = [squares; i1 i2 i3 i4];
        end
        
        % find triangular face
         
        % T2
        ind = find(im1 & im2 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x+1 y],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        % T3
        ind = find(im1 & im3 & im4);
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y],    'rows'));
            i2 = find(ismember(nodes, [x y+1],  'rows'));
            i3 = find(ismember(nodes, [x+1 y+1],  'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2 i3]), 2)==3)==0
                faces = {faces{:}, [i1 i2 i3]};
            end
        end       
        
        
        % find diagonal edges, which do not already belong to a square face
        % diagonal 1
        ind = find(img(1:N1-1, 1:N2-1) & img(2:N1, 2:N2));
        for i=1:length(ind)
            [y x] = ind2sub([N1-1 N2-1], ind(i));
            i1 = find(ismember(nodes, [x y], 'rows'));
            i2 = find(ismember(nodes, [x+1 y+1], 'rows'));
            % check if already belong to a square face
            if sum(sum(ismember(squares, [i1 i2]), 2)==2)==0
                edges(size(edges, 1)+1, 1:2) = [i1 i2];
            end
        end        
        
    else
        error('undefined connectivity');
    end
    
elseif nd==3

    % shortcuts for image dimensions
    N1 = dim(1);
    N2 = dim(2);
    N3 = dim(3);
    
    % first find nodes, equivalent to pixels
    ind = find(img);
    [y x z] = ind2sub([N1 N2 N3], ind);
    nodes = sortrows([x y z], [3 2 1]);
    
    
    if conn==6
        %%% 3D Image, 6 neighbors

        edges = zeros(0, 2);
        faces = zeros(0, 4);  % only square faces
         
        % find edges in direction 1
        ind = find(img(1:N1-1, 1:N2, 1:N3) & img(2:N1, 1:N2, 1:N3));
        for i=1:length(ind)
            [y x z] = ind2sub([N1-1 N2 N3], ind(i));
            i1 = find(ismember(nodes, [x y z], 'rows'));
            i2 = find(ismember(nodes, [x y+1 z], 'rows'));
            edges = [edges ; i1 i2];
        end

        % find edges in direction 2
        ind = find(img(1:N1, 1:N2-1, 1:N3) & img(1:N1, 2:N2, 1:N3));
        for i=1:length(ind)
            [y x z] = ind2sub([N1 N2-1 N3], ind(i));
            i1 = find(ismember(nodes, [x y z], 'rows'));
            i2 = find(ismember(nodes, [x+1 y z], 'rows'));
            edges = [edges ; i1 i2];
        end
        
        % find edges in direction 3
        ind = find(img(1:N1, 1:N2, 1:N3-1) & img(1:N1, 1:N2, 2:N3));
        for i=1:length(ind)
            [y x z] = ind2sub([N1 N2 N3-1], ind(i));
            i1 = find(ismember(nodes, [x y z], 'rows'));
            i2 = find(ismember(nodes, [x y z+1], 'rows'));
            edges = [edges ; i1 i2];
        end

        % find faces in direction 1
        ind = find(img(1:N1, 1:N2-1, 1:N3-1) & img(1:N1, 1:N2-1, 2:N3) & ...
                   img(1:N1, 2:N2, 1:N3-1)   & img(1:N1, 2:N2, 2:N3) );
        for i=1:length(ind)
            [y x z] = ind2sub([N1 N2-1 N3-1], ind(i));
            i1 = find(ismember(nodes, [x y z],  'rows'));
            i2 = find(ismember(nodes, [x+1 y z], 'rows'));
            i3 = find(ismember(nodes, [x+1 y z+1], 'rows'));
            i4 = find(ismember(nodes, [x y z+1], 'rows'));
            faces = [faces; i1 i2 i3 i4];
        end

        % find faces in direction 2
        ind = find(img(1:N1-1, 1:N2, 1:N3-1) & img(1:N1-1, 1:N2, 2:N3) & ...
                   img(2:N1, 1:N2, 1:N3-1)   & img(2:N1, 1:N2, 2:N3) );
        for i=1:length(ind)
            [y x z] = ind2sub([N1-1 N2 N3-1], ind(i));
            i1 = find(ismember(nodes, [x y z], 'rows'));
            i2 = find(ismember(nodes, [x y+1 z], 'rows'));
            i3 = find(ismember(nodes, [x y+1 z+1], 'rows'));
            i4 = find(ismember(nodes, [x y z+1], 'rows'));
            faces = [faces; i1 i2 i3 i4];
        end

        % find faces in direction 3
        ind = find(img(1:N1-1, 1:N2-1, 1:N3) & img(1:N1-1, 2:N2, 1:N3) & ...
                   img(2:N1, 1:N2-1, 1:N3)   & img(2:N1, 2:N2, 1:N3) );
        for i=1:length(ind)
            [y x z] = ind2sub([N1-1 N2-1 N3], ind(i));
            i1 = find(ismember(nodes, [x y z], 'rows'));
            i2 = find(ismember(nodes, [x+1 y z], 'rows'));
            i3 = find(ismember(nodes, [x+1 y+1 z], 'rows'));
            i4 = find(ismember(nodes, [x y+1 z], 'rows'));
            faces = [faces; i1 i2 i3 i4];
        end
        
        %% Solids (for CONN=6, only cubes)
        
        cells = {};
        ind = find(img(1:N1-1, 1:N2-1, 1:N3-1)  & img(1:N1-1, 1:N2-1, 2:N3) & ...
                   img(1:N1-1,   2:N2, 1:N3-1)  & img(1:N1-1,   2:N2, 2:N3) & ...
                   img(2:N1,   1:N2-1, 1:N3-1)  & img(2:N1,   1:N2-1, 2:N3) & ...
                   img(2:N1,     2:N2, 1:N3-1)  & img(2:N1,     2:N2, 2:N3) );
        for i=1:length(ind)
            % first find indices of nodes
            [y x z] = ind2sub([N1-1 N2-1 N3], ind(i));
            i1 = find(ismember(nodes, [x y z],      'rows'));
            i2 = find(ismember(nodes, [x+1 y z],    'rows'));
            i3 = find(ismember(nodes, [x y+1 z],    'rows'));
            i4 = find(ismember(nodes, [x+1 y+1 z],  'rows'));
            i5 = find(ismember(nodes, [x y z+1],    'rows'));
            i6 = find(ismember(nodes, [x+1 y z+1],  'rows'));
            i7 = find(ismember(nodes, [x y+1 z+1],  'rows'));
            i8 = find(ismember(nodes, [x+1 y+1 z+1],'rows'));
            
            % find faces which contains 4 nodes of the previous list
            if1 = find(sum(ismember(faces, [i1 i2 i3 i4]), 2)==4);
            if2 = find(sum(ismember(faces, [i1 i2 i5 i6]), 2)==4);
            if3 = find(sum(ismember(faces, [i1 i3 i5 i7]), 2)==4);
            if4 = find(sum(ismember(faces, [i2 i4 i6 i8]), 2)==4);
            if5 = find(sum(ismember(faces, [i3 i4 i7 i8]), 2)==4);
            if6 = find(sum(ismember(faces, [i5 i6 i7 i8]), 2)==4);

            % add the new cell to the list
            cells = {cells{:}, sort([if1 if2 if3 if4 if5 if6])};
        end
        
    elseif conn==26
        %%% 3D Image, 26 neighbors        

        edges = zeros(0, 2);
        faces = {};                 % all faces (triangular + square)
        cells = {};
        
        % position of tle vertices wrt initial vertex
        pos = [...
            0 0 0; ...
            0 1 0; ...
            1 0 0; ...
            1 1 0; ...
            0 0 1; ...
            0 1 1; ...
            1 0 1; ...
            1 1 1; ...
            ];

        for z = 1:N3-1
            for x = 1:N2-1
                for y = 1:N1-1
                    
                    % find nodes of current tiles
                    indNodes = [];
                    for i=1:size(pos, 1)
                        xi = x+pos(i, 2);
                        yi = y+pos(i, 1);
                        zi = z+pos(i, 3);
                        if img(yi, xi, zi); 
                            ind = find(ismember(nodes, [xi yi zi], 'rows'));
                            indNodes = [indNodes ind];
                        end
                    end
                    
                    % nodes in current tile
                    coords = nodes(indNodes, :);                    
                    n = size(coords, 1);

                    % Check whether there is a solid in the config. There is one if there
                    % are at least 5 vertices, or 4 vertices non coplanar.
                    solid = ~isCoplanar(coords);

                    indCell = [];                    
                    if n==8
                        % special case of the cube
                        
                        % find indices of each vertex in tile
                        ind(1) = find(ismember(nodes, [x y z],      'rows'));
                        ind(2) = find(ismember(nodes, [x+1 y z],    'rows'));
                        ind(3) = find(ismember(nodes, [x y+1 z],    'rows'));
                        ind(4) = find(ismember(nodes, [x+1 y+1 z],  'rows'));
                        ind(5) = find(ismember(nodes, [x y z+1],    'rows'));
                        ind(6) = find(ismember(nodes, [x+1 y z+1],  'rows'));
                        ind(7) = find(ismember(nodes, [x y+1 z+1],  'rows'));
                        ind(8) = find(ismember(nodes, [x+1 y+1 z+1],'rows'));

                        % indices of vertices in each face
                        indFaces = [1 2 4 3;1 2 6 5;1 3 7 5;2 4 8 6;3 4 8 7;5 6 8 7];
                        
                        % try to add each face
                        for i=1:size(indFaces, 1)
                            face = ind(indFaces(i,:));
                            
                            % try to find existing face with same vertices
                            ind2 = [];
                            for j=1:length(faces)
                                if sum(ismember(faces{j}, face))==length(face)
                                    ind2 = j;
                                    break;
                                end
                            end
                            
                            % if face does not exist, create it
                            if isempty(ind2)
                                faces = {faces{:}, face};
                                ind2 = length(faces);
                            end
                            
                            % add created face to the face list of current
                            % cell
                            indCell(i) = ind2;
                        end
                        
                        % add the cell, defined by indices of faces
                        cells = {cells{:}, indCell};
                        
                        % also add 12 edges
                        edges = [edges; ...
                            indNodes(1) indNodes(2); ...
                            indNodes(1) indNodes(3); ...
                            indNodes(1) indNodes(5); ...
                            indNodes(2) indNodes(4); ...                       
                            indNodes(2) indNodes(6); ...
                            indNodes(3) indNodes(4); ...
                            indNodes(3) indNodes(7); ...
                            indNodes(4) indNodes(8); ...
                            indNodes(5) indNodes(6); ...
                            indNodes(5) indNodes(7); ...
                            indNodes(6) indNodes(8); ...
                            indNodes(7) indNodes(8); ...
                        ];
                        
                    elseif solid
                        % convex hull is a polyhedron, with triangle and
                        % square faces
                        % number of vertices can vary from 4 to 7.
                        
                        % get convex hull with only triangles
                        hull = convhulln(coords);
                        
                        % compute normals of given faces
                        planes =createPlane(coords(hull(:,1),:), coords(hull(:,2),:), coords(hull(:,3),:));
                        normals = planeNormal(planes);
                        
                        % find faces with same normals, and sharing 2
                        % vertices (-> number of unique vertices is 4)
                        indSquare = zeros([0 2]);
                        for i=1:size(normals, 1)-1
                           for j=i+1:size(normals, 1)
                               if norm(cross(normals(i, :), normals(j, :)))<1e-10 && ...
                                       length(unique([hull(i,:), hull(j,:)]))==4
                                   indSquare = [indSquare; i j];
                               end
                           end
                        end
                        
                        indCell = [];
                        
                        % process triangular faces
                        for i=1:size(hull, 1)
                            if ismember(i, indSquare)
                                continue;
                            end

                            % create the face with indices to nodes array
                            face = indNodes(hull(i,:));
                            
                            % try to find existing face with same vertices
                            ind2 = [];
                            for j=1:length(faces)
                                if sum(ismember(faces{j}, face))==length(face)
                                    ind2 = j;
                                    break;
                                end
                            end
                            
                            % if face does not exist, create it
                            if isempty(ind2)
                                faces = {faces{:}, face};
                                ind2 = length(faces);
                                % also add edges of this face (double edges
                                % will be removed at the end)
                                edges = [edges;face(1) face(2);face(2) face(3);face(3) face(1)];
                            end
                            
                            % add created face to the face list of current
                            % cell
                            indCell(i) = ind2;
                        end
                        
                        % process square faces
                        for i=1:size(indSquare, 1)
                            % find indices of vertices in square face
                            face1 = indNodes(hull(indSquare(i, 1), :));
                            face2 = indNodes(hull(indSquare(i, 2), :));
                            indFace = unique([face1 face2]);
                            
                            % sort vertices wrt angle
                            [tmp I] = angleSort3d(nodes(indFace,:));
                            face = indFace(I);
                        
                            % use convention : each face starts with the lowest
                            % index.
                            [tmp ind] = min(face);
                            face = circshift(face, [1 1-ind]);
                                                   
                            % try to find existing face with same vertices
                            ind2 = [];
                            for j=1:length(faces)
                                if sum(ismember(faces{j}, face))==length(face)
                                    ind2 = j;
                                    break;
                                end
                            end
                            
                            % if face does not exist, create it
                            if isempty(ind2)
                                faces = {faces{:}, face};
                                ind2 = length(faces);
                                % also add edges of this face (double edges
                                % will be removed at the end)
                                edges = [edges;face(1) face(2);face(2) face(3);face(3) face(4);face(4) face(1)];
                            end
                            
                            % add created face to the face list of current
                            % cell
                            indCell = [indCell ind2];                            
                        end
                        
                        % add new cell, defined by pointers to faces
                        cells = {cells{:}, indCell};
        
                    elseif n==4
                        % convex hull is a square/rectangular face
                        % create face
                        [tmp I] = angleSort3d(nodes(indNodes,:));
                        face = indNodes(I);

                        % use convention : each face starts with the lowest
                        % index.                        
                        [tmp ind] = min(face);
                        face = circshift(face, [1 1-ind]);
                        
                        % try to find existing face with same vertices
                        ind2 = [];
                        for j=1:length(faces)
                            if sum(ismember(faces{j}, face))==length(face)
                                ind2 = j;
                                break;
                            end
                        end

                        % if face does not exist, create it
                        if isempty(ind2)
                            faces = {faces{:}, face};
                        end

                    elseif n==3
                        % convex hull is a triangular face
                        face = sort(indNodes);
                        
                        % add the edges, even if they already exist
                        edges = [edges; face(1) face(2)];
                        edges = [edges; face(1) face(3)];
                        edges = [edges; face(2) face(3)];
                        
                        % try to find existing face with same vertices
                        ind2 = [];
                        for j=1:length(faces)
                            if sum(ismember(faces{j}, face))==length(face)
                                ind2 = j;
                                break;
                            end
                        end

                        % if face does not exist, create it
                        if isempty(ind2)
                            faces = {faces{:}, face};
                        end
                        
                    elseif n==2 
                        % convex hull is just an edge
                        edge = sort(indNodes);                        
                        edges = [edges; edge];
                    end
                end
            end
        end
    elseif conn==14.1 || conn==14.2
        %%% 3D Image, 14 neighbours, first variant
        
        edges = zeros(0, 2);
        faces = zeros(0, 3);  % all faces (only triangular)
        cells = {};
        
        % position of tile vertices wrt initial vertex
        % in y-x-z coordinate
        pos = [...
            0 0 0; ...
            0 1 0; ...
            1 0 0; ...
            1 1 0; ...
            0 0 1; ...
            0 1 1; ...
            1 0 1; ...
            1 1 1; ...
            ];
  
        if conn==14.1
            tetrahedra = [ ...
                1 2 4 8; ...
                1 2 6 8; ...
                1 3 4 8; ...
                1 5 6 8; ...
                1 5 7 8; ...
                1 3 7 8;
                ];
            tileFaces = [...
                1 2 4; ...
                1 2 6; ...
                1 2 8; ...
                1 3 4; ...
                1 3 7; ...
                1 3 8; ...
                1 4 8; ...
                1 5 6; ...
                1 5 7; ...
                1 5 8; ...
                1 6 8; ...
                1 7 8; ...
                2 4 8; ...
                2 6 8; ...
                3 4 8; ...
                3 7 8; ...
                5 6 8; ...
                5 7 8; ...
                ];
            tileEdges = [...
                1 2; ...
                1 3; ...
                1 4; ...
                1 5; ...
                1 6; ...
                1 7; ...
                1 8; ...
                2 4; ...
                2 6; ...
                2 8; ...
                3 4; ...
                3 7; ...
                3 8; ...
                4 8; ...
                5 6; ...
                5 7; ...
                5 8; ...
                6 8; ...
                7 8; ...
                ];
        else
            tetrahedra = [ ...
                1 2 4 6; ...
                1 3 4 8; ...
                1 3 5 8; ...
                1 4 6 8; ...
                1 5 6 8; ...
                3 5 7 8;
                ];
            tileFaces = [...
                1 2 4; ...
                1 2 6; ...
                1 3 4; ...
                1 3 5; ...
                1 3 8; ...
                1 4 6; ...
                1 4 8; ...
                1 5 6; ...
                1 5 8; ...
                1 6 8; ...
                2 4 6; ...
                3 4 8; ...
                3 5 7; ...
                3 5 8; ...
                3 7 8; ...
                4 6 8; ...
                5 6 8; ...
                5 7 8; ...
                ];
            tileEdges = [...
                1 2; ...
                1 3; ...
                1 4; ...
                1 5; ...
                1 6; ...
                1 8; ...
                2 4; ...
                2 6; ...
                3 4; ...
                3 5; ...
                3 7; ...
                3 8; ...
                4 6; ...
                4 8; ...
                5 6; ...
                5 7; ...
                5 8; ...
                7 8; ...
                ];
        end
        
        for z = 1:N3-1
            for x = 1:N2-1
                for y = 1:N1-1

                    % find nodes of current tiles
                    ind = [];
                    indNodes = [];
                    for i=1:size(pos, 1)
                        xi = x+pos(i, 2);
                        yi = y+pos(i, 1);
                        zi = z+pos(i, 3);
                        if img(yi, xi, zi);
                            ind = [ind i];
                            indNodes = [indNodes find(ismember(nodes, [xi yi zi], 'rows'))];
                        end
                    end
                    
                    % nodes in current tile
                    %coords = nodes(indNodes, :);                    
                    %n = size(coords, 1);

                    % check for edges
                    for e=1:size(tileEdges)
                        indt = ismember(ind, tileEdges(e,:));
                        if sum(indt)==2
                            edges = [edges; indNodes(indt)];
                        end
                    end

                    % check for a triangular faces
                    % They are non necessarly unique, but they are sorted
                    % later
                    for f=1:size(tileFaces)
                        indt = ismember(ind, tileFaces(f,:));
                        if sum(indt)==3
                            face = indNodes(indt);
                            % add the face only if it does not already
                            % exists
                            if isempty(faces) || ~ismember(faces, face, 'rows')
                                faces = [faces; face];
                            end
                        end
                    end
                                        
                    % check for a tetrahedra
                    for t=1:size(tetrahedra)
                        indt = find(ismember(ind, tetrahedra(t,:)));
                        if length(indt)==4
                            indF1 = find(ismember(faces, indNodes(indt([1 2 3])), 'rows'));
                            indF2 = find(ismember(faces, indNodes(indt([1 2 4])), 'rows'));
                            indF3 = find(ismember(faces, indNodes(indt([1 3 4])), 'rows'));
                            indF4 = find(ismember(faces, indNodes(indt([2 3 4])), 'rows'));
                            cells = {cells{:}, [indF1, indF2, indF3, indF4]};
                        end
                    end
        
                end
            end
        end                
    end
end

% clean up variables
nodes = nodes.*repmat(delta, [size(nodes, 1) 1]);
edges = unique(sort(edges, 2), 'rows');

%% process output arguments
if nargout==1
    graph.nodes = nodes;
    graph.edges = edges;
    graph.faces = faces;
    if exist('cells', 'var')
        graph.cells = cells;
    end
    varargout{1} = graph;
    
elseif nargout==2
    varargout{1} = nodes;
    varargout{2} = edges;
    
elseif nargout==3    
    varargout{1} = nodes;
    varargout{2} = edges;
    varargout{3} = faces;
    
elseif nargout==4
    varargout{1} = nodes;
    varargout{2} = edges;
    varargout{3} = faces;
    varargout{4} = cells;
end


function varargout = angleSort3d(pts, varargin)
%ANGLESORT3D sort 3D coplanar points according to their angles in plane
%
%
%   PTS2 = angleSort3d(PTS);
%   Consider all points are located on the same plane, and sort them
%   according to the angle on plane. PTS is a [Nx2] array.
%
%   PTS2 = angleSort3d(PTS, PTS0);
%   Compute angles between each point of PTS and PT0. By default, uses
%   centroid of points.
%
%   PTS2 = angleSort3d(PTS, PTS0, PTS1);
%   Specifies the point which will be used as a start.
%
%   [PTS2, I] = angleSort3d(...);
%   Also return in I the indices of PTS, such that PTS2 = PTS(I, :);
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2005-11-24
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


%   HISTORY :

% default values
pt0     = mean(pts, 1);
pt1     = pts(1,:);

if length(varargin)==1
    pt0 = varargin{1};
elseif length(varargin)==2
    pt0 = varargin{1};
    pt1 = varargin{2};
end

% create support plane
plane   = createPlane(pts(1:3, :));

% project points onto the plane
pts2d   = planePosition(pts, plane);
pt0     = planePosition(pt0, plane);
pt1     = planePosition(pt1, plane);

% compute origin angle
theta0  = atan2(pt1(2)-pt0(2), pt1(1)-pt0(1));
theta0  = mod(theta0 + 2*pi, 2*pi);

% translate to reference point
n       = size(pts, 1);
pts2d   = pts2d - repmat(pt0, [n 1]);

% compute angles
angle   = atan2(pts2d(:,2), pts2d(:,1));
angle   = mod(angle - theta0 + 4*pi, 2*pi);

% sort points according to angles
[tmp, I] = sort(angle);


% format output
if nargout<2
    varargout{1} = pts(I, :);
elseif nargout==2
    varargout{1} = pts(I, :);
    varargout{2} = I;
end



function plane = createPlane(varargin)
%CREATEPLANE create a plane in parametrized form
%
%   Create a plane in the following format : 
%   PLANE = [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%   
%
%
%   PLANE = createPlane(P1, P2, P3) 
%   create a plane containing the 3 points
%
%   PLANE = createPlane(PTS) 
%   The 3 points are packed into a single 3x3 array.
%
%   PLANE = createPlane(P0, N);
%   create a plane from a point and from a normal to the plane.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY :
%   24/11/2005 : add possibility to pack points for plane creation

if length(varargin)==1
    var = varargin{1};
    
    if iscell(var)
        plane = zeros([0 9]);
        for i=1:length(var)
            plane = [plane; createPlane(var{i})];
        end
    elseif size(var, 1)==3
        % 3 points in a single array
        p1 = var(1,:);
        p2 = var(2,:);
        p3 = var(3,:);
        
        % create direction vectors
        v1 = p2-p1;
        v2 = p3-p1;

        % create plane
        plane = [p1 v1 v2];
        return;
    end
    
elseif length(varargin)==2
    
    p0 = varargin{1};
    
    var = varargin{2};
    if size(var, 2)==2
        n = sph2cart2([var repmat(1, [size(var, 1) 1])]);
    elseif size(var, 2)==3
        n  = normalize3d(var);
    else
        error ('wrong number of parameters in createPlane');
    end
    
    % find a vector not colinear to the normal
    v0 = repmat([1 0 0], [size(p0, 1) 1]);    
    if abs(cross(n, v0, 2))<1e-14
        v0 = repmat([0 1 0], [size(p0, 1) 1]);
    end
    
    % create direction vectors
    v1 = normalize3d(cross(n, v0, 2));
    v2 = -normalize3d(cross(v1, n, 2));
    
    plane = [p0 v1 v2];
    return;
    
elseif length(varargin)==3
    p1 = varargin{1};    
    p2 = varargin{2};
    p3 = varargin{3};
    
    % create direction vectors
    v1 = p2-p1;
    v2 = p3-p1;
   
    plane = [p1 v1 v2];
    return;
  
else
    error('wrong number of arguments in "createPlane".');
end

function vn = normalize3d(v)
%NORMALIZE3D normalize a 3D vector, such that its norm equals 1.

n = sqrt(v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3));
vn = v./[n n n];


function n = planeNormal(plane)
%PLANENORMAL compute the normal to a plane
%
%   N = planeNormal(PLANE) 
%   compute the normal of the given plane
%   PLANE : [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   N : [dx dy dz]
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/02/2005.
%

%   HISTORY


% plane normal
n = cross(plane(:,4:6), plane(:, 7:9), 2);

function pos = planePosition(point, plane)
%PLANEPOSITION compute position of a point on a plane
%
%   PT2 = PLANEPOSITION(POINT, PLANE)
%   POINT has format [X Y Z], and plane has format
%   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%
%   Result PT2 has the form [XP YP], with [XP YP] coordinate of the point
%   in the coordinate system of the plane.
%
%   
%   CAUTION :
%   WORKS ONLY FOR PLANES WITH ORTHOGONAL DIRECTION VECTORS
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY :
%   24/11/2005 add support for multiple input

% unify size of data
if size(point, 1)~=size(plane, 1)
    if size(point, 1)==1
        point = repmat(point, [size(plane, 1) 1]);
    elseif size(plane, 1)==1
        plane = repmat(plane, [size(point, 1) 1]);
    else
        error('point and plane do not have the same dimension');
    end
end


p0 = plane(:,1:3);
d1 = plane(:,4:6);
d2 = plane(:,7:9);

s = dot(point-p0, d1, 2)./vecnorm3d(d1);
t = dot(point-p0, d2, 2)./vecnorm3d(d2);

pos = [s t];

function varargout = sph2cart2(varargin)
%SPH2CART2 convert spherical coordinate to cartesian coordinate
%
%   usage :
%   C = SPH2CART2(S)
%   C = SPH2CART2(PHI, THETA)       (assume rho = 1)
%   C = SPH2CART2(PHI, THETA, RHO)   
%   [X, Y, Z] = SPH2CART2(PHI, THETA, RHO);
%
%   S = [phi theta rho] (sphercial coordiante).
%   C = [X Y Z]  (cartesian coordinate)
%
%   Math convention is used : theta is angle with vertical, 0 for north
%   pole, +pi for south pole, pi/2 for points with z=0.
%   phi is the same as matlab cart2sph : angle from Ox axis, counted
%   counter-clockwise.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   22/03/2005 : make test for 2 args, and add radius if not specified for
%       1 arg.

if length(varargin)==1
    var = varargin{1};
    if size(var, 2)==2
        var = [var ones(size(var, 1), 1)];
    end
elseif length(varargin)==2
    var = [varargin{1} varargin{2} ones(size(varargin{1}))];
elseif length(varargin)==3
    var = [varargin{1} varargin{2} varargin{3}];
end

[x y z] = sph2cart(var(:,1), pi/2-var(:,2), var(:,3));

if nargout == 1 || nargout == 0
    varargout{1} = [x, y, z];
else
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end

function n = vecnorm3d(v)
%VECNORM3D compute norm of vector or of set of 3D vectors
n = sqrt(sum(v.*v, 2));


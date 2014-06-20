function alpha = complexNormalAngle(varargin)
%COMPLEXNORMALANGLE compute normal angle of a vertex of a cellular complex
%
%   ALPHA = complexNormalAngle(NODES, EDGES, FACES, INDEX)
%   ALPHA = complexNormalAngle(NODES, EDGES, FACES, CELLS, INDEX)
%   Compute the nortmal angle of the polyhedral reconstruction defined be
%   nodes NODES, edges EDGES and faces FACES. For 3D reconstructions, it
%   can also contain cells CELLS. INDEX is the index of NODES for which the
%   normal angle ALPHA is computed.
%   Result is normalised between 0 and 2*PI.
%
%   ALPHA = complexNormalAngle(GRAPH, INDEX)
%   Internal data are stored in a structure GRAPH, with fields : 'nodes',
%   'edges', 'faces', and eventually 'cells'.
%
%   
%   ALPHA = complexNormalAngle(..., INDICES)
%   If INDICES is an array of indices, the normal angle is computed for
%   each element of NODES(INDICES,:). The result ALPHA has the same size
%   than INDICES.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2005-12-19
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   2006-04-19 fix bug for small number of faces
%   2006-04-26 returns 0 and not [] for null complexes
%   2006-10-25 revert to return value=[] for null complex
%   2008-08-11 code clean up


cells = [];
if length(varargin)==4
    % no cells in cellular complex
    nodes = varargin{1};
    edges = varargin{2};
    faces = varargin{3};
    ind   = varargin{4};
    
elseif length(varargin)==5
    % cells are given
    nodes = varargin{1};
    edges = varargin{2};
    faces = varargin{3};
    cells = varargin{4};
    ind   = varargin{5};
    
elseif length(varargin)==2
    % data stored as structure
    graph = varargin{1};
    nodes = graph.nodes;
    edges = graph.edges;
    faces = graph.faces;
    if isfield(graph, 'cells')
        cells = graph.cells;
    end
    ind   = varargin{2};
else
    error('wrong number of arguments');
end


alpha0 = zeros([length(ind) 1]);
alpha1 = zeros([length(ind) 1]);
alpha2 = zeros([length(ind) 1]);
alpha3 = zeros([length(ind) 1]);
alpha = [];

if size(nodes, 2)==2
    % 2 dimensions
    
    if iscell(faces)

        % process faces as cell array
        for i=1:length(ind)
            % check that vertex is contained in the complex
            if ind(i)>size(nodes, 1)
                continue;
            end
            
            % normal angle of vertex
            alpha0(i) = 2*pi;

            % normal angle of edges
            alpha1(i) = length(find(sum(edges==ind(i), 2)))*pi;

            % normal angle of faces
            alpha2(i) = 0;
            for j=1:length(faces)
                face = faces{j};
                indf = find(face==ind(i));
                
                if ~isempty(indf)
                    alpha2(i) = alpha2(i) + polygonNormalAngle(nodes(face,:), indf);
                end
            end
        end

    else
        % process faces as arrays
        for i=1:length(ind)

            % check that vertex is contained in the complex
            if ind(i)>size(nodes, 1)
                continue;
            end

            % normal angle of vertex
            alpha0(i) = 2*pi;

            % normal angle of edges
            alpha1(i) = length(find(sum(edges==ind(i), 2)))*pi;

            % normal angle of faces
            alpha2(i) = 0;
            for j=1:size(faces, 1)
                face = faces(j,:);
                indf = find(face==ind(i));
                
                if ~isempty(indf)
                    alpha2(i) = alpha2(i) + polygonNormalAngle(nodes(face,:), indf);
                end
            end
            
        end
    end
    
    % compute total normal angle of reconstruction
    alpha = alpha0 - alpha1 + alpha2;

elseif size(nodes, 2)==3
    % 3 dimensions
    for i=1:length(ind)
        
        % check that vertex is contained in the complex
        if ind(i)>size(nodes, 1)
            continue;
        end        

        % normal angle of vertex
        alpha0(i) = 4*pi;

        % normal angle of edges
        alpha1(i) = length(find(sum(edges==ind(i), 2)))*2*pi;

        % normal angle of faces
        alpha2(i) = 0;
        if iscell(faces)
            % process faces as cell array
            for j=1:length(faces)
                face = faces{j};
                indf = find(face==ind(i));

                if ~isempty(indf)
                    alpha2(i) = alpha2(i) + polygon3dNormalAngle(nodes(face,:), indf);
                end
            end
            
        else
            % process faces as array of double
            for j=1:size(faces, 1)
                face = faces(j,:);
                indf = find(face==ind(i));
                
                if ~isempty(indf)
                    alpha2(i) = alpha2(i) + polygon3dNormalAngle(nodes(face,:), indf);
                end
            end
        end

        % normal angle of cells
        alpha3(i) = 0;
        for j=1:length(cells)
            cell = cells{j};
            if iscell(faces)
                cellFaces = faces(cell);
            else
                cellFaces = faces(cell, :);
            end

            alpha3(i) = alpha3(i) + polyhedronNormalAngle(nodes, cellFaces, ind(i));
        end
         
        % compute total normal angle of reconstruction
        alpha = alpha0 - alpha1 + alpha2 - alpha3;
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set of internal functions, for angle computations in 2D and 3D

function theta = polygonNormalAngle(points, ind)
%POLYGONNORMALANGLE compute normal angle at a vertex of the polygon

% number of points
np = size(points, 1);

% number of angles to compute
nv = length(ind);

theta = zeros(nv, 1);

for i=1:nv
    p0 = points(ind(i), :);
    
    % previous vertex
    if ind(i)==1
        p1 = points(np, :);
    else
        p1 = points(ind(i)-1, :);
    end
    
    % next vertex
    if ind(i)==np
        p2 = points(1, :);
    else
        p2 = points(ind(i)+1, :);
    end
    
    % compute angles
    theta1  = mod(atan2(p1(2)-p0(2), p1(1)-p0(1)) + 2*pi, 2*pi);
    theta2  = mod(atan2(p2(2)-p0(2), p2(1)-p0(1)) + 2*pi, 2*pi);
    dtheta  = mod(theta2-theta1+2*pi, 2*pi);
    
    % use simplification due to the fact that cells are convex
    dtheta  = min(dtheta, 2*pi-dtheta);
    theta(i)= pi - dtheta;    
end

return;



function theta = polyhedronNormalAngle(nodes, faces, ind)
%POLYHEDRONNORMALANGLE compute normal angle at a vertex of a 3D polyhedron
%
%   THETA = polyhedronNormalAngle(NODES, FACES, IND);
%   where NODES is a set of 3D points, and FACES a set of faces, whose
%   elements are indices to NODES array, compute the normal angle at the
%   vertex whose index is given by IND.


% number of angles to compute
na = length(ind);

theta = zeros(na, 1);
for i=1:na
    
    % find faces containing given vertex,
    % and compute normal angle at each face containing vertex
    if iscell(faces)
        for j=1:length(faces)
            if ismember(ind(i), faces{j})
                % create 3D polygon
                face = nodes(faces{j}, :);
                
                % index of point in polygon
                indp = find(faces{j}==ind(i));
                
                % compute face angle
                thetaf = [thetaf polygon3dInnerAngle(face, indp)];
            end
        end
    else
        indf = find(sum(ismember(faces, ind(i)), 2));
        
        thetaf = zeros(length(indf), 1);
        for j=1:length(indf)
            ind2 = faces(indf(j), :);
            face = nodes(ind2, :);
            indp = find(ind2==ind(i));
            thetaf(j) = polygon3dInnerAngle(face, indp);
        end
    end

    % compute normal angle of polyhedron, by use of angle defect formula
    if ~isempty(thetaf)
        theta(i) = 2*pi - sum(thetaf);
    end    
end

return;


function theta = polygon3dNormalAngle(points, ind)
%POLYGON3DNORMALANGLE compute normal angle at a vertex of the 3D polygon

    
theta = 2*pi - 2*polygon3dInnerAngle(points, ind);

return;


function theta = polygon3dInnerAngle(points, ind)
%POLYGON3DNORMALANGLE compute normal angle at a vertex of the 3D polygon

% number of points
np = size(points, 1);

% number of angles to compute
nv = length(ind);

theta = zeros(nv, 1);

for i=1:nv
    p0 = points(ind(i), :);
    
    % previous vertex
    if ind(i)==1
        p1 = points(np, :);
    else
        p1 = points(ind(i)-1, :);
    end
    
    % next vertex
    if ind(i)==np
        p2 = points(1, :);
    else
        p2 = points(ind(i)+1, :);
    end
    
    theta(i) = angle3d(p1, p0, p2);
    theta(i) = min(theta(i), 2*pi-theta(i));
    % todo: solve case for CW oriented polygons
end

return;


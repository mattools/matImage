function graph = graphStructure(nodes, edges, varargin)
%GRAPHSTRUCTURE create a graph structure from nodes, edges... arrays
%
%   GRAPH = graphStructure(NODES, EDGES);
%   GRAPH = graphStructure(NODES, EDGES, FACES);
%   GRAPH = graphStructure(NODES, EDGES, FACES, CELLS);
%   inputs are :
%   - NODES is coordinate of each graph vertex , this a [NNx2] or [NNx3]
%   array
%   - EDGES is a set of pointer to the first and second vertices of each
%   edge
%   - FACES is either a [NFx3], [NFx4]... array, when all faces have same
%   number of vertices, or a cell array of length NF
%   - CELLS is a set of pointers to faces.
%
%
%   See also drawGraph
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2005-11-24
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

graph.nodes = nodes;
graph.edges = edges;

if ~isempty(varargin)
    graph.faces = varargin{1};
else
    graph.faces = zeros(0, 4);
end

if length(varargin)>1
    graph.cells = varargin{2};
else
    graph.cells = zeros(0, 3);
end

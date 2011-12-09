function [nodes2, edges2] = removeNode(nodes, edges, node)
%REMOVENODE remove a node in a graph, and return the modified graph
% 
%   usage :
%   [NODES2 EDGES2] = removeNode(NODES, EDGES, NODE2REMOVE)
%   remove the node with index NODE2REMOVE from array NODES, and also
%   remove edges containing the node NODE2REMOVE.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY :
%   10/02/2004 : doc


% remove all edges connected to the node 
neighbours = getNeighbourNodes(node, edges);
[nodes2, edges2] = removeEdges(nodes, edges, neighbours);


% change edges information, due to the node index shift
for i=1:length(edges2)
    if(edges2(i,1)>node)
        edges2(i,1) = edges2(i,1)-1;
    end
    if(edges2(i,2)>node)
        edges2(i,2) = edges2(i,2)-1;
    end
end

% allocate memory
dim = size(nodes);
nodes2 = zeros(dim(1)-1, 2);

% copy nodes information, except the undesired node
nodes2(1:node-1, :) = nodes(1:node-1, :);
nodes2(node:dim(1)-1, :) = nodes(node+1:dim(1), :);

function [nodes2, edges2] = removeEdges(nodes, edges, rmEdges)
%REMOVEEDGES remove several edges from a graph
%
%   [NODES2 EDGES2] = removeEdges(NODES, EDGES, EDGES2REMOVE)
%   Remove some edges in the edges list, and return the modified graph.
%   The NODES array is not modified.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY :
%   10/02/2004 : doc


rmEdges = sort(rmEdges);

% don't change the node list
nodes2 = nodes;

% allocate memory for new  edges list
dim = size(edges);
N = dim(1);
NR = length(rmEdges);
N2 = N-NR;
edges2 = zeros(N2, 2);

if NR==0
    nodes2 = nodes;
    edges2 = edges;
    return;
end

% process the first edge
edges2(1:rmEdges(1)-1,:) = edges(1:rmEdges(1)-1,:);

% process the classical edges
for i=2:NR    
    %if rmEdges(i)-i < rmEdges(i-1)-i+2 
    %    continue;
    %end
    edges2(rmEdges(i-1)-i+2:rmEdges(i)-i, :) = edges(rmEdges(i-1)+1:rmEdges(i)-1, :);
end

% process the last edge
edges2(rmEdges(NR)-NR+1:N2, :) = edges(rmEdges(NR)+1:N, :);

return;

function [nodes2, edges2] = mergeNodesMedian(nodes, edges, mnodes)
%MERGENODESMEDIAN merge nodes in a graph
%
%   [NODES2 EDGES2] = mergeNodesMedian(NODES, EDGES, NODES2MERGE)
%   NODES ans EDGES are the graph structure, and NODES2MERGE is the list of
%   indices of nodes to be merged.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation


x = median(nodes(mnodes, 1));
y = median(nodes(mnodes, 2));
refNode = findPoint(nodes, [x y]);
mnodes = sort(mnodes(mnodes~=refNode));

for n=1:length(mnodes)
    node = mnodes(n);
    
    % process each neighbour of the current node
    neighbours = getNeighbourNodes(node, edges);
    for e = 1:length(neighbours)
        edge = neighbours(e);
        
        if edges(edge, 1)==refNode || edges(edge, 2)==refNode
            continue;
        end

        % find if the node is referenced as 1 or 2 in the edge,
        % and replace it with the reference node.
        if edges(edge, 1)== node
            edges(edge, 1) = refNode;
        else
            edges(edge, 2) = refNode;
        end  
        
    end
end   

% remove nodes from the list, except the reference node.
for n=1:length(mnodes)
    [nodes edges] = removeNode(nodes, edges, mnodes(n)-n+1);
end

nodes2 = nodes;
edges2 = edges;

    
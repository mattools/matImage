function varargout = simplifyLines(nodes, edges)
%SIMPLIFYLINES replace each path between n-points by a single edge
%
%   [NODES2 EDGES2] = SIMPLIFYLINES(NODES, EDGES)
%   replace each line with multiple 2-degrees nodes by a single 
%   edge with 2 nodes of degree 3+.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY :
%   10/02/2004 : doc



n=1;
while n<length(nodes)
    neigh = getNeighbourNodes(n, edges);
    if length(neigh)==2
        % find other node of first edge
        edge = edges(neigh(1), :);
        if edge(1) == n
            node1 = edge(2);
        else
            node1 = edge(1);
        end

        % replace current node in the edge by the other node
        % of first edge
        edge = edges(neigh(2), :);
        if edge(1)==n
            edges(neigh(2), 1) = node1;
        else
            edges(neigh(2), 2) = node1;
        end
        
        [nodes edges] = removeNode(nodes, edges, n);
        continue
    end
    n=n+1;
end

% process output depending on how many arguments are needed
if nargout == 1
    out{1} = nodes;
    out{2} = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout{1} = nodes;
    varargout{2} = edges;
end

return;

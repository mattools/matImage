function neigh = getNeighbourEdges(node, edges)
%GETNEIGHBOUREDGES find edges adjacent to a given node
%
%   NEIGHS = getNeighbourEdges(NODE, EDGES)
%   NODE : index of the node
%   EDGES : the complete edges list
%   NEIGHS : the indices of edges containing the node index
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation
%   13/07/2004 : faster algorithm
%   17/01/2006 : rename and change implementation

neigh = find(edges(:,1)==node | edges(:,2)==node);

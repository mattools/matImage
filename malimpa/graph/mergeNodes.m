function [nodes, edges] = mergeNodes(nodes, edges, mnodes)
%MERGENODES merge two (or more) nodes in a graph.
%
% usage :
%   [NODES2 EDGES2] = mergeNodes(NODES, EDGES, NODES2MERGE)
%   NODES et EDGES sont le graphe d'adjacence de la partition.
%   B1 sont les indices de 2 bassins versants, avec B1 qui inonde B2.
%
%   NODES2 et EDGES2 sont une nouvelle partition de l'image, telle que les
%   regions B1 et B2 soient fusionnees. Cela implique :
%   - suppression de(s) arete(s) entre B1 et B2
%   - fusion des aretes communes a B1 ou B2 et d'autres regions.
%
%   Ex : fusion des regions A et B
%   Edges :         Edges2 :
%   [A D]           [A D]
%   [A B]           [A C]
%   [A C]           [C D]
%   [B C]
%   [C D]
%   
%
%   See also : imRAG
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 30/06/2004.
%

refNode = mnodes(1);
mnodes = mnodes(2:length(mnodes));


% replace merged nodes references by references to refNode
edges(ismember(edges, mnodes))=refNode;

% remove edges between 
edges = edges(edges(:,1)~=refNode | edges(:,2)~=refNode, :);

% format output
edges = sortrows(unique(sort(edges, 2), 'rows'));


return
    
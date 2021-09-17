function [res, fusion] = imMergeEnclosedRegions(lbl, varargin)
% Merge regions within a label image, based on an inclusion criteria.
%
%   Merge regions in an image. Criterion is a inclusion criterion: if a
%   region is mostly within the convex image of a neighbor region, then the
%   two region merge.
%
%	See Also
%	  imMergeRegions, imRAG
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-09-17,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2021 INRAE.

%   HISTORY
%   17/08/2004 create as independant function, and merge 2D and 3D cases
%   17/09/2021 rename as imMergeEnclosedRegions


%% Parse input arguments

% create default structuring element
se = zeros([3 3 3]);
se(1,2,2) = 1;
se(3,2,2) = 1;
se(2,:,:) = [0 1 0;1 1 1;0 1 0];

verbose = true;
while length(varargin) > 1
    name = varargin{1};
    if strcmp(name, 'verbose')
        verbose = varargin{2};
    else
        error('Can not interpret input option: %s', name);
    end
    varargin(1:2) = [];
end


%% Initialisations

% init
res = lbl;

% compute adjacency graph
% (use a wrong node list, because of memory problems, but dont really need
% it)
if verbose
    disp('compute adjacency graph');
end
lastLabel = double(max(lbl(:)));
nodes = [(1:lastLabel)';(1:lastLabel)'];
edges = imRAG(lbl);


% compute volume of each cell
if verbose
    disp('compute area');
end
area = zeros(lastLabel, 1);
for i = 1:lastLabel
    area(i) = sum(lbl(:)==i);
end

% init fusion information
fusion = [];

for i = 1:lastLabel
    if verbose
        disp(sprintf('cell: %d/%d', i, lastLabel)); %#ok<DSPS>
    end
    
    % check:
    %   1 - cell still exist
    %   2 - cell is large enough (as some problem can occur in convexImage)
    if area(i) < 10
        continue;
    end

    % compute convex image of current cell
    im = imConvexImage(lbl==i);
    
    % find neighbours
    neigh = unique(edges(edges(:,1)==i | edges(:,2)==i, 1:2));
    neigh = neigh(neigh~=i);
    
    mergeFlag = false;
    for i2 = 1:length(neigh)
        % compute area
        common = sum(im(:)&res(:) == neigh(i2));
        if common / area(neigh(i2)) > .7
            disp(sprintf('fusion of regions %d and %d', i, neigh(i2))); %#ok<DSPS>

            % update RAG and fusion process information
            [nodes, edges] = grMergeNodes(nodes, edges, [i neigh(i2)]);
            fusion(size(fusion, 1)+1, 1:2) = [i neigh(i2)]; %#ok<AGROW>
            
            % update result image
            res(res==neigh(i2)) = i;
            mergeFlag = true;
        end
    end
    
    % fill in the space between merged regions
    if mergeFlag
        res(imerode(imclose(res==i, se), se)) = i;
    end
end
    
function [nodes, edges] = grMergeNodes(nodes, edges, mnodes)
% Merge two (or more) nodes in a graph.
%
% Usage:
%   [NODES2 EDGES2] = grMergeNodes(NODES, EDGES, NODE_INDS)
%   NODES and EDGES are wo arrays representing a graph, and NODE_INDS is
%   the set of indices of the nodes to merge.
%   The nodes corresponding to indices in NODE_INDS are removed from the
%   list, and edges between two nodes are removed.
%
%   Example: merging of labels 1 and 2
%   Edges:         Edges2:
%   [1 2]           [1 3]
%   [1 3]           [1 4]
%   [1 4]           [3 4]
%   [2 3]
%   [3 4]
%   

refNode = mnodes(1);
mnodes = mnodes(2:length(mnodes));

% replace merged nodes references by references to refNode
edges(ismember(edges, mnodes))=refNode;

% remove "loop edges" from and to reference node
edges = edges(edges(:,1) ~= refNode | edges(:,2) ~= refNode, :);

% format output
edges = sortrows(unique(sort(edges, 2), 'rows'));


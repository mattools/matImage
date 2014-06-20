function res = mergeRegions(lbl, varargin)
%MERGEREGIONS Merge regions of labeled image, using inclusion criteria
%
%   Merge regions in an image. Criterion is a inclusion criterion: if a
%   region is mostly within the convex image of a neighbor region, then the
%   two region merge.
%
%	See Also
%	imMergeLabels, imMergeCells, imRAG
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 14/01/2004
%

%   HISTORY
%   17/08/2004 create as independant function, and merge 2D and 3D cases

res = lbl;

% compute adjacency graph
% (use a wrong node list, because of memory problems, but dont really need
% it)
disp('compute adjacency graph');
n = double(max(lbl(:)));
nodes = [(1:n)';(1:n)'];
edges = imRAG(lbl);


% compute volume of each cell
disp('compute area');
area = zeros(n, 1);
for i=1:n
    area(i) = sum(lbl(:)==i);
end

fusion = [];
%se = ones([3 3 3]);
se = zeros([3 3 3]);
se(1,2,2) = 1;
se(3,2,2) = 1;
se(2,:,:) = [0 1 0;1 1 1;0 1 0];

for i=1:n
    disp(sprintf('cellule : %d/%d', i, n));
    
    % check :
    %   1 - cell still exist
    %   2 - cell is big enough (some problem can occur in convexImage). 
    if area(i)<10
        continue;
    end

    % compute convex image of current cell
    im = convexImage(lbl==i);
    
    % find neighbours
    neigh = unique(edges(edges(:,1)==i | edges(:,2)==i, 1:2));
    neigh = neigh(neigh~=i);
    
    ok=0;
    for i2=1:length(neigh)
        
        common = sum(im(:)&res(:)==neigh(i2));
        if common/area(neigh(i2))>.7
            disp(sprintf('fusion %d et %d', i, neigh(i2)));

            % update RAG and fusion process information
            [nodes edges] = mergeNodes(nodes, edges, [i neigh(i2)]);
            fusion(size(fusion, 1)+1, 1:2) = [i neigh(i2)];
            
            % update result image
            %ind = regionsBoundary(res, i, neigh(i2));
            res(res==neigh(i2)) = i;
            %res(ind) = i;
            ok = 1;
        end
    end
    
    % remplit l'espace entre les cellules fusionnees
    if ok
        res(imerode(imclose(res==i, se), se)) = i;
    end
     
end
    

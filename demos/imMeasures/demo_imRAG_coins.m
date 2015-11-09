%DEMO_IMRAG_COINS  One-line description here, please.
%
%   output = demo_imRAG_coins(input)
%
%   Example
%   demo_imRAG_coins
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-10-22,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2015 INRA - Cepia Software Platform.


%% Read input image

img = imread('coins.png');

% make binary, and remove noise
bin = imopen(img > 80, ones(3, 3));
imshow(bin);


%% Compute Skeleton by Influence Zone (SKIZ)

% distance function
dist = bwdist(bin);
imshow(dist, []); title('distance function');

% compute watershed
distf = imfilter(dist, ones(3, 3)/9, inf);
wat = watershed(distf, 4);

% superposition of watershed on original image
ovr = imOverlay(img, imdilate(wat==0, ones(3, 3)));

% display result
figure;
imshow(ovr);
title('watershed');


%% Region adjacency graph

% Compute RAG
[nodeList, edgeList] = imRAG(wat);

% diplay RAG with surimpression
hold on;
for i = 1:size(edgeList, 1)
    edge = edgeList(i,:);
    plot(nodeList(edge, 1), nodeList(edge, 2), 'linewidth', 2, 'color', 'g');
end
% draw region nodes
plot(nodeList(:,1), nodeList(:,2), 'bo');


%% evaluate boundary statistics 
% use morpho math operations, so this couldbe slow.
% However, need to iterate over couples of neighbor edges, so it is faster
% than testing all pairs of regions.

nEdges = size(edgeList, 1);
stats = zeros(nEdges, 4);
stats(:, 1:2) = edgeList;

tic
se= [0 1 0;1 1 1;0 1 0];
for iEdge = 1:size(edgeList, 1)
    edge = edgeList(iEdge,:);
    im1 = imdilate(wat == edge(1), se);
    im2 = imdilate(wat == edge(2), se);
    bnd = im1 & im2;
    
    stats(iEdge, 3) = sum(bnd(:));
    stats(iEdge, 4) = mean(img(bnd));
end
toc

% display result using blank image as backgroundfigure; 
imshow(ones(size(img)));
hold on;
for iEdge = 1:size(edgeList, 1)
    edge = edgeList(iEdge,:);
    plot(nodeList(edge, 1), nodeList(edge, 2), 'linewidth', 1, 'color', 'b');
    pos = (nodeList(edge(1), :) + nodeList(edge(2), :)) / 2;
    text(pos(1)+2, pos(2)+2, sprintf('%d', stats(iEdge, 3)));
end
title('Using regions dilation');


%% The same using adjacency infos

% Compute RAG
tic;
[nodeList, edgeList, edgeIndsList] = imRAG(wat);

% allocate memory for results, still using 2 columns
stats2 = zeros(nEdges, 2);

% for each edge, grablist of indices, compute length an average value
% within grayscale image
for iEdge = 1:nEdges
    inds = edgeIndsList{iEdge};
    stats2(iEdge, 3) = length(inds);
    stats2(iEdge, 4) = mean(img(inds));
end
toc

% display result using blank image as background
figure; imshow(ones(size(img)));
hold on;
for iEdge = 1:size(edgeList, 1)
    edge = edgeList(iEdge,:);
    plot(nodeList(edge, 1), nodeList(edge, 2), 'linewidth', 1, 'color', 'b');
    pos = (nodeList(edge(1), :) + nodeList(edge(2), :)) / 2;
    text(pos(1)+2, pos(2)+2, sprintf('%d', stats2(iEdge, 3)));
end
title('Using transitions detection');

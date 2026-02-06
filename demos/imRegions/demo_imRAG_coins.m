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
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-02-06,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

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
title('Regions');


%% Region adjacency graph

% Compute RAG
[v, e] = imRAG(wat);

% diplay RAG with surimpression
hold on;
for i = 1:size(e, 1)
    plot(v(e(i,:), 1), v(e(i,:), 2), 'linewidth', 2, 'color', 'g');
end
plot(v(:,1), v(:,2), 'bo');

% print(gcf, 'imRAG_coins.png', '-dpng')
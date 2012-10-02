%DEMOIMFERETDIAMETER  One-line description here, please.
%
%   output = demoImFeretDiameter(input)
%
%   Example
%   demoImFeretDiameter
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-02-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%% Segmentation de l'image

% image de depart
img = imread('rice.png');
figure(1); clf;
imshow(img);

% calcul du fond
bg = imopen(img, ones(30, 30));
img2 = img - bg;
figure(2); clf;
imshow(img2);


% affiche histogramme pour identifier seuil
figure(3); clf;
imHistogram(img2);

% binarisation de l'image
bin = img2>50;
bin = imclearborder(bin, 4);
imshow(bin);

% labelise l'image, avec connexité minimale
lbl = bwlabel(bin, 4);
nLabels = max(lbl(:));

% affiche une image labelisee
rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
figure(4); clf;
imshow(rgb);


%% Calcul des diametres de Feret

% liste de directions pour le calcul de Feret
nTheta = 200;
theta = linspace(0, 180, nTheta+1);
theta = theta(1:end-1);

% calcule les diametres de feret
fd = imFeretDiameter(lbl, theta);

% calcule le diametre max
[fdMax indMax] = max(fd, [], 2);

% indices des diametres a 90 du max
indMax2 = mod(indMax + nTheta/2-1, nTheta) + 1;

% tableau des diametres de Feret a 90 degre du max
fd90 = zeros(size(fdMax));
for i=1:size(fd, 1)
    fd90(i) = fd(i, indMax2(i));
end

%% Essaie de trouver rectangle englobant

% calcule le diametre min
[fdMin indMin] = min(fd, [], 2);

%DEMOIMSHAPES2D Display various 2D demo shapes
%
%   output = demoShapes2d(input)
%
%   Example
%   demoImShapes
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% initialisations

% generate cubic images
lx = 1:100;
ly = 1:100;

% choose a center not aligned with the grid
center = [50+sqrt(2)-1 50+sqrt(3)-1];

angles = [...
    0; ...
    10; ...
    30; ...
    45];



%% Disc

% sphere is defined by center and radius
disc = [center 40];

% generation of 3D image
img = discreteDisc(lx, ly, disc);

% display image
f = figure; 
imshow(~img);
    
% decorate
title('Disc, radius=40');


%% Ellipse

figure;
for i = 1:4
    % sphere is defined by center and radius
    ellipse = [center 40 20 angles(i)];

    % generation of 3D image
    img = discreteEllipse(lx, ly, ellipse);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Ellipse, Th=%02d', angles(i)));
end


%% Square

figure;
for i = 1:4
    % sphere is defined by center and radius
    square = [center 60 angles(i)];

    % generation of 3D image
    img = discreteSquare(lx, ly, square);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Square, Th=%02d', angles(i)));
end


%% Rectangle

figure;
for i = 1:4
    % sphere is defined by center and radius
    rect = [center 60 30 angles(i)];

    % generation of 3D image
    img = discreteRectangle(lx, ly, rect);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Rectangle, Th=%02d', angles(i)));
end


%% Capsule

figure;
for i = 1:4
    % sphere is defined by center and radius
    [dx dy] = pol2cart(deg2rad(angles(i)), 30);
    caps = [center-[dx dy] center+[dx dy] 15];

    % generation of 3D image
    img = discreteCapsule(lx, ly, caps);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Capsule, Th=%02d', angles(i)));
end


%% Egg

figure;
for i = 1:4
    % egg defined by a center, a size and an angle
    egg = [center 30 angles(i)];

    % generation of 3D image
    img = discreteEgg(lx, ly, egg);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Egg, Th=%02d', angles(i)));
end


%% Trefoil

figure;
for i = 1:4
    % trefoil defined by a center, two radii and an angle
    trefoil = [center 40 15 angles(i)];

    % generation of 3D image
    img = discreteTrefoil(lx, ly, trefoil);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Trefoil, Th=%02d', angles(i)));
end


%% Starfish

figure;
for i = 1:4
    % starfish defined by a center, two radii and an angle
    starfish = [center 40 20 angles(i)];

    % generation of 3D image
    img = discreteStarfish(lx, ly, starfish);

    % display image
    subplot(2, 2, i); 
    imshow(~img);

    % decorate
    title(sprintf('Starfish, Th=%02d', angles(i)));
end





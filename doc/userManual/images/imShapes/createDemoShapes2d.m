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

% generate square images
lx = 1:100;
ly = 1:100;

% choose a center not aligned with the grid
center = [50+sqrt(2)-1 50+sqrt(3)-1];

theta = -30;


%% Disc

% sphere is defined by center and radius
disc = [center 40];

% generation of 3D image
img = discreteDisc(lx, ly, disc);

% save image
imwrite(uint8(~img)*255, 'disk.png');
    


%% Ellipse

% ellipse is defined by center, two radius and orientation
ellipse = [center 40 20 theta];

% generation of 3D image
img = discreteEllipse(lx, ly, ellipse);

imwrite(uint8(~img)*255, 'ellipse_theta30.png');


%% Square

% square is defined by center, side length and orientation
square = [center 60 theta];

% generation of 3D image
img = discreteSquare(lx, ly, square);

% save image
imwrite(uint8(~img)*255, 'square_theta30.png');


%% Rectangle

% rectangle is defined by center, two side lengths, and orientation
rect = [center 60 30 theta];

% generation of 3D image
img = discreteRectangle(lx, ly, rect);

% save image
imwrite(uint8(~img)*255, 'rectangle_theta30.png');


%% Capsule

% sphere is defined by center and radius
[dx, dy] = pol2cart(deg2rad(theta), 30);
caps = [center-[dx dy] center+[dx dy] 15];

% generation of 3D image
img = discreteCapsule(lx, ly, caps);

% save image
imwrite(uint8(~img)*255, 'capsule_theta30.png');


%% Egg

% egg defined by a center, a size and an angle
egg = [center 30 theta];

% generation of 3D image
img = discreteEgg(lx, ly, egg);

% save image
imwrite(uint8(~img)*255, 'egg_theta30.png');


%% Trefoil

% trefoil defined by a center, two radii and an angle
trefoil = [center 40 15 theta];

% generation of 3D image
img = discreteTrefoil(lx, ly, trefoil);

% save image
imwrite(uint8(~img)*255, 'trefoil_theta30.png');


%% Starfish

% starfish defined by a center, two radii and an angle
starfish = [center 40 20 theta];

% generation of 3D image
img = discreteStarfish(lx, ly, starfish);

% save image
imwrite(uint8(~img)*255, 'starfish_theta30.png');




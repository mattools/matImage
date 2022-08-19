%DEMOIMSHAPES Display various 3D demo shapes
%
%   output = demoImShapes(input)
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
lz = 1:100;

% choose a center not aligned with the grid
center = [50+sqrt(2)-1 50+sqrt(3)-1 50+sqrt(5)-2];

angles = [30 0];

% ellipsoid orientations in format YAW PITCH ROLL
orient = [ 30  -30   0];


%% Ball

% sphere is defined by center and radius
sphere = [center 40];

% generation of 3D image
img = discreteBall(lx, ly, lz, sphere);

% display image isosurface
f = figure; set(gca, 'fontsize', 14);
isosurface(img, .5);
    
% setup display
hold on; axis equal; light;
axis ([0 100 0 100 0 100]);
view([40 20]);
print(gcf, 'ball_R40.png', '-dpng');


%% Ellipsoid

clf;

elli = [center 50 30 10 orient];

% generation of 3D image
img = discreteEllipsoid(lx, ly, lz, elli);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([0 100 0 100 0 100]);
view([40 20]);

% decorate
strTitle = sprintf('Ellipsoid, ori=[%d %d %d]', orient);
title(strTitle);

print(gcf, 'ellipsoid_A50_B30_C10_Y30_P30_R00.png', '-dpng');


%% Cuboid

clf;

cubo = [center 90 40 10 orient];

% generation of 3D image
img = discreteCuboid(lx, ly, lz, cubo);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([0 100 10 90  20 80]);
view([40 20]);

% decorate
strTitle = sprintf('Cuboid, ori=[%d %d %d]', orient);
title(strTitle);

print(gcf, 'cuboid_A90_B40_C10_Y30_P30_R00.png', '-dpng');



%% Cube

% cube representation
cube = [center 60 orient];

% generation of 3D image
img = discreteCube(lx, ly, lz, cube);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([0 100 0 100 0 100]);
view([40 20]);

% decorate
strTitle = sprintf('Cube, ori=[%d %d %d]', orient);
title(strTitle);

print(gcf, 'cube_S60_Y30_P30_R00.png', '-dpng');



%% Torus

torus = [center 30 10 angles];

% generation of 3D image
img = discreteTorus(lx, ly, lz, torus);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([0 100 10 90  20 80]);
view([40 20]);

% decorate
strTitle = sprintf('Torus, ori=[%d %d]', angles);
title(strTitle);

print(gcf, 'torus_A30_B10_Y30_P00_R00.png', '-dpng');


%% Cylinder

clf;

% cylinder representation
cart = sph2cart2d(angles);
p1 = center - 30*cart;
p2 = center + 30*cart;
cyl = [p1 p2 10];

% generation of 3D image
img = discreteCylinder(lx, ly, lz, cyl);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([20 80 20 80 0 100]);
view([40 20]);

% decorate
strTitle = sprintf('Cylinder, ori=[%d %d]', angles);
title(strTitle);

print(gcf, 'cylinder_L60_R10_T30_P00.png', '-dpng');


%% Capsule 3D

clf;

% cylinder representation
cart = sph2cart2d(angles);
p1 = center - 30*cart;
p2 = center + 30*cart;
caps = [p1 p2 15];

% generation of 3D image
img = discreteCapsule3d(lx, ly, lz, caps);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal; light;
axis ([0 100 0 100 0 100]);
view([40 20]);

% decorate
strTitle = sprintf('Capsule 3D, ori=[%d %d]', angles);
title(strTitle);

print(gcf, 'capsule_L60_R15_T30_P00.png', '-dpng');


%% Revolution of Reuleaux Triangle

clf;

% cylinder representation
reuleaux = [center 80 angles];

% generation of 3D image
img = discreteReuleauxRevol(lx, ly, lz, reuleaux);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal;
l = light('Position', [0 1 -1], 'Style', 'infinite');
axis ([0 100 0 100 0 100]);
view([40 20]);
set(gca, 'ydir', 'reverse');
set(gca, 'zdir', 'reverse');

% decorate
strTitle = sprintf('Reuleaux, ori=[%d %d]', angles);
title(strTitle);

print(gcf, 'reuleaux_R80_T30_P00.png', '-dpng');


%% Sphere Eight

clf;

% sphere eighth representation
spheight = [center 40 [10 -80]];
% generation of 3D image
img = discreteSphereEighth(lx, ly, lz, spheight);

% display image isosurface
clf; set(gca, 'fontsize', 14);
patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');

% setup display
hold on; axis equal;
l = light('Position', [0 1 -1], 'Style', 'infinite');
axis ([35 95 0 60 40 100]);
view([40 20]);
set(gca, 'ydir', 'reverse');
set(gca, 'zdir', 'reverse');

% decorate
strTitle = sprintf('Sphere Eights, ori=[%d %d]', [10 -80]);
title(strTitle);

print(gcf, 'spheighth_R40_T10_P80.png', '-dpng');


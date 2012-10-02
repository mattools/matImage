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

angles = [...
    0 0; ...
    30 0; ...
    30 30];

% set of ellipsoid orientations, in format YAW PITCH ROLL
orientations = [...
     0   0   0; ...
    30   0   0; ...
    30  30   0; ...
    30  30  30];


%% Ball

% sphere is defined by center and radius
sphere = [center 40];

% generation of 3D image
img = discreteBall(lx, ly, lz, sphere);

% display image isosurface
f = figure; set(gca, 'fontsize', 14);
isosurface(img, .5);
    
% setup display
hold on; axis equal; l = light;
axis ([0 100 0 100 0 100]);
view([40 20]);
snapnow;


%% Ellipsoid

clf;

% iterate on orientations
for i = 1:4
    elli = [center 50 30 10 orientations(i, :)];
    
    % generation of 3D image
    img = discreteEllipsoid(lx, ly, lz, elli);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([0 100 10 90  20 80]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Ellipsoid, ori=[%d %d %d]', orientations(i, :));
    title(strTitle);

    snapnow;
end


%% Cuboid

clf;

% iterate on orientations
for i = 1:4
    cubo = [center 90 40 10 orientations(i, :)];
    
    % generation of 3D image
    img = discreteCuboid(lx, ly, lz, cubo);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([0 100 10 90  20 80]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Cuboid, ori=[%d %d %d]', orientations(i, :));
    title(strTitle);

    snapnow;
end



%% Cube

% iterate on orientations
for i = 1:4
    
    % cylinder representation
    cube = [center 60 orientations(i, :)];
    
    % generation of 3D image
    img = discreteCube(lx, ly, lz, cube);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([0 100 0 100 0 100]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Cube, ori=[%d %d %d]', orientations(i, :));
    title(strTitle);

    snapnow;
end



%% Torus

% iterate on orientations
for i = 1:3
    torus = [center 30 10 angles(i, :)];
    
    % generation of 3D image
    img = discreteTorus(lx, ly, lz, torus);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([0 100 10 90  20 80]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Torus, ori=[%d %d]', angles(i, :));
    title(strTitle);

    snapnow;
end


%% Cylinder

clf;

% iterate on orientations
for i = 1:3
    
    % cylinder representation
    cart = sph2cart2d(angles(i, :));
    p1 = center - 30*cart;
    p2 = center + 30*cart;
    cyl = [p1 p2 10];
    
    % generation of 3D image
    img = discreteCylinder(lx, ly, lz, cyl);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([20 80 20 80 0 100]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Cylinder, ori=[%d %d]', angles(i, :));
    title(strTitle);

    snapnow;
end


%% Capsule 3D

clf;

% iterate on orientations
for i = 1:3
    
    % cylinder representation
    cart = sph2cart2d(angles(i, :));
    p1 = center - 30*cart;
    p2 = center + 30*cart;
    caps = [p1 p2 15];
    
    % generation of 3D image
    img = discreteCapsule3d(lx, ly, lz, caps);
    
    % display image isosurface
    clf; set(gca, 'fontsize', 14);
    patch(isosurface(img, .5), 'FaceColor', 'g', 'LineStyle', 'none');
        
    % setup display
    hold on; axis equal; l = light;
    axis ([0 100 0 100 0 100]);
    view([40 20]);
 
    % decorate
    strTitle = sprintf('Capsule 3D, ori=[%d %d]', angles(i, :));
    title(strTitle);

    snapnow;
end


%% Revolution of Reuleaux Triangle

clf;

% iterate on orientations
for i = 1:3
    
    % cylinder representation
    reuleaux = [center 80 angles(i, :)];
    
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
    strTitle = sprintf('Cylinder, ori=[%d %d]', angles(i, :));
    title(strTitle);

    snapnow;
end


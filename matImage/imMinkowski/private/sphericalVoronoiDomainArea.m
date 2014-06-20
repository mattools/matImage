function area = sphericalVoronoiDomainArea(refPoint, neighbors)
%SPHERICALVORONOIDOMAINAREA Compute area of a spherical voronoi domain
%
%   AREA = sphericalVoronoiDomainArea(GERM, NEIGHBORS)
%   GERM is a 1-by-3 row vector representing cartesian coordinates of a
%   point on the sphere (in X, Y Z order)
%   NEIGHBORS is a N-by-3 array representing cartesian coordinates of the
%   germ neighbors. It is expected that NEIGHBORS contains only neighbors
%   that effectively contribute to the voronoi domain.
%
%   Example
%   sphericalVoronoiDomainArea
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-11-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% reference sphere
sphere = [0 0 0 1];

% number of neigbors, and number of sides of the domain
nbSides = size(neighbors, 1);

% compute planes containing separating circles
planes = zeros(nbSides, 9);
for i=1:nbSides
    planes(i,1:9) = normalizePlane(medianPlane(refPoint, neighbors(i,:)));
end

% allocate memory
lines       = zeros(nbSides, 6);
intersects  = zeros(2*nbSides, 3);

% compute circle-circle intersections
for i=1:nbSides
    lines(i,1:6) = intersectPlanes(planes(i,:), ...
        planes(mod(i,nbSides)+1,:));
    intersects(2*i-1:2*i,1:3) = intersectLineSphere(lines(i,:), sphere);
end

% keep only points in the same direction than refPoint
ind = dot(intersects, repmat(refPoint, [2*nbSides 1]), 2)>0;
intersects = intersects(ind,:);
nbSides = size(intersects, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles = zeros(nbSides, 1);
for i=1:nbSides
    pt1 = intersects(i, :);
    pt2 = intersects(mod(i  , nbSides)+1, :);
    pt3 = intersects(mod(i+1, nbSides)+1, :);
    
    angles(i) = sphericalAngle(pt1, pt2, pt3);
    angles(i) = min(angles(i), 2*pi-angles(i));
end

% compute area of spherical polygon
area = sum(angles) - pi*(nbSides-2);

% IMSHAPES Generation of images representing geometric shapes
% Version 1.1 01-Jul-2011 .
%
%   This module contains several function for creating synthetic images of
%   common shapes, in 2D (ellipses, rectangles...), or in 3D (balls and
%   ellipsoids, cuboids, torus...).
%   Such discrete representation can be used as phantom to test and / or
%   validate algorithms of binary images measurements.
%
%   Requires the 'geom2d', the 'geom3d', and the 'imFilters' toolboxes.
% 
% Shapes 2D:
%   discretePoints         - Discretize a set of points
%   discreteDisc           - Discretize a disc
%   discreteEllipse        - Discretize a planar ellipse
%   discreteSquare         - Discretize a planar square
%   discreteRectangle      - Discretize a planar rectangle
%   discreteCapsule        - Discretize a planar capsule
%   discretePolygon        - Discretize a planar polygon
%   discretePolyline       - Discretize a planar polyline
%   discreteHalfPlane      - Discretize a half plane
%   discreteParabola       - Discretize a planar parabola
%   discreteEgg            - Discretize a planar egg
%   discreteStarfish       - Discretize a starfish curve
%   discreteTrefoil        - Discretize a trefoil curve
%   discreteCurve          - Discretize a planar curve
%
% Shapes 3D:
%   discreteBall           - Discretize a 3D Ball
%   discreteHalfBall       - discretize a 3D half-ball
%   discreteEllipsoid      - discretize a 3D ellipsoid
%   discreteCuboid         - discretize a 3D cuboid
%   discreteCube           - discretize a 3D cube
%   discreteTorus          - Discretize a 3D Torus
%   discreteCylinder       - Discretize a 3D cylinder
%   discreteCapsule3d      - Create binary image of a 3D capsule
%   discreteReuleauxRevol  - Discretize the revolution of a Reuleaux triangle
%   discreteSphereEighth   - Discretize a 3D sphere eighth
%
% Tessellations:
%   imPointsInfluenceZones - Maps influence zones of a set of 2D/3D points
%   imvoronoi2d            - Generate a 2D voronoi image from a set of points
%   imvoronoi3d            - generate a 3D voronoi image from a set of points
%   dilatedVoronoi         - Simulate a 'thick' voronoi tesselation
%   imAWVoronoi            - generate Additively Weighted Voronoi Diagram image
%   imPowerDiagram         - Power diagramm of a set of points
%
%
% Author: David Legland
% e-mail: david.legland@inra.fr
% http://github.com/mattools/matImage
% Copyright 2009 INRA - Cepia Software Platform.

help('imShapes');



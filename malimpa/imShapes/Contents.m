% IMSHAPES Generation of images representing geometric shapes
% Version 1.1 01-Jul-2011 .
%
%   Requires the 'geom2d', the 'geom3d', and the 'imFilters' toolboxes.
% 
% Shapes 2D:
%   discretePoints        - discretize a set of points
%   discreteDisc          - discretize a 3D Disc
%   discreteEllipse       - discretize a planar ellipse
%   discreteSquare        - discretize a planar square
%   discreteRectangle     - discretize a planar rectangle
%   discreteCapsule       - Create binary image of a planar capsule
%   discretePolygon       - discretize a planar polygon
%   discretePolyline      - discretize a planar polyline
%   discreteHalfPlane     - discretize a half plane
%   discreteParabola      - discretize a planar parabola
%   discreteEgg           - Create a discrete image of egg
%   discreteStarfish      - Discretize a starfish curve
%   discreteTrefoil       - Discretize a trefoil curve
%   discreteCurve         - discretize a planar curve
%
% Shapes 3D:
%   discreteBall          - discretize a 3D Ball
%   discreteHalfBall      - discretize a 3D half-ball
%   discreteEllipsoid     - discretize a 3D ellipsoid
%   discreteCuboid        - discretize a 3D cuboid
%   discreteCube          - discretize a 3D cube
%   discreteTorus         - discretize a 3D Torus
%   discreteCylinder      - discretize a 3D cylinder
%   discreteCapsule3d     - Create binary image of a 3D capsule
%   discreteReuleauxRevol - discretize the revolution of a Reuleaux triangle
%
% Tessellations:
%   imvoronoi2d           - generate a 2D voronoi image from a set of points
%   imvoronoi3d           - generate a 3D voronoi image from a set of points
%   dilatedVoronoi        - simulate a 'thick' voronoi tesselation
%   imAWVoronoi           - generate Additively Weighted Voronoi Diagram image
%   imPowerDiagram        - power diagramm of a set of points
%
%
% -----
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 19/04/2004.
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the BSD License, see the file license.txt

help('imShapes');


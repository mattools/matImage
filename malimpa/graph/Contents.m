% GRAPH Simple Toolbox for manipulating Geometric Graphs
% FILTERS Generic filters for image processing
% Version 0.5 11-Apr-2010 .
%
%   The aim of this package is to provides functions to easily create,  
%   modify and display geometric graphs (geometric in a sense position
%   of vertices is kept in memory).
%
%   Graph structure is represented by at least two arrays:
%   NODES, which contains coordinates of each vertex
%   EDGES, which contains indices of start and end vertex.
%
%   Others arrays may sometimes be used:
%   FACES, which contains indices of vertices of each face (either a double
%   array, or a cell array)
%   CELLS, wich contains indices of faces of each cell.
%
%   An alternative representation is to use a structure, with fields:
%   * edges
%   * faces
%   * cells
%   corresponding to the data described above.
%
%   Note that topological description of 2D graph is entirely contained in
%   EDGES array, and that NODES array is used only to display graph
%   
%   Caution: this type of data structure is easy to create and to manage,
%   but may be very inefficient for some algorithms. 
%
%   Graphs are usually considered as non-oriented in this package.
%
%
% Graph creation
%   knnGraph                - Create the k-nearest neighbors graph of a set of points
%   graphStructure          - create a graph structure from nodes, edges... arrays
%   imageGraph              - create equivalent graph of the image
%   boundaryGraph           - get boundary of image as a graph
%   gcontour2d              - creates contour graph of a 2D binary image.
%   gcontour3d              - creates contour graph of a 3D binary image.
%   vectorize               - transform a binary skeleton into a graph (nodes and edges)
%
% Graph information
%   getNodeDegree           - return degree of a node in a (undirected) graph
%   getNodeInnerDegree      - return inner degree of a node in a graph
%   getNodeOuterDegree      - return outer degree of a node in a graph
%   getNeighbourNodes       - find nodes adjacent to a given node
%   getNeighbourEdges       - find edges adjacent to a given node
%   getOppositeNode         - Return opposite node in an edge
%
% Graph management (low level operations)
%   addFace                 - add a (square) face defined from its vertices to a graph.
%   removeNode              - remove a node in a graph, and return the modified graph
%   removeNodes             - remove some nodes in a graph, and return the modified graph
%   removeEdge              - remove an edge in a graph.
%   removeEdges             - remove several edges from a graph
%   removeDoubleEdges       - remove edges sharing two same extremities
%
% Graph distances
%   grPropagateDistance     - Propagates distances from a vertex to other vertices
%   grVertexEccentricity    - Eccentricity of vertices in the graph
%   graphCenter             - Center of a graph
%   graphDiameter           - Diameter of a graph
%   graphRadius             - Radius of a graph
%   graphPeripheralVertices - Peripheral vertices of a graph
%
% Graph processing (general applications)
%   mergeGraphs             - merge two graphs, by adding nodes, edges and faces lists. 
%   mergeNodes              - merge two (or more) nodes in a graph.
%   mergeNodesMedian        - merge nodes in a graph
%   simplifyGraph           - simplify graph by removing multiple vertices
%   simplifyLines           - replace each path between n-points by a single edge
%   prim                    - minimal spanning tree by Prim's algorithm
%
% Operations for geometric graphs
%   euclideanMST            - build euclidean minimal spanning tree of a set of points
%   clipGraph               - clip a graph with a rectangular area
%   findPoint               - find index of a point in an array from its coordinates
%   getGraphFace            - return face of a graph as a 2D or 3D polygon
%
% Voronoi Graphs
%   boundedVoronoi2d        - return the voronoi diagram as a graph structure
%   voronoi2d               - return the voronoi diagram as a graph structure
%   centroidalVoronoi2d     - create a Centroidal Voronoi Tesselation
%   cvtIterate              - update germs of a CVT using random points with given density
%   cvtUpdate               - update germs of a CVT with given points
%
% Filtering operations on Graph
%   grLabel                 - associate a label to each connected component of the graph
%   grMean                  - compute mean from neihgbours
%   grMedian                - compute median from neihgbours
%   grClose                 - morphological closing on graph
%   grDilate                - morphological dilation on graph
%   grErode                 - morphological erosion on graph
%   grOpen                  - morphological opening on graph
%
% Graph processing (specific applications)
%   removeMultiplePoints    - remove special triangle configurations in a graph
%   minGraph                - merge all edges between 2-degrees nodes.
%   detectePoints           - detect triple points in a binary image
%   detectePoints2          - detect triple points of boundary in a labeled image
%   cleanGraph              - return a 'cleaned' graph.
%
% Graph display
%   drawGraph               - draw a graph, given as a set of vertices and edges
%   drawGraphEdges          - draw edges of a graph
%   drawGraphFaces          - draw faces of a graph
%   drawDigraph             - draw a directed graph, given as a set of vertices and edges
%   drawDirectedEdges       - draw edges with arrow indicating direction
%   drawEdgeLabels          - draw values associated to graph edges
%   drawNodeLabels          - draw values associated to graph nodes
%   graph2Contours          - convert a graph to a set of contour curves
%   drawSquareMesh          - transform 3D graph (mesh) into patch
%   patchGraph              - transform 3D graph (mesh) into patch
%
%
% -----
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the  07/11/2005.
% Copyright INRA - Cepia Software Platform.
% http://www.pfl-cepia.inra.fr/index.php?page=imael
% Licensed under the terms of the BSD License, see the file license.txt

  
% HISTORY
% 25/07/2007 remove old functions
% 27/07/2007 integrate headers of other functions
% 27/07/2007 add MST by prim algo, and EuclideanMST
% 24/08/2010 code cleanup
% 07/09/2010 add functions for computing geodesic distances 

%   quiverToGraph           - Converts quiver data to quad mesh

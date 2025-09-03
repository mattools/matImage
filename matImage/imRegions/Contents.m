% IMMEASURES Analysis of digital images
% Version 1.1 01-Jul-2011 .
%
%   Provides several functions for measurements on digital images. Most
%   functions are simple wrappers that manage 3D and/or color images, as
%   well as eventual type conversion.
%   Some geometrical measures are provided as well, for description of
%   particles in binary or in label images.
%
% Regions / particles analysis
%   imCentroid            - Centroid of regions in a label image.
%   imBoundingBox         - Bounding box of regions within a 2D or 3D binary or label image.
%   imEquivalentEllipse   - Equivalent ellipse of a binary or label image.
%   imEquivalentEllipsoid - Equivalent ellipsoid of a 3D binary image.
%   imInscribedCircle     - Maximal circle inscribed in a region.
%   imInscribedBall       - Maximal ball inscribed in a 3D region.
%   imEnclosingCircle     - Minimal enclosing circle of a region.
%   imOrientedBox         - Minimum-width oriented bounding box of regions in image.
%   imFeretDiameter       - Feret diameter of region(s) for a given direction(s).
%   imMaxFeretDiameter    - Maximum Feret diameter of a binary or label image.
%   imConvexity           - Convexity of regions within a 2D or 3D label image.
%   imRegionFun           - Apply a function to each region of a label image
%
% Region moments
%   imPrincipalAxes       - Computes principal axes of a 2D/3D binary image.
%   imMoment              - Compute simple moment(s) of an image
%   imCMoment             - Compute centered moment of an image
%   imCSMoment            - Compute centered and scaled moments of an image.
%   imHuInvariants        - Compute Hu's invariant for a 2D image.
%
%   Operators for label images:
%   label2rgb3d             - Convert a 3D label image to a 3D RGB image.
%   imLabelToValue          - Convert label image to parametric map
%   imKillBorderRegions     - Remove regions on the border of an image
%   imAreaOpening           - Remove all regions smaller than a given area
%   imAttributeOpening      - Filter regions on a size or shape criterium
%   imSeparateParticles     - Separate touching particles using watershed algorithm
%   imLargestRegion         - Keep the largest region within a binary or label image.
%   imCropLabel             - Extract the portion of image that contains the specified label
%   imMergeRegions          - Merge adajcent regions in a label image.
%   imMergeEnclosedRegions  - Merge regions within a label image, based on an inclusion criteria.
%   imBoundaryIndices       - Find indices of boundary between 2 cells
%   imLabelEdges            - Label edges between adjacent regions of labeled image.
%
% Extract geometric primitives
%   imFind                - Return coordinates of non-zero pixels in an image
%   imRAG                 - Region adjacency graph (RAG) of a label image.
%   imBoundaryContours    - Extract polygonal contours of a binary image.
%   imContourLines        - Extract iso contours of an image as polylines.
%   imBinaryToGraph       - Transform a binary image into a graph structure
%
% Utility functions
%   imFindLabels          - Find unique labels within a label image.
%

% Author: David Legland
% e-mail: david.legland@inrae.fr
% Copyright INRAE
% http://github.com/mattools/matImage
 
% display help if executed
help Contents

%   Deprecated:

%   imInertiaEllipse      - Inertia ellipse of a binary or label image
%   imInertiaEllipsoid    - Inertia ellipsoid of a 3D binary image
%   imContours            - Extract polygonal contours of a binary image

%   Others:


% IMMEASURES Analysis of digital images
% Version 1.1 01-Jul-2011 .
%
%   Provides several functions for measurements on digital images. Most
%   functions are simple wrappers that manage 3D and/or color images, as
%   well as eventual type conversion.
%   Some geometrical measures are provided as well, for description of
%   particles in binary or in label images.
%
% Evaluate image values
%   imLineProfile         - Evaluate image value along a line segment
%   imEvaluate            - Evaluate image value at given position(s).
%
% Statistics on image element values
%   imHistogram           - Histogram of 2D/3D grayscale or color images
%   imHistogramDialog     - Open a dialog to setup image histogram display options
%   imColorHistogram      - Plot 3D histogram of a color image
%   imWeightedHistogram   - Weighted histogram of 2D/3D grayscale image.
%   imJointHistogram      - Joint histogram of two images.
%   imEntropy             - Compute entropy of an image
%   imJointEntropy        - Joint entropy between two images
%   imMutualInformation   - Mutual information between two images
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
% Particle moments
%   imPrincipalAxes       - Computes principal axes of a 2D/3D binary image.
%   imMoment              - Compute simple moment(s) of an image
%   imCMoment             - Compute centered moment of an image
%   imCSMoment            - Compute centered and scaled moments of an image.
%   imHuInvariants        - Compute Hu's invariant for a 2D image.
%
% General information on images
%   imSize                - Compute the size of an image in [x y z] order
%   is3DImage             - Check if an image is 3D
%   isColorImage          - Check if an image is a color image
%   imPhysicalExtent      - Compute the physical extent of an image
%   imGrayscaleExtent     - Grayscale extent of an image
%   imFindLabels          - Find unique labels within a label image.
%
%  Summary statistics on pixel values
%   imSum                 - Sum of a grayscale image, or sum of each color component
%   imMean                - Mean of a grayscale image, or mean of each color component
%   imStd                 - Standard deviation of pixel values
%   imVar                 - Variance of a grayscale image, or of each color component
%   imMin                 - Minimum value of a grayscale image, or of each color component
%   imMax                 - Maximum value of a grayscale image, or of each color component
%   imMedian              - Median value of a grayscale image, or of each color component
%   imQuantile            - Computes value that threshold a given proportion of pixels
%   imMode                - Mode of pixel values in an image
%
% Extract geometric primitives
%   imFind                - Return coordinates of non-zero pixels in an image
%   imRAG                 - Region adjacency graph (RAG) of a label image.
%   imBoundaryContours    - Extract polygonal contours of a binary image.
%   imContourLines        - Extract iso contours of an image as polylines.
%   imBinaryToGraph       - Transform a binary image into a graph structure
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


% IMFILTERS Generic filters for image processing
% Version 1.1 01-Jul-2011 .
%
%   Geometric filters:
%   imAddBorder         - Add a border around a 2D or 3D image
%   imTranspose         - Transpose an image (grayscale or RGB)
%   subsample           - Subsample an array by applying operation on blocs
%   subsamplergb        - Return a sub-sampled version of an rgb image.
%   imCheckerBoard      - Create a checkerboard image from 2 images
%
%   Generic filters:
%   imGaussFilter       - Apply gaussian filter to an image, using separability
%   imGradient          - Compute gradient magnitude in a grayscale image
%   imMorphoGradient    - Morphological gradient of an image
%   imMorphoLaplacian   - Morphological laplacian of an image
%   imImposedWatershed  - Compute watershed after imposition of extended minima
%   imrecerode          - Perform a morphological reconstruction by erosion
%   imHConcave          - H-concave transformation of an image
%   imHConvex           - H-convex transformation of an image
%   imDirectionalFilter - Apply and combine several directional filters
%   imMeanFilter        - Compute mean value in the neighboorhood of each pixel
%   imMedianFilter      - Compute median value in the neighboorhood of each pixel
%   imNeighborhood      - Return the neighborhood of a given pixel
%
%   Color and gray-scale conversions
%   imOverlay           - Add colored markers to an image (2D or 3D, grayscale or color)
%   imAdjustDynamic     - Rescale gray levels of image to get better dynamic
%   imMergeBands        - Merge 3 bands to create a 2D or 3D color image
%   imSplitBands        - Split the 3 bands of a 2D or 3D image
%   double2rgb          - Create a RGB image from double values
%   angle2rgb           - Convert an image of angles to color image
%   imGetHue            - Extract hue of a color image, using rgb2hsv.
%   imGray12ToGray8     - Convert a 12 bits gray scale image to 8 bits gray scale
%
%   Indexed images:
%   imLUT               - Apply a look-up table (LUT) to a gray-scale image.
%   grayFilter          - Compute configuration map of a binary image
%   grayHist            - Compute frequencies of configurations in binary images
%   createTile          - Create a binary tile (2x2) from its index
%   tileIndex           - Return the index of a 2x2 binary tile
%   createTile3d        - Create a 3D binary tile (2x2x2) from its index
%   tileIndex3d         - Return the index of a 2x2x2 binary tile
%
%   Filters for label images:
%   label2rgb3d         - Convert a 3D label image to a 3D RGB image
%   imMergeLabels       - Merge regions in a labeled image
%   mergeRegions        - Merge regions of labeled image, using inclusion criteria
%   imBoundaryIndices   - Find indices of boundary between 2 cells
%   imLabelEdges        - Label edges between adjacent regions of labeled image.
%   removeBorderRegions - Remove regions on the border of an image
%
%   Generate images from binary:
%   imDistance          - Create distance image from a set of points
%   imDistance3d        - Create distance image from a set of 3D points
%   imConvexImage       - Compute smallest convex image containing the original pixels
%   imBoundary          - Compute the boundary image of a binary image
%   findContour         - Chain neigbor pixels to form a contour
%
%   Structuring elements:
%   ball                - Generate a ball in a matrix in 2 or 3 dimensions
%   gaussianKernel3d    - Create a 3D gaussian kernel for image filtering
%   cross3d             - Return a 3D structuring element with cross shape
%   intline             - Integer-coordinate line drawing algorithm.
%   strelDisk           - Discrete disk structuring element
%
%   Utilities
%   createImage         - Create a new image with given size and type
%   imDrawLine          - Draw a line between two points in the image
%
% -----
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 19/04/2004.
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the BSD License, see the file license.txt

% display help if executed
help Contents

%   Deprecated functions
%   convexImage         - Compute smallest convex image containing the original pixels
%   imdirfilter         - Apply and combine several directional filters
%   immean              - Compute mean value in the neighboorhood of each pixel
%   immedian            - Compute median value in the neighboorhood of each pixel
%   imRescale           - Rescale gray levels of image to get better dynamic

%   Not supported functions
%   imMergeCells        - merge labeled cell of an image

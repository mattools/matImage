% IMEXPLORE Utility functions to quickly explore image contents.
%
% Provides several function for histogram computation, for computing
% Summary statistics on pixel values, or for semi-interactive exploration
% (line profiles). 
%
% Statistics on image element values
%   imHistogram         - Histogram of 2D/3D grayscale or color images
%   imHistogramDialog   - Open a dialog to setup image histogram display options
%   imColorHistogram    - Plot 3D histogram of a color image
%   imWeightedHistogram - Weighted histogram of 2D/3D grayscale image.
%   imEntropy           - Compute entropy of an image
%   imJointHistogram    - Joint histogram of two images.
%   imJointEntropy      - Joint entropy between two images
%   imMutualInformation - Mutual information between two images
%
%  Summary statistics on pixel values
%   imSum               - Sum of a grayscale image, or sum of each color component
%   imMean              - Mean of a grayscale image, or mean of each color component
%   imStd               - Standard deviation of pixel values
%   imVar               - Variance of a grayscale image, or of each color component
%   imMin               - Minimum value of a grayscale image, or of each color component
%   imMax               - Maximum value of a grayscale image, or of each color component
%   imMedian            - Median value of a grayscale image, or of each color component
%   imQuantile          - Computes value that threshold a given proportion of pixels
%   imMode              - Mode of pixel values in an image
%
% Evaluate image values
%   imLineProfile       - Evaluate image value along a line segment
%   imEvaluate          - Evaluate image value at given position(s).
%   imLocalGradient     - Compute gradient for chosen locations within image.
%
% General information about images
%   imGrayscaleExtent   - Grayscale extent of an image
%   imPhysicalExtent    - Compute the physical extent of an image
%   imSize              - Compute the size of an image in [x y z] order
%   is3DImage           - Check if an image is 3D
%   isColorImage        - Check if an image is a color image
%   imFileInfo          - Generalization of the imfinfo function

% Author: David Legland
% e-mail: david.legland@inra.fr
% Copyright INRA - Cepia Software Platform.
% http://github.com/mattools/matImage



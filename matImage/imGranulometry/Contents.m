% IMGRANULOMETRY Gray-level granulometry using mathematical morphology.
% Version 1.0 02-Apr-2020 .
%
%   Provides functions to compute granulometry curves on grayscale images
%   using mathematical morphology operations.
%
%
% Computation of granulometry curves
%   imGranulo         - Compute granulometry curve of a given image.
%   imGranuloByRegion - Granulometry curve for each region of label image.
%
% Analysis of granulometry curves
%   granuloMeanSize   - Compute geometric mean of granulometric curve.
%   granuloMean       - Compute arithmetic mean of granulometric curve(s).
%   granuloStd        - Compute standard deviation of granulometric curve(s).
%
% Variations of granulometry analysis
%   imOrientedGranulo - Gray level granulometry mean size for various orientations.
%
%
% References
% * Soille P, 2003, "Morphological Image Analysis", Springer.
% * Devaux MF and Legland D, 2014, "Grey level granulometry for
%   histological image analysis of plant tissues". Formatex Research
%   Center, pp. 681-688.
%   http://www.formatex.info/microscopy6/book/681-688.pdf
%
%
% -----
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Copyright INRAE - BIA - Cepia Software Platform.
% http://github.com/mattools/matImage
% http://www.pfl-cepia.inrae.fr/index.php?page=imael


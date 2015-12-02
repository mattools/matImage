function res = imOrientedGranulo(img, angleList, granuloType, strelSizes, varargin)
%IMORIENTEDGRANULO compute granulometry mean size for various orientations
%
%   output = imOrientedGranulo(IMG, ANGLES, TYPE, SIZES)
%   IMG should be a 2D image (binary, grayscale or color)
%   ANGLES is the list of angles to consider, in degrees, as a 1-by-N row
%     vector
%   GRTYPE can be one of {'opening', 'closing', 'erosion', 'dilation'}.
%   SIZES are given as radius in pixels. Diameters of strels are obtained
%     as 2*R+1. 
%   The result GR is a 1-by-N array with as many columns as the number of
%     elements provided in ANGLES array.
%
%   Example
%   imOrientedGranulo
%
%   See also
%     imGranulo, imGranuloByRegion
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-12-02,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2015 INRA - Cepia Software Platform.

nAngles = length(angleList);

if islogical(img)
    interp = 'nearest';
else
    interp = 'linear';
end

res = zeros(1, nAngles);
diams = 2*strelSizes+1;

for iAngle = 1:nAngles
    angle = angleList(iAngle);
    imgr = imrotate(img, angle, interp);
    grCurve = imGranulo(imgr, granuloType, 'lineh', strelSizes);
    res(iAngle) = granuloMeanSize(grCurve, diams);
end

 
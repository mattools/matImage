function [res, diams] = imOrientedGranulo(img, angleList, granuloType, strelSizes, varargin)
% Gray level granulometry mean size for various orientations.
%
%   RES = imOrientedGranulo(IMG, ANGLES, TYPE, SIZES)
%   IMG should be a 2D image (binary, grayscale or color)
%   ANGLES is the list of angles to consider, in degrees, as a 1-by-N row
%     vector
%   GRTYPE can be one of {'opening', 'closing', 'erosion', 'dilation'}.
%   SIZES are given as radius in pixels. Diameters of strels are obtained
%     as 2*R+1. 
%   The result GR is a 1-by-N array with as many columns as the number of
%     elements provided in ANGLES array.
%
%   [RES, DIAMS] = imOrientedGranulo(...)
%   Also returns the diameters used for each morphological filtering step.
%
%
%   Example
%   imOrientedGranulo
%
%   See also
%     imGranulometry, imDirectionalGranulo, imGranulo, imGranuloByRegion,
%     granuloMeanSize 
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2015-12-02,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2015 INRAE - Cepia Software Platform.


% how to interpolate images
if islogical(img)
    interp = 'nearest';
else
    interp = 'linear';
end

% convert sizes from radius to diameter
diams = 2 * strelSizes + 1;

% allocate result array
nAngles = length(angleList);
res = zeros(1, nAngles);

% iterate over the orientations
for iAngle = 1:nAngles
    angle = angleList(iAngle);
    imgr = imrotate(img, angle, interp);
    grCurve = imGranulo(imgr, granuloType, 'lineh', strelSizes);
    res(iAngle) = granuloMeanSize(grCurve, diams);
end

 
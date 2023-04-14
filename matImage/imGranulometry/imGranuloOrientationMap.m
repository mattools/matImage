function [orientMap, resMax, rgb] = imGranuloOrientationMap(img, nOrients, grType, LMax)
% Orientation map of directional granulometry.
%
%   Usage:
%   ORIMAP = imGranuloOrientationMap(IMG, NORIENT, GRTYPE, LMAX)
%   [ORIMAP, RESMAX, RGB] = imGranuloOrientationMap(IMG, NORIENT, GRTYPE, LMAX)
%
%   Computes the orientation map ORIMAP by applying grey level granulometry
%   methods on the input image IMG. The orientation map is obtained by
%   performing grey level granulometries with orietned line segments of
%   increasing sizes, and retaining for each pixel the orientation whose
%   granulometriccurve provides that largest mean size.
%
%   Input arguments:
%   IMG:     the input image. Must be 2D and grayscale.
%   NORIENT: the number of orientations to consider. Orientations are
%     distributed within the [0 180] interval.
%   GRTYPE:  the type of granulometry to perform. Must be either 'opening'
%     (in the case of bright fibers over dark background) or 'closing (in
%     the case of dark fibers over bright background). 
%   LMAX:    the size of the largest structuring element to use.
%
%   Output arguments:
%   ORIMAP is a numeric array the same size as IMG, with values between 0
%   and 180 corresponding to the orientation (in degrees). Orientation 0
%   corresponds to horizontal, orientation 90 corresponds to vertical.
%   
%   Also returns an RESMAX and RGB as follow:
%   RESMAX:  an array the same saize as IMG that corresponds to the size
%     that was computed for retained orientation. 
%   RGB:     a color representation of the orientation map, that combines
%     the values in the orientation map and the intensities of the original
%     image.  
%
%   Example
%   imGranuloOrientationMap
%
%   See also
%     imGranulometry, imDirectionalGranulo, granuloMeanSize
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2018-12-19,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.

% compute the 3D array of mean size for each position and each orientation
[res, orientList] = imDirectionalGranulo(img, nOrients, grType, LMax);
resMax = max(res, [], 3);

% convert to radians, over all directions
orientRads = deg2rad(2 * orientList);

% compute average direction for each pixel, weighted by granulometric size
dxList = reshape(cos(orientRads), [1 1 nOrients]);
dyList = reshape(sin(orientRads), [1 1 nOrients]);
dxMoy = sum(bsxfun(@times, res, dxList), 3) ./ sum(res, 3);
dyMoy = sum(bsxfun(@times, res, dyList), 3) ./ sum(res, 3);

% create orientation map, in degrees
orientMap = mod(rad2deg(atan2(dyMoy, dxMoy) / 2) + 180, 180);

% optionnaly create an rgb version
if nargout > 2
    hue = orientMap / 180;
    sat = double(img) / double(max(img(:)));
    if strcmp(grType, 'closing')
        sat = 1 - sat;
    end
    val = ones(size(img));
    rgb = hsv2rgb(cat(3, hue, sat, val));
end

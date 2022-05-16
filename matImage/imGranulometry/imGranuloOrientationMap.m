function [orientMap, resMax, rgb] = imGranuloOrientationMap(img, nOrients, grType, LMax)
% Orientation map of directional granulometry.
%
%   ORIMAP = imGranuloOrientationMap(IMG, NORIENT, GRTYPE, LMAX)
%
%   [ORIMAP, RGB] = imGranuloOrientationMap(IMG, NORIENT, GRTYPE, LMAX)
%   Also returns an RGB version for display
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
if nargout > 1
    hue = orientMap / 180;
    sat = double(img) / double(max(img(:)));
    val = ones(size(img));
    rgb = hsv2rgb(cat(3, hue, sat, val));
end

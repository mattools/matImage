function res = imThicknessMap(img, varargin)
%IMTHICKNESSMAP Compute thickness map of a binary image
%
%   THMAP = imThicknessMap(BW)
%   Returns an imagethe same size as the input binary image BW, containing
%   for each pixel the thickness of the white phase at this position.
%
%   Example
%     img =  imread('circles.png');
%     img = imFillHoles(img);
%     tmap = imThicknessMap(img);
%     figure; imshow(tmap, [])
%     colormap jet
%
%   See also
%     imDistanceMap
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-06-28,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

% compute distance map
distMap = imDistanceMap(img);

% determine the maximum thickness
maxDist = ceil(max(distMap(:)));

% generate an imageor computing strels
diam = 2 * maxDist + 1;
distRef = zeros(diam, diam);
distRef(maxDist, maxDist) = 1;
distRef = imDistanceMap(~distRef);

% allocate memory for result
res = zeros(size(img));

% iterate over distances
for i = 1:maxDist
    se = strel('arbitrary', distRef <= i);
    tmp = imdilate(distMap >= i, se);
    res = max(res, double(tmp) * i);
end

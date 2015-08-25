function res = imSeparateParticles(img, varargin)
%IMSEPARATEPARTICLES Separate touching particles using watershed algorithm
%
%   RES = imSeparateParticles(BINIMG)
%
%   Example
%     img = imread('circles.png');
%     img2 = imSeparateParticles(img);
%     figure; imshow(img2);
%
%   See also
%     watershed, imImposedWatershed
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-08-25,    using Matlab 8.5.0.197613 (R2015a)
% Copyright 2015 INRA - Cepia Software Platform.

% default connectivity
if ndims(img) == 2 %#ok<ISMAT>
    conn = 4;
elseif ndims(img) == 3
    conn = 6;
end
 
% compute complement of distance map
distMap = imDistanceMap(img);
comp = imcomplement(distMap);

% apply h-minima transform to avoid over-segmentation
emin = imextendedmin(comp, 2, conn);
imp = imimposemin(comp, emin, conn);

% apply watershed transform on filtered distance map
wat = watershed(imp, conn);

% combine with original image
res = img & wat > 0;

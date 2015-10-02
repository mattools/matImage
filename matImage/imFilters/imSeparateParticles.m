function res = imSeparateParticles(img, varargin)
%IMSEPARATEPARTICLES Separate touching particles using watershed algorithm
%
%   RES = imSeparateParticles(BINIMG)
%   Separates particles in a binary image by applying watershed transform
%   on the complement of the distance map. A detection of watershed markers
%   is  performed by applying detection of extended minima.
%
%   RES = imSeparateParticles(BINIMG, EMINDYN)
%   Also specifies the dynamic used to separated extended minima before
%   computing watershed.
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

% choose dymanic value
dyn = 2;
if ~isempty(varargin)
    dyn = varargin{1};
end

% compute complement of distance map
distMap = imDistanceMap(img);
comp = imcomplement(distMap);

% apply h-minima transform to avoid over-segmentation
emin = imextendedmin(comp, dyn, conn);
imp = imimposemin(comp, emin, conn);

% apply watershed transform on filtered distance map
wat = watershed(imp, conn);

% combine with original image
res = img & wat > 0;

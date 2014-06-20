function img = imCheckerboardLabels(size, tileWidth)
%IMCHECKERBOARDLABELS  Create a checkerboard label image
%
%   IMG = imCheckerboardLabels(IMGSIZE, TILEWIDTH)
%
%   Example
%   lbl = imCheckerboardLabels([128 128], [8 8]);
%   rgb = label2rgb(lbl, 'colorcube', 'w', 'shuffle');
%   imshow(rgb);
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-02-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

img = zeros(size);

nTiles = ceil(size ./ tileWidth);

lab = 1;
for y = 1:nTiles(1)
    i0 = (y - 1) * tileWidth(1) + 1;
    i1 = min(y * tileWidth(1), size(1));
    for x = 1:nTiles(2)
        j0 = (x - 1) * tileWidth(2) + 1;
        j1 = min(x * tileWidth(2), size(2));
        
        img(i0:i1, j0:j1) = lab;
        lab = lab + 1;
    end
end

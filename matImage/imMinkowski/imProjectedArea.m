function res = imProjectedArea(img, shifts, varargin)
%IMPROJECTEDAREA  Total projected area in a given direction
%
%   AREA = imProjectedArea(IMG, SHIFT)
%   IMG is a 3D binary image, SHIFT is a 1-by3 row vector indicating the
%   shift between two voxels to test.
%
%   Example
%     % generate binary image of a 3D ellipsoid
%     elli = [50.12 50.23 50.34 50 35 20 30 40 50];
%     img = discreteEllipsoid(1:100, 1:100, 1:100, elli);
%     % compute projected area in main directions
%     D1 = imProjectedArea(img, [1 0 0]);
%     D2 = imProjectedArea(img, [0 1 0]);
%     D3 = imProjectedArea(img, [0 0 1]);
%     % compute projected area in a less common direction
%     D4 = imProjectedArea(img, [2 1 1]);
%
%   See also
%     imSurface, imProjectedDiameter
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-05-27,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

dim = size(img);

dx = shifts(1);
dy = shifts(2);
dz = shifts(3);

dl = hypot(hypot(dx, dy), dz);
% vol = dx * dy * dz;

% iterate over pixels in image to count number of transitions
% count = 0;
% for z = 3:dim(3)-2
%     for y = 3:dim(1)-2
%         for x = 3:dim(2)-2
%             if img(y, x, z) ~= img(y+dy, x+dx, z+dz)
%                 count = count + 1;
%             end
%         end
%     end
% end

ix = 3:dim(2)-2;
iy = 3:dim(1)-2;
iz = 3:dim(3)-2;
count = sum(sum(sum( img(iy, ix, iz) ~= img(iy+dy, ix+dx, iz+dz) )));

% number of connected components
count = count / 2;

% normalize with line density
res = count * 1 / dl;

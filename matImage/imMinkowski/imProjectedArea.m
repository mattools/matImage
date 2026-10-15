function res = imProjectedArea(img, shifts, varargin)
% Total projected area of a 3D region in a given direction.
%
%   AREA = imProjectedArea(IMG, SHIFT)
%   IMG is a 3D binary image, SHIFT is a 1-by-3 row vector indicating the
%   shift between two voxels to test.
%
%   Note: this function does not handle very well the regions close to
%   image border. It is advised to pad the image with the value of the
%   offset in the corresponding direction.
%
%   Example
%     % generate binary image of a 3D ellipsoid
%     elli = [50.12 50.23 50.34 50 35 20 30 40 50];
%     img = discreteEllipsoid(1:100, 1:100, 1:100, elli);
%     % compute projected area in main directions
%     D1 = imProjectedArea(img, [1 0 0]);  % y-direction
%     D2 = imProjectedArea(img, [0 1 0]);  % x-direction
%     D3 = imProjectedArea(img, [0 0 1]);  % z-direction
%     % compute projected area in a less common direction
%     D4 = imProjectedArea(img, [2 1 1]);
%
%   See also
%     imSurface, imProjectedDiameter
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2015-05-27,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2026 INRAE - BIA-BIBS.

% retrieve image size
dims = size(img);

% retrieve offset elements
dx = shifts(1);
dy = shifts(2);
dz = shifts(3);
% vol = dx * dy * dz;

% find index of image pixels whose pair also lies within image
ix = createLinearIndices(dims(2), dx);
iy = createLinearIndices(dims(1), dy);
iz = createLinearIndices(dims(3), dz);

% count the number of connected components
count = sum(sum(sum( img(iy, ix, iz) ~= img(iy+dy, ix+dx, iz+dz) )));
count = count / 2;

% normalize with line density
dl = hypot(hypot(dx, dy), dz);
res = count * 1 / dl;


function inds = createLinearIndices(maxLength, shift)

inds = 1:maxLength;
inds2 = inds + shift;
inds(inds2 < 1 | inds2 > maxLength) = [];

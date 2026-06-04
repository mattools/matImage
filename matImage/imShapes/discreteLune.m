function img = discreteLune(varargin)
%DISCRETELUNE Create a binary image of a lune, as the intersection of two disks.
%
%   IMG = discreteLune(LX, LY, LUNE)
%   LUNE has format: [XC YC R D THETA], where (XC,YC) is the center of the
%   lune, R is its outer radius, D is the distance between the two disk
%   centers, and THETA is the direction of the second disk center (given in
%   degress, relative to horizontal).
%
%   Example
%     img = discreteLune(1:100, 1:100, [50 50 30 -20]);
%     imshow(img);
%
%   See also
%   imShapes, discreteDisk, discreteEllipse
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-06-04,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

% compute coordinate of image pixels
[lx, ly, varargin] = parseGridArgs(varargin{:});
[x, y]   = meshgrid(lx, ly);

% extract lune parameters
lune = varargin{1};
xc = lune(1);
yc = lune(2);
R  = lune(3);
d  = lune(4);
th = lune(5);

% transform grid to have lune "centered" and pointing to the right
rot = createRotation(-deg2rad(th));
center = [xc yc];
tra = createTranslation(-center);
[x, y] = transformPoint(x, y, rot * tra);

% init image with black square
img = false(size(x));

% main disk
img(x.^2 + y.^2 < R^2) = 1;

% remove second disk
img((x-d).^2 + y.^2 < R^2) = 0;

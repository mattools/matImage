function img = discreteEgg(varargin)
%DISCRETEEGG Create a discrete image of egg
%
%   IMG = discreteEgg(LX, LY, EGG)
%   EGG has format: [XC YC R THETA].
%
%   Example
%     img = discreteEgg(1:100, 1:100, [50 50 30 -20]);
%     imshow(img);
%
%   See also
%   discreteEllipse, discreteTrefoil, discreteStarfish
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% compute coordinate of image pixels
[lx ly varargin] = parseGridArgs(varargin{:});
[x y]   = meshgrid(lx, ly);

% extract egg parameters
egg = varargin{1};
xc = egg(1);
yc = egg(2);
R  = egg(3);
th = egg(4);

% transform grid to have egg "centered" and pointing to the right
rot = createRotation(-deg2rad(th));
center = [xc yc];
tra = createTranslation(-center);
[x y] = transformPoint(x, y, rot * tra);

% init image with black square
img = false(size(x));

% main disk
img(x.^2 + y.^2 < R^2) = 1;

% two parts of greater disks
h = sqrt(2) * R;
img(x.^2 + (y+R).^2 < (2*R)^2 & x >= 0 & x <= h & y >= 0) = 1;
img(x.^2 + (y-R).^2 < (2*R)^2 & x >= 0 & x <= h & y <= 0) = 1;

% small disk at egg apex
rc = R * (2 - sqrt(2));
img((x-R).^2 + y.^2 < rc^2) = 1;


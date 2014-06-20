function img = discreteTrefoil(varargin)
%DISCRETETREFOIL  Discretize a trefoil curve
%
%   IMG = discreteTrefoil(LX, LY, TREFOIL);
%   Computes the discretisation of a trefoil curve. Inputs are LX and LY,
%   two row vectors specifying pixel positions along each direction, and
%   TREFOIL = [XC YC ROUT RIN THETA], where (XC YC) is the center of the
%   trefoil, ROUT and RIN are the outer and the inner radius, and THETA is
%   the orientation of the first lobe, in degrees counted counter
%   clockwise.
%
%   Example
%     trefoil = [50.12 50.23 45 15 10];
%     img = discreteTrefoil(1:100, 1:100, trefoil);
%     imshow(img)
%
%   See also
%   discreteEllipse, discreteStarfish
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% compute coordinate of image pixels
[lx ly varargin] = parseGridArgs(varargin{:});
[x y]   = meshgrid(lx, ly);

% process input parameters
var = varargin{1};
center  = var(:, 1:2);
rOut    = var(:, 3);
rIn     = var(:, 4);
theta   = var(:, 5);

% compute middle radius, and radius extent
rc = (rOut + rIn) / 2;
dr = (rOut - rIn) / 2;

% transforms pixels according to shape position
tra     = createTranslation(-center);
rot     = createRotation(-deg2rad(theta));

[x y]   = transformPoint(x, y, rot*tra);

% convert to polar coordinates
[th rho] = cart2pol(x(:), y(:));

% compute theoretical polar distance
rhoTh = rc + dr * cos(3 * th);

% create image 
img = false(size(x));
img(rho < rhoTh) = 1;

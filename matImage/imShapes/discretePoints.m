function img = discretePoints(dim, points)
%DISCRETEPOINTS discretize a set of points
%
%   IMG = discretePoints(DIM, PTS)
%   DIM is the size of image, with the format [x0 dx x1;y0 dy y1]
%   PTS is a Nx2 array of coordinate.
%
%   IMG = discretePoints(DIM, BALL)
%   send parameters in a row vector, where BALL contains at least the
%   center coordinate, and possibly the other parameters.
%
%   Example
%   img = discretePoints([1 1 100;1 1 100], [50 50;10 10;90 90;10 90;90 10]);
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-02-27
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY

x0 = dim(1,1);
dx = dim(1,2);
x1 = dim(1,3);
y0 = dim(2,1);
dy = dim(2,2);
y1 = dim(2,3);

nx = (x1-x0)/dx + 1;
ny = (y1-y0)/dy + 1;

img = false(ny, nx);

for i=1:size(points, 1)
    ix = max(min(round((points(i,1)-x0)/dx), nx), 1);
    iy = max(min(round((points(i,2)-y0)/dy), ny), 1);
    img(iy, ix) = 1;
end

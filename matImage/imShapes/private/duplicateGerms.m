function points = duplicateGerms(lx, ly, points)
% Duplicate germs for voronoi periodic boundary condition.
%
%   GERMS2 = duplicateGerms(LX, LY, GERMS);
%   LX and LY are vectors containing positions of pixels in an image
%   GERMS are points within thin image
%   The result is the set of germes repeated in each of the 8 directions
%   aroundthe central image. The number of returned points is 9 times the
%   number of input points.
%
%   Example
%   duplicateGerms([1 100], [1 100], rand(30, 2)*100);
%
%   See also
%     imvoronoi2d, imAWVoronoi, imPowerDiagram
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-05-29,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

N = size(points, 1);

% width of window in each dimension
if length(lx)>1
    width = [lx(end)-2*lx(1)+lx(2) ly(end)-2*ly(1)+ly(2)];
else
    width = [lx ly];
end

% duplicate the array of points with same coordinates
points = repmat(points, [9 1]);

% add x-shift for left points
for i=[1 2 3]
    points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) - width(1);
end

% add x-shift for right points
for i=[7 8 9]
    points((i-1)*N+1:i*N, 1) = points((i-1)*N+1:i*N, 1) + width(1);
end

% add y-shift for bottom points
for i=[1 4 7]
    points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) - width(2);
end

% add y-shift for top points
for i=[3 6 9]
    points((i-1)*N+1:i*N, 2) = points((i-1)*N+1:i*N, 2) + width(2);
end

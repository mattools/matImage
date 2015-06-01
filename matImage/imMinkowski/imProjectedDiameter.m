function res = imProjectedDiameter(img, shifts)
%IMPROJECTEDDIAMETER  Projected diameter in a given direction
%
%   DIAM = imProjectedDiameter(IMG, SHIFT)
%   IMG is a 2D binary image, SHIFT is a 1-by-2 row vector indicating the
%   shift between two pixels to test.
%
%   Example
%   elli = [50.12 50.23 40 20 30];
%   img = discreteEllipse(1:100, 1:100, elli);
%   Dx = imProjectedDiameter(img, [1 0]);
%   Dy = imProjectedDiameter(img, [0 1]);
%   Dxy1 = imProjectedDiameter(img, [1 1]);
%   Dxy2 = imProjectedDiameter(img, [1 -1]);
%
%   See also
%     imPerimeter, imProjectedArea
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-24,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

dim = size(img);

dx = shifts(1);
dy = shifts(2);

d12 = hypot(dx, dy);


% iterate over pixels in image to count number of transitions
count = 0;
for y = 3:dim(1)-2
    for x = 3:dim(2)-2
        if img(y, x) ~= img(y+dy, x+dx)
            count = count + 1;
        end
    end
end

% number of connected components
count = count / 2;

% normalize with line density
res = count * 1 / d12;

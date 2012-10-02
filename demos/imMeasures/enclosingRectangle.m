function rect = enclosingRectangle(points, theta)
%ENCLOSINGRECTANGLE Minimal-area enclosing rectangle of a set of points
%
%   RECT = enclosingRectangle(POINTS, ANGLES)
%
%   Example
%   enclosingRectangle
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-02-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

x = points(:, 1);
y = points(:, 2);

fd = zeros(1, length(theta));

% keep only points of the convex hull
try
    inds = convhull(x, y);
    x = x(inds);
    y = y(inds);
catch ME %#ok<NASGU>
    % an exception can occur if points are colinear.
    % in this case we transform all points
end

% recenter points (should be better for numerical accuracy)
xc = mean(x);
yc = mean(y);
x = x - xc;
y = y - yc;

% iterate over orientations
for t = 1:numel(theta)
    % convert angle to radians, and change sign (to make transformed
    % points aligned along x-axis)
    theta2 = -theta(t) * pi / 180;
    
    % compute only transformed x-coordinate
    x2  = x * cos(theta2) - y * sin(theta2);
    
    % compute diameter for extreme coordinates
    xmin    = min(x2);
    xmax    = max(x2);
    
    % store result (add 1 pixel to consider pixel width)
    fd(t)   = xmax - xmin + 1;
end

feretArea = fd(:, 1:end/2).*fd(:, end/2+1:end);
[minArea indMinArea] = min(feretArea, [], 2); %#ok<ASGLU>

indMin90 = indMinArea + 100;

if fd(indMinArea) < fd(indMin90)
    thetaMax = theta(indMin90);
else
    thetaMax = theta(indMinArea);
end

% elongation in direction of rectangle length
thetaRect = -thetaMax * pi / 180;
x2  = x * cos(thetaRect) - y * sin(thetaRect);
y2  = x * sin(thetaRect) + y * cos(thetaRect);

xmin = min(x2);
xmax = max(x2);
ymin = min(y2);
ymax = max(y2);

dl = (xmax + xmin)/2;
dw = (ymax + ymin)/2;

% change  coordinate from rectangle to user-space
theta2 = thetaMax * pi / 180;
dx  = dl * cos(theta2) - dw * sin(theta2);
dy  = dl * sin(theta2) + dw * cos(theta2);

% coordinates of rectangle center
xc2 = xc + dx;
yc2 = yc + dy;

% size of the rectangle
rectLength  = xmax - xmin + 1;
rectWidth   = ymax - ymin + 1;

% concatenate recangle data
rect = [xc2 yc2 rectLength rectWidth -thetaRect];

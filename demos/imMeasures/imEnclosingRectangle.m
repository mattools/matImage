function rect = imEnclosingRectangle(img, theta)
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

labels = unique(img(:));
labels(labels==0) = [];

nLabels = length(labels);

rect = zeros(nLabels, 5);


for i=1:nLabels
    [y x] = find(img==labels(i));
    
    % keep only points of the convex hull
    try
        inds = convhull(x, y);
        x = x(inds);
        y = y(inds);
    catch ME %#ok<NASGU>
        % an exception can occur if points are colinear.
        % in this case we transform all points
    end

    % compute convex hull centroid, that corresponds to approximate
    % location of rectangle center
    xc = mean(x);
    yc = mean(y);
    
    % recenter points (should be better for numerical accuracy)
    x = x - xc;
    y = y - yc;

    % allocate memory for result of Feret Diameter computation
    fd = zeros(1, length(theta));

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

    % compute area of enclosing rectangles with various orientations
    feretArea = fd(:, 1:end/2).*fd(:, end/2+1:end);
    
    % find the orientation that produces to minimum area rectangle
    [minArea indMinArea] = min(feretArea, [], 2); %#ok<ASGLU>

    % convert index to angle (in degrees)
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

    % compute extension along main directions
    xmin = min(x2);    xmax = max(x2);
    ymin = min(y2);    ymax = max(y2);

    % position of the center with respect to the centroid compute before
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
    rect(i,:) = [xc2 yc2 rectLength rectWidth -thetaRect];
end


function [fd labels] = imFeretDiameter(img, varargin)
%IMFERETDIAMETER Feret diameter of a particle(s) for a given direction(s)
%
%   FD = imFeretDiameter(IMG, THETA);
%   Compute the Feret diameter for particles in image IMG (binary or
%   label), for the direction THETA, given in degrees.
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each particle in IMG.
%
%   THETA can be a set of directions. In this case, the result has as many
%   columns as the number of directions, and as many rows as the number of
%   particles.
%
%   FD = imFeretDiameter(IMG);
%   Uses a default set of directions for computing Feret diameter.
%
%   [FD LABELS] = imFeretDiameter(...);
%   Also returns the set of labels that were considered for measure.
%
%   The maximum Feret diameter can be obtained using a max() function. 
%
%   Example:
%   % compute Feret diameter for a discrete square
%   img = zeros(100, 100, 'uint8');
%   img(21:80, 21:80) = 1;
%   theta = linspace(0, 180, 201);
%   fd = imFeretDiameter(img, theta);
%   figure(1); clf; set(gca, 'fontsize', 14);
%   plot(theta, fd); xlim([0 180]);
%   xlabel('Angle (in degrees)');
%   ylabel('Diameter (in pixels)');
%   title('Feret diameter of discrete square');
%
%   % max Feret diameter:
%   diam = max(fd, [], 2)
%   ans =
%       84.4386
%
%   See also 
%   imOrientedBox
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-03-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2011-02-06 update doc, use convex hull, use degrees instead of radians

% extract orientations
if isempty(varargin)
    theta = linspace(0, 180, 32+1);
    theta = theta(1:end-1);
else 
    theta = varargin{1};
end

% number of particles
labels = unique(img(:));
labels(labels==0) = [];
nLabels = length(labels);

% allocate memory for result
fd = zeros(nLabels, numel(theta));

for i = 1:nLabels
    % extract pixel centroids
    [y x] = find(img==labels(i));
    if isempty(x)
        continue;
    end
    
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
    x = x - mean(x);
    y = y - mean(y);
    
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
        fd(i, t) = xmax - xmin + 1;
    end
end


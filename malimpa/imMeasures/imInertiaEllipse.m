function [ellipse labels] = imInertiaEllipse(img)
%IMINERTIAELLIPSE Inertia ellipse of a binary or label image
%
%   ELLI = imInertiaEllipse(IMG)
%   Compute the inertia ellipses of the particles in labeled image IMG. If
%   the image is binary, one ellipse, corresponding to the foreground (i.e.
%   the pixels with value 1) will be computed.
%
%   The result is a N-by-5 array ELLI = [XC YC A B THETA], containing
%   coordinates of ellipse center, lengths of semi major and minor axes,
%   and the orientation (given in degrees, in the direction of the greatest
%   axis).
%
%   The same result could be obtained with the regionprops function. The
%   advantage of using imInertiaEllipse is that equivalent ellipses can be
%   obtained in one call. Orientation of both functions are not consistent.
%
%   Example
%   % Draw a commplex particle together with its equivalent ellipse
%     img = imread('circles.png');
%     imshow(img); hold on;
%     elli = imInertiaEllipse(img);
%     drawEllipse(elli)
%
%   % Compute and display the equivalent ellipses of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     ellipses = imInertiaEllipse(lbl);
%     imshow(img); hold on;
%     drawEllipse(ellipses, 'linewidth', 2, 'color', 'g');
%
%   See also
%     regionprops, drawEllipse, imOrientedBox, imInertiaEllipsoid
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% extract the set of labels, and remove label for background
labels = unique(img(:));
labels(labels==0) = [];

nLabels = length(labels);

% allocate memory for result
ellipse = zeros(nLabels, 5);

for i=1:nLabels
    % extract points of the current particle
    [y x] = find(img==labels(i));
    
    % compute convex hull centroid, that corresponds to approximate
    % location of rectangle center
    xc = mean(x);
    yc = mean(y);
    
    % recenter points (should be better for numerical accuracy)
    x = x - xc;
    y = y - yc;

    % number of points
    n = length(x);
    
    % compute inertia parameters. 1/12 is the contribution of a single
    % pixel, then for regions with only one pixel the resulting ellipse has
    % positive radii.
    Ixx = sum(x.^2) / n + 1/12;
    Iyy = sum(y.^2) / n + 1/12;
    Ixy = sum(x.*y) / n;
    
    % compute ellipse semi-axis lengths
    common = sqrt( (Ixx - Iyy)^2 + 4 * Ixy^2);
    ra = sqrt(2) * sqrt(Ixx + Iyy + common);
    rb = sqrt(2) * sqrt(Ixx + Iyy - common);
    
    % compute ellipse angle and convert into degrees
    theta = atan2(2 * Ixy, Ixx - Iyy) / 2;
    theta = rad2deg(theta);
    
    % create the resulting inertia ellipse
    ellipse(i,:) = [xc yc ra rb theta];
end

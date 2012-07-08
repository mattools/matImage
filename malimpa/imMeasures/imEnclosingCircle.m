function [circle labels] = imEnclosingCircle(img)
%IMENCLOSINGCIRCLE Minimal enclosing circle of a particle
%
%   CIRC = imEnclosingCircle(IMG)
%   Computes the minimal enclosing circle around a binary particle, or
%   around each labeled particle in the input image.
%
%
%   Example
%   % Draw a commplex particle together with its enclosing circle
%     img = imread('circles.png');
%     imshow(img); hold on;
%     circ = imEnclosingCircle(img);
%     drawCircle(circ)
%
%   % Compute and display the equivalent ellipses of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     circles = imEnclosingCircle(lbl);
%     imshow(img); hold on;
%     drawCircle(circles, 'linewidth', 2, 'color', 'g');
%
%   See also
%     drawCircle, imInscribedCircle, imInertiaEllipse, imInertiaEllipse
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% extract the set of labels, and remove label for background
labels = unique(img(:));
labels(labels==0) = [];

nLabels = length(labels);

% allocate memory for result
circle = zeros(nLabels, 3);

for i = 1:nLabels
    % extract points of the current particle
    [y x] = find(img==labels(i));

    % works on convex hull (faster), or on original points if the hull
    % could not be computed
    try 
        inds = convhull(x, y);
        pts = [x(inds) y(inds)];
    catch %#ok<CTCH>
        pts = [x y];
    end
    
    circle(i,:) = recurseCircle(size(pts, 1), pts, 1, zeros(3, 2));
end


function circ = recurseCircle(n, p, m, b)
%    n: number of points given
%    m: an argument used by the function. Always use 1 for m.
%    bnry: an argument (3x2 array) used by the function to set the points that 
%          determines the circle boundary. You have to be careful when choosing this
%          array's values. I think the values should be somewhere outside your points
%          boundary. For my case, for example, I know the (x,y) I have will be something
%          in between (-5,-5) and (5,5), so I use bnry as:
%                       [-10 -10
%                        -10 -10
%                        -10 -10]


if m == 4
    circ = createCircle(b(1,:), b(2,:), b(3,:));
    return;
end

circ = [Inf Inf 0];

if m == 2
    circ = [b(1,1:2) 0];
elseif m == 3
    c = (b(1,:) + b(2,:))/2;
    circ = [c distancePoints(b(1,:), c)];
end


for i = 1:n
    if distancePoints(p(i,:), circ(1:2)) > circ(3)
        if sum(b(:,1)==p(i,1) & b(:,2)==p(i,2)) == 0
            b(m,:) = p(i,:);
            circ = recurseCircle(i, p, m+1, b);
        end
    end
end


function dist = distancePoints(p1, p2)

dist = hypot(p2(:,1) - p1(:,1), p2(:,2) - p1(:,2));

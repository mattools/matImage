function [points labels] = imCentroid(img)
%IMCENTROID Centroid of regions in a label image
%
%   CENTRO = imCentroid(IMG)
%   Compute the centroid (center of mass) of each particle in the label
%   image IMG. IMG can also be a binary image, in this case only one
%   centroid will be returned. The same result can be obtained with the
%   'regionprops' function, but extracting the centroids is often tedious.
%   
%   The result CENTRO is a N-by-2 array containing coordinates of particle
%   centroids. First column contains X coordinates, second column Y
%   coordinates.
%
%   If IMG is a 3D image (label or binary), the result is a N-by-3 array
%   containing x-, y- and z-ccordinates of the 3D centroids.
%
%   [CENTRO LABELS] = imCentroid(...)
%   Also returns the label forwhich a centroid was computed. Can be useful
%   in case of a label image with 'missing' labels.
%
%   Example
%   % Draw a commplex particle together with its centroids
%     img = imread('circles.png');
%     imshow(img); hold on;
%     pts = imCentroid(img);
%     drawPoint(pts, '+')
%
%   % Compute and display the centroid of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     centroids = imCentroid(lbl);
%     imshow(img); hold on;
%     drawPoint(centroids, 'marker', '+', 'linewidth', 2);
%
%   See also
%   regionprops, drawPoint, imOrientedBox, imInertiaEllipse
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
nd = ndims(img);
points = zeros(nLabels, nd);

if nd == 2
    for i = 1:nLabels
        % extract points of the current particle
        [y x] = find(img==labels(i));

        % compute coordiante of particle centroid
        xc = mean(x);
        yc = mean(y);

        points(i, :) = [xc yc];
    end
    
elseif nd == 3
    for i = 1:nLabels
        % extract points of the current particle
        [y x z] = find(img==labels(i));

        % compute coordiante of particle centroid
        xc = mean(x);
        yc = mean(y);
        zc = mean(z);

        points(i, :) = [xc yc zc];
    end
    
else    
    error('Input image must be 2D or 3D');
    
end

function [circle labels] = imInscribedCircle(lbl, varargin)
%IMINSCRIBEDCIRCLE Maximal circle inscribed in a particle
%
%   CIRC = imInscribedCircle(IMG)
%   Computes the maximal circle inscribed in a given particle, or
%   around each labeled particle in the input image.
%
%   Example
%   % Draw a commplex particle together with its enclosing circle
%     img = imFillHoles(imread('circles.png'));
%     imshow(img); hold on;
%     circ = imInscribedCircle(img);
%     drawCircle(circ, 'linewidth', 2)
%
%   % Compute and display the equivalent ellipses of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     circles = imInscribedCircle(lbl);
%     imshow(img); hold on;
%     drawCircle(circles, 'linewidth', 2, 'color', 'g');
%
%   See also
%     drawCircle, imEnclosingCircle, imInertiaEllipse, imInertiaEllipse
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% extract the set of labels, and remove label for background
labels = unique(lbl(:));
labels(labels==0) = [];

nLabels = length(labels);

% allocate memory for result
circle = zeros(nLabels, 3);

for i = 1:nLabels
    % compute distance map
    distMap = imChamferDistance(lbl==i);
    
    % find value and position of the maximum
    maxi = max(distMap(:));    
    [yc xc] = find(distMap==maxi, 1, 'first');
    
    circle(i,:) = [xc yc maxi];
end


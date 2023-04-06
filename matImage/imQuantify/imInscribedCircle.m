function [circle, labels] = imInscribedCircle(lbl, varargin)
% Maximal circle inscribed in a region.
%
%   CIRC = imInscribedCircle(IMG)
%   Computes the maximal circle inscribed in a given particle, or
%   around each labeled particle in the input image.
%
%   CIRC = imInscribedCircle(IMG, SPACING)
%   CIRC = imInscribedCircle(IMG, SPACING, ORIGIN)
%   Takes into account the spatical calibration to compute the results in
%   physical units. Both SPACING and ORIGIN are 1-by-2 row vectors, that
%   correspond to the spacing between pixels and to the position of the
%   first pixel, respectively.
%
%   CIRC = imInscribedCircle(..., LABELS)
%   Specify the labels for which the inscribed circle needs to be computed.
%   The result is a N-by-3 array with as many rows as the number of labels.
%
%
%   Example
%   % Draw a commplex particle together with its enclosing circle
%     img = imFillHoles(imread('circles.png'));
%     imshow(img); hold on;
%     circ = imInscribedCircle(img);
%     drawCircle(circ, 'LineWidth', 2)
%
%   % Compute and display the equivalent ellipses of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     circles = imInscribedCircle(lbl);
%     imshow(img); hold on;
%     drawCircle(circles, 'LineWidth', 2, 'Color', 'g');
%
%   See also
%     drawCircle, imEnclosingCircle, imInertiaEllipse, imInscribedBall
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-07-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Process input arguments

% default values
spacing = [1 1];
origin  = [1 1];
calib   = false;

% extract spacing
if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = [0 0];
end

% extract origin
if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
    origin = varargin{1};
    varargin(1) = [];
end

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(lbl);
end
nLabels = length(labels);


%% Main processing

% allocate memory for result
circle = zeros(nLabels, 3);

for iLabel = 1:nLabels
    % compute distance map
    distMap = imDistanceMap(lbl==labels(iLabel));
    
    % find value and position of the maximum
    maxi = max(distMap(:));    
    [yc, xc] = find(distMap==maxi, 1, 'first');
    
    circle(iLabel,:) = [xc yc maxi];
end

% apply spatial calibration
if calib
    circle(:,1:2) = bsxfun(@plus, bsxfun(@times, circle(:,1:2) - 1, spacing), origin);
    circle(:,3) = circle(:,3) * spacing(1);
end

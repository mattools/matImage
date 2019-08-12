function [ellipse, labels] = imInertiaEllipse(img, varargin)
%IMINERTIAELLIPSE Inertia ellipse of a binary or label image
%
%   Deprecated, use 'imEquivalentEllipse' instead.
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
%   ELLI = imInertiaEllipse(IMG, SPACING);
%   ELLI = imInertiaEllipse(IMG, SPACING, ORIGIN);
%   Specifies the spatial calibration of image. Both SPACING and ORIGIN are
%   1-by-2 row vectors. SPACING = [SX SY] contains the size of a pixel.
%   ORIGIN = [OX OY] contains the center position of the top-left pixel of
%   image. 
%   If no calibration is specified, spacing = [1 1] and origin = [1 1] are
%   used. If only the sapcing is specified, the origin is set to [0 0].
%
%   ELLI = imInertiaEllipse(..., LABELS)
%   Specify the labels for which the inertia ellipse needs to be computed.
%   The result is a N-by-5 array with as many rows as the number of labels.
%
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
%     imEquivalentEllipse
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

warning('MatImage:deprecated', ...
    'function imInertiaEllipse is obsolete, use imEquivalentEllipse instead');

%% extract spatial calibration

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
end

%% Initialisations

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);

% allocate memory for result
ellipse = zeros(nLabels, 5);


%% Extract ellipse corresponding to each label

for i = 1:nLabels
    % extract points of the current particle
    [y, x] = find(img==labels(i));
    
    % transform to physical space if needed
    if calib
        x = (x-1) * spacing(1) + origin(1);
        y = (y-1) * spacing(2) + origin(2);
    end
    
    % compute centroid, used as center of inertia ellipse
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
    Ixx = sum(x.^2) / n + spacing(1)^2/12;
    Iyy = sum(y.^2) / n + spacing(2)^2/12;
    Ixy = sum(x.*y) / n;
    
    % compute ellipse semi-axis lengths
    common = sqrt( (Ixx - Iyy)^2 + 4 * Ixy^2);
    ra = sqrt(2) * sqrt(Ixx + Iyy + common);
    rb = sqrt(2) * sqrt(Ixx + Iyy - common);
    
    % compute ellipse angle and convert into degrees
    theta = atan2(2 * Ixy, Ixx - Iyy) / 2;
    theta = theta * 180 / pi;
    
    % create the resulting inertia ellipse
    ellipse(i,:) = [xc yc ra rb theta];
end

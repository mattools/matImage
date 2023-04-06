function [ellipse, labels] = imEquivalentEllipse(img, varargin)
% Equivalent ellipse of a binary or label image.
%
%   ELLI = imEquivalentEllipse(IMG)
%   Computes the ellipse with same second order moments for each region in
%   label image IMG. If the case of a binary image, a single ellipse
%   corresponding to the foreground (i.e. to the region with pixel value 1)
%   will be computed. 
%
%   The result is a N-by-5 array ELLI = [XC YC A B THETA], containing
%   coordinates of ellipse center, lengths of semi major and minor axes,
%   and the orientation (given in degrees, counter-clockwise, in the
%   direction of the greatest axis).
%
%   Note: the same result could be obtained with the regionprops function
%   from the image processing toolbox. One  advantage of using the
%   'imEquivalentEllipse' function is that equivalent ellipses can be
%   obtained in one call. Orientation of both functions are not consistent. 
%
%   ELLI = imEquivalentEllipse(IMG, SPACING);
%   ELLI = imEquivalentEllipse(IMG, SPACING, ORIGIN);
%   Specifies the spatial calibration of image. Both SPACING and ORIGIN are
%   1-by-2 row vectors. SPACING = [SX SY] contains the size of a pixel.
%   ORIGIN = [OX OY] contains the center position of the top-left pixel of
%   image. 
%   If no calibration is specified, spacing = [1 1] and origin = [1 1] are
%   used. If only the sapcing is specified, the origin is set to [0 0].
%
%   ELLI = imEquivalentEllipse(..., LABELS)
%   Specifies the labels for which the equivalent ellipse needs to be
%   computed. The result is a N-by-5 array with as many rows as the number
%   of labels.
%
%
%   Example
%   % Draw a commplex particle together with its equivalent ellipse
%     img = imread('circles.png');
%     imshow(img); hold on;
%     elli = imEquivalentEllipse(img);
%     drawEllipse(elli)
%
%   % Compute and display the equivalent ellipses of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     ellipses = imEquivalentEllipse(lbl);
%     imshow(img); hold on;
%     drawEllipse(ellipses, 'linewidth', 2, 'color', 'g');
%
%   See also
%     imPrincipalAxes, imEquivalentEllipsoid, drawEllipse, imOrientedBox
%     regionprops, equivalentEllipse
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Process input arguments

% default spatial calibration
spacing = [1 1];
origin  = [1 1];
calib   = false;

% extract spacing
if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = [0 0];
    
    % extract origin
    if ~isempty(varargin) && sum(size(varargin{1}) == [1 2]) == 2
        origin = varargin{1};
        varargin(1) = [];
    end
end

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end


%% Initialisations

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
    
    % compute centroid, used as center of equivalent ellipse
    xc = mean(x);
    yc = mean(y);
    
    % recenter points (should be better for numerical accuracy)
    x = x - xc;
    y = y - yc;

    % number of points
    n = length(x);
    
    % compute second order parameters. 1/12 is the contribution of a single
    % pixel, then for regions with only one pixel the resulting ellipse has
    % positive radii.
    Ixx = sum(x.^2) / n + spacing(1)^2/12;
    Iyy = sum(y.^2) / n + spacing(2)^2/12;
    Ixy = sum(x.*y) / n;
    
    % compute semi-axis lengths of ellipse
    common = sqrt( (Ixx - Iyy)^2 + 4 * Ixy^2);
    ra = sqrt(2) * sqrt(Ixx + Iyy + common);
    rb = sqrt(2) * sqrt(Ixx + Iyy - common);
    
    % compute ellipse angle and convert into degrees
    theta = atan2(2 * Ixy, Ixx - Iyy) / 2;
    theta = theta * 180 / pi;
    
    % create the resulting equivalent ellipse
    ellipse(i,:) = [xc yc ra rb theta];
end

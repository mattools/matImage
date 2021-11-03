function [diam, thetaMax] = imMaxFeretDiameter(img, varargin)
% Maximum Feret diameter of a binary or label image.
%
%   FD = imMaxFeretDiameter(IMG)
%   Computes the maximum Feret diameter of particles in label image IMG.
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each particle in IMG.
%
%   [FD, THETAMAX] = imMaxFeretDiameter(IMG)
%   Also returns the direction for which the diameter is maximal. THETAMAX
%   is given in degrees, between 0 and 180.
%
%   FD = imMaxFeretDiameter(IMG, LABELS)
%   Specify the labels for which the Feret diameter needs to be computed.
%   The result is a N-by-1 array with as many rows as the number of labels.
%
%
%   Example
%     img = imread('circles.png');
%     diam = imMaxFeretDiameter(img)
%     diam =
%         272.7144
%
%   See also
%     imFeretDiameter, imOrientedBox
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-07-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Process input arguments

% extract orientations
thetas = 180;
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    thetas = varargin{1};
    varargin(1) = [];
end

if isscalar(thetas)
    % assume this is the number of directions to use
    thetas = linspace(0, 180, thetas+1);
    thetas = thetas(1:end-1);
end

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
diam = zeros(nLabels, 1);
thetaMax = zeros(nLabels, 1);

% for each label, compute set of diameters, and keep the max
for i = 1:nLabels
    if calib
        diams = imFeretDiameter(img == labels(i), thetas, spacing, origin);
    else
        diams = imFeretDiameter(img == labels(i), thetas);
    end
    
    % find max diameters, with indices
    [diam(i), ind] = max(diams, [], 2);
    
    % keep max orientation
    thetaMax(i) = thetas(ind);
end


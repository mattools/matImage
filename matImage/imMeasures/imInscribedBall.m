function [ball, labels] = imInscribedBall(lbl, varargin)
%IMINSCRIBEDBALL Maximal ball inscribed in a 3D particle
%
%   BALL = imInscribedBall(IMG)
%   Computes the maximal ball inscribed in a given 3D particle, or
%   around each labeled particle in the input image.
%
%   BALL = imInscribedBall(IMG, LABELS)
%   Specify the labels for which the inscribed ball needs to be computed.
%   The result is a N-by-3 array with as many rows as the number of labels.
%
%   Examples
%   % Test with a discretized ball
%     img = discreteBall(1:100, 1:100, 1:100, [40 50 60 35]);
%     ball = imInscribedBall(img)
%     ball =
%         40    50    60    35
%
%   % Check with a an octant of ball
%     img = discreteBall(1:100, 1:100, 1:100, [90 90 90 80]);
%     img(91:end, :,:) = 0;
%     img(:, 91:end, :) = 0;
%     img(:, :, 91:end) = 0;
%     ball = imInscribedBall(img)
%     ball =
%         61    61    61    30
% 
%   See also
%     drawSphere, imInscribedCircle, imInertiaEllipsoid
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-07-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

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

% allocate memory for result (3 coords + 1 radius)
ball = zeros(nLabels, 4);

for i = 1:nLabels
    % compute distance map from background
    distMap = bwdist(lbl ~= labels(i));
    
    % find value and position of the maximum
    [maxi, inds] = max(distMap(:));
    [yb, xb, zb] = ind2sub(size(distMap), inds);
    
    ball(i,:) = [xb yb zb maxi];
end


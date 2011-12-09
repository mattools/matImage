function [diam thetaMax] = imMaxFeretDiameter(img, varargin)
%IMMAXFERETDIAMETER Maximum Feret diameter of a binary or label image
%
%   FD = imMaxFeretDiameter(IMG)
%   Computes the maximum Feret diameter of particles in label image IMG.
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each particle in IMG.
%
%   [FD THETAMAX] = imMaxFeretDiameter(IMG)
%   Also returns the direction for which the diameter is maximal. THETAMAX
%   is given in degrees, between 0 and 180.
%
%
%   Example
%   imMaxFeretDiameter
%
%   See also
%   imFeretDiameter, imOrientedBox
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


% extract orientations
if isempty(varargin)
    thetas = linspace(0, 180, 180+1);
    thetas = thetas(1:end-1);
else 
    thetas = varargin{1};
    if isscalar(thetas)
        % assume this is the number of directions to use
        thetas = linspace(0, 180, thetas+1);
        thetas = thetas(1:end-1);
    end
end

% number of particles
labels = unique(img(:));
labels(labels==0) = [];
nLabels = length(labels);

% allocate memory for result
diam = zeros(nLabels, 1);
thetaMax = zeros(nLabels, 1);

% for each particle, compute set of diamters, and find max
for i = 1:nLabels
    diams = imFeretDiameter(img == labels(i), thetas);
    
    % find max diameters, with indices
    [diam(i) ind] = max(diams, [], 2);
    
    % keep max orientation
    thetaMax(i) = thetas(ind);
end


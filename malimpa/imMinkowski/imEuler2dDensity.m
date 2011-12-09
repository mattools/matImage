function [epcd labels] = imEuler2dDensity(img, varargin)
% Euler density in a 2D image
%   EPCD = imEuler2dDensity(IMG)
%
%   Example
%   imEuler2dDensity
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 2
    error('first argument should be a 2D image');
end

% check image resolution
delta = [1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    epcd = zeros(length(labels), 1);
    for i = 1:length(labels)
        epcd(i) = imEuler2dDensity(img == labels(i), varargin{:});
    end
    return;
end

% Euler-Poincare Characteristic of each component in image
chi     = imEuler2dEstimate(img, varargin{:});

% total area of image
totalArea = numel(img) * prod(delta);

% compute area density
epcd = chi / totalArea;



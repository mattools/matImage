function [sd labels] = imSurfaceDensity(img, varargin)
% Surface area density of a 3D binary structure
%
%   Sv = imSurfaceDensity(IMG)
%
%   Example
%   imSurfaceDensity
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    sd = zeros(length(labels), 1);
    for i=1:length(labels)
        sd(i) = imSurfaceDensity(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% check image resolution
delta = [1 1 1];
if ~isempty(varargin)
    var = varargin{end};
    if length(var)==3
        delta = varargin{end};
    end
end

% component area in image
s = imSurfaceEstimate(img, varargin{:});

% total volume of image (without edges)
refVol = prod(size(img)-1)*prod(delta);

% compute area density
sd = s / refVol;

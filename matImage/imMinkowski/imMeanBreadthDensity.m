function [breadth, labels] = imMeanBreadthDensity(img, varargin)
%IMMEANBREADTHDENSITY Mean breadth density of a 3D binary structure
%
%   MV = imMeanBreadthDensity(IMG)
%   MV = imMeanBreadthDensity(IMG, RESOL)
%   MV = imMeanBreadthDensity(IMG, RESOL, NDIRS)
%
%   Example
%   imMeanBreadthDensity
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-20,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    sd = zeros(length(labels), 1);
    for i = 1:length(labels)
        sd(i) = imMeanBreadthDensity(img==labels(i), varargin{:});
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
breadth = imMeanBreadthEstimate(img, varargin{:});

% total volume of image (without edges)
refVol = prod(size(img)-1) * prod(delta);

% compute area density
breadth = breadth / refVol;

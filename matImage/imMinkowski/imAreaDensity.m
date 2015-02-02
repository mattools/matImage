function [ad, labels] = imAreaDensity(img, varargin)
% Compute area density in a 2D image
%
%   DENSITY = imAreaDensity(IMG)
%
%   Example
%   imAreaDensity
%
%   See also
%   imArea
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=2 %#ok<ISMAT>
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    ad = zeros(length(labels), 1);
    for i=1:length(labels)
        ad(i) = imAreaDensity(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% component area in image
a = imArea(img);

% total area of image
totalArea = numel(img);

% compute area density
ad = a / totalArea;

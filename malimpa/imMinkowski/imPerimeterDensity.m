function [pd labels] = imPerimeterDensity(img, varargin)
% Perimeter density of a 2D binary structure, using Crofton formula
%
%   Pv = imPerimeterDensity(IMG)
%
%   Example
%   imPerimeterDensity
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
if ndims(img)~=2
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels==0) = [];
    
    % allocate result array
    nLabels = length(labels);
    perim = zeros(nLabels, 1);

    props = regionprops(img, 'BoundingBox');
    
    % compute perimeter of each label considered as binary image
    for i = 1:nLabels
        label = labels(i);
        bin = imcrop(img, props(label).BoundingBox) == label;
        perim(i) = imPerimeterDensity(bin, varargin{:});
    end
    
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% check image resolution
delta = [1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% component area in image
p = imPerimeterEstimate(img, varargin{:});

% total area of image
totalArea = prod(size(img)-1)*prod(delta);

% compute area density
pd = p / totalArea;

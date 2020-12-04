function [epcd, labels] = imEuler2dDensity(img, varargin)
% Euler density in a 2D image.
%   EPCD = imEuler2dDensity(IMG)
%
%   Example
%   imEuler2dDensity
%
%   See also
%     imEuler2d, imEuler2dEstimate
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('first argument should be a 2D image');
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

% default connectivity
conn = 4;

% default image resolution
delta = [1 1];

% parse parameter name-value pairs
while ~isempty(varargin)
    var = varargin{1};
    
    if isnumeric(var)        
        % option is either number of directions or resolution
        if isscalar(var)
            conn = var;
        else
            delta = var;
        end
        varargin(1) = [];
        
    elseif ischar(var)
        if length(varargin) < 2
            error('Parameter name must be followed by parameter value');
        end
    
        if strcmpi(var, 'conn')
            conn = varargin{2};
        elseif strcmpi(var, 'resolution')
            delta = varargin{2};
        else
            error(['Unknown parameter name: ' var]);
        end
        
        varargin(1:2) = [];
    end
end

% Euler-Poincare Characteristic of each component in image
chi     = imEuler2dEstimate(img, conn);

% total area of image, minus borders
obsArea = prod(size(img) - 1) * prod(delta);

% compute area density
epcd = chi / obsArea;



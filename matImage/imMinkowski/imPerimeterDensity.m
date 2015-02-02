function [pd, labels] = imPerimeterDensity(img, varargin)
% Perimeter density of a 2D binary structure, using Crofton formula
%
%   Pv = imPerimeterDensity(IMG)
%
%   Example
%   imPerimeterDensity
%
%   See also
%   imPerimeter

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Pre-processing

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels==0) = [];
    
    % allocate result array
    nLabels = length(labels);
    pd = zeros(nLabels, 1);

    props = regionprops(img, 'BoundingBox');
    
    % compute perimeter of each label considered as binary image
    for i = 1:nLabels
        label = labels(i);
        bin = imcrop(img, props(label).BoundingBox) == label;
        pd(i) = imPerimeterDensity(bin, varargin{:});
    end
    
    return;
end


%% Extract input arguments

% in case of binary image, compute only one label
labels = 1;

% default number of directions
nDirs = 4;

% default image resolution
delta = [1 1];

% parse parameter name-value pairs
while ~isempty(varargin)
    var = varargin{1};
    
    if isnumeric(var)        
        % option is either number of directions or resolution
        if isscalar(var)
            nDirs = var;
        else
            delta = var;
        end
        varargin(1) = [];
        
    elseif ischar(var)
        if length(varargin) < 2
            error('Parameter name must be followed by parameter value');
        end
    
        if strcmpi(var, 'ndirs')
            nDirs = varargin{2};
        elseif strcmpi(var, 'resolution')
            delta = varargin{2};
        else
            error(['Unknown parameter name: ' var]);
        end
        
        varargin(1:2) = [];
    end
end


%% Compute perimeter within image, and normalize by area

% component area in image
p = imPerimeterEstimate(img, nDirs, delta);

% total area of image, without borders
totalArea = prod(size(img)-1) * prod(delta);

% compute perimeter density
pd = p / totalArea;

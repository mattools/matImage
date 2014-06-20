function [perim labels] = imPerimeter(img, varargin)
%Perimeter of a 2D image using Crofton formula
%
%   P = imPerimeter(IMG);
%   Return an estimate of the perimeter of the image, computed by
%   counting intersections with 2D lines, and using discretized version of
%   the Crofton formula.
%
%   P = imPerimeter(IMG, NDIR);
%   Specify number of directions to use. Use either 2 or 4 (the default).
%
%   P = imPerimeter(IMG, NDIR, SCALE);
%   Also specify scale of image tile. SCALE si a 1-by-2 array, containing
%   pixel size in each physical direction. Default is [1 1].
%   SCALE(1) coresponds to DX, and SCALE(2) coresponds to DY.
%   
%   [P LABELS] = imPerimeter(LBL, ...)
%   Process a label image, and return also the labels for which a value was
%   computed.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Pre-processing

% check image dimension
if ndims(img) ~= 2
    error('First argument should be a 2D image');
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
        perim(i) = imPerimeter(bin, varargin{:});
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


%% Initialisations 

% distances between a pixel and its neighbours.
% (d1 is dx, d2 is dy)
d1  = delta(1);
d2  = delta(2);
d12 = hypot(d1, d2);

% area of a pixel (used for computing line densities)
vol = d1 * d2;

% size of image
dim = size(img);
D1  = dim(1);
D2  = dim(2);


%% Processing for 2 or 4 main directions

% compute number of pixels, equal to the total number of vertices in graph
% reconstructions 
nv = sum(img(:));

% compute number of connected components along orthogonal lines
% (Use Graph-based formula: chi = nVertices - nEdges)
n1 = nv - sum(sum(img(:, 1:D2-1) & img(:, 2:D2)));
n2 = nv - sum(sum(img(1:D1-1, :) & img(2:D1, :)));

% Compute perimeter using 2 directions
% equivalent to:
% perim = mean([n1/(d1/a) n2/(d2/a)])*pi/2;
% with a = d1*d2 being the area of the unit tile
if nDirs == 2
    perim = pi * mean([n1*d2 n2*d1]);
    return;
end


%% Processing specific to 4 directions

% Number of connected components along diagonal lines
n3 = nv - sum(sum(img(1:D1-1, 1:D2-1) & img(2:D1,   2:D2)));
n4 = nv - sum(sum(img(1:D1-1, 2:D2  ) & img(2:D1, 1:D2-1)));

% compute direction weights (necessary for anisotropic case)
if any(delta ~= 1);
    c = computeDirectionWeights2d4(delta)';
else
    c = [1 1 1 1] / 4;
end

% compute weighted average over directions
perim = pi * sum( [n1/d1 n2/d2 n3/d12 n4/d12] * vol .* c );

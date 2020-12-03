function [perim, labels] = imPerimeter(img, varargin)
% Perimeter of regions within a 2D binary or label image.
%
%   P = imPerimeter(IMG);
%   Return an estimate of the perimeter of the image, computed by
%   counting intersections with 2D lines, and using discretized version of
%   the Crofton formula.
%
%   P = imPerimeter(IMG, NDIR);
%   Specify number of directions to use. Use either 2 or 4 (the default).
%
%   P = imPerimeter(..., SPACING);
%   Also specify the spatial calibration of the image. SPACING is a 1-by-2
%   row vector, containing the pixel size in each physical direction.
%   Default is [1 1]. SPACING(1) coresponds to DX, and SPACING(2)
%   coresponds to DY. 
%   
%   [P, LABELS] = imPerimeter(LBL, ...)
%   Process a label image, and return also the labels for which a value was
%   computed.
%
%   Example
%     % compute the perimeter of a binary disk of radius 40
%     lx = 1:100; ly = 1:100;
%     [x, y] = meshgrid(lx, ly);
%     img = hypot(x - 50.12, y - 50.23) < 40;
%     imPerimeter(img)
%     ans =
%         251.1751
%     % to be compared to (2 * pi * 40), approximately 251.3274
%
%   See also
%     imArea, imSurfaceArea, imMeanBreadth, imPerimeterLut

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRAE - Cepia Software Platform.


%% Parse input arguments

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('First argument should be a 2D image');
end

% default values of parameters
nDirs = 4;
delta = [1 1];
labels = [];

% parse parameter name-value pairs
while ~isempty(varargin)
    var1 = varargin{1};
    
    if isnumeric(var1)
        % option can be number of directions, spatial calibration, or list
        % of labels
        if isscalar(var1)
            nDirs = var1;
        elseif all(size(var1) == [1 2])
            delta = var1;
        elseif size(var1, 2) == 1
            labels = var1;
        end
        varargin(1) = [];
        
    elseif ischar(var1)
        if length(varargin) < 2
            error('Parameter name must be followed by parameter value');
        end
        
        if strcmpi(var1, 'ndirs')
            nDirs = varargin{2};
        elseif strcmpi(var1, 'resolution')
            delta = varargin{2};
        else
            error(['Unknown parameter name: ' var1]);
        end
        
        varargin(1:2) = [];
    end
end


%% Process label images

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels if necessary (considers 0 as background)
    if isempty(labels)
        labels = imFindLabels(img);
    end
    
    % allocate result array
    nLabels = length(labels);
    perim = zeros(nLabels, 1);
    
    % compute bounding box of each region
    boxes = imBoundingBox(img, labels);
    
    % compute perimeter of each region considered as binary image
    for i = 1:nLabels
        label = labels(i);
        
        % convert bounding box to image extent, in x and y directions
        i0 = ceil(boxes(i, [3 1]));
        i1 = floor(boxes(i, [4 2]));
        
        bin = img(i0(1):i1(1), i0(2):i1(2)) == label;
        perim(i) = imPerimeter(bin, nDirs, delta);
    end
    
    return;
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
if any(delta ~= 1)
    c = computeDirectionWeights2d4(delta)';
else
    c = [1 1 1 1] / 4;
end

% compute weighted average over directions
perim = pi * sum( [n1/d1 n2/d2 n3/d12 n4/d12] * vol .* c );

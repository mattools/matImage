function [area, labels] = imArea(img, varargin)
% Area of regions within a 2D binary or label image.
%
%   A = imArea(IMG);
%   Compute the area of the regions in the image IMG. IMG can be either a
%   binary image, or a label image. If IMG is binary, a single area is
%   returned. In the case of a label image, the area of each region is 
%   returned in a column vector with as many elements as the number of
%   regions.
%
%   A = imArea(..., SPACING);
%   Also specify the spatial calibration of the image. SPACING is a 1-by-2
%   row vector, containing the pixel size in each physical direction.
%   Default is [1 1]. SPACING(1) coresponds to DX, and SPACING(2)
%   coresponds to DY. 
%   
%   A = imArea(..., LABELS);
%   In the case of a label image, specifies the labels for which the area
%   need to be computed.
%
%   See Also
%     regionprops, imPerimeter, imEuler2d
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Initialisations

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('first argument should be a 2D binary or label image');
end

% default options
labels = [];
delta = [1 1];

% parse input arguments
while ~isempty(varargin)
    var1 = varargin{1};
    varargin(1) = [];
    
    if size(var1, 2) == 1
        % the labels to compute
        labels = var1;
    elseif all(size(var1) == [1 2])
        % spatial calibration
        delta = var1;
    else
        error('Unable to interpret input argument');
    end
end


%% Process label image

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels if necessary (considers 0 as background)
    if isempty(labels)
        labels = imFindLabels(img);
    end
    
    % allocate result array
    nLabels = length(labels);
    area = zeros(nLabels, 1);
    
    % compute bounding box of each region
    boxes = imBoundingBox(img, labels);
    
    % compute area of each region considered as binary image
    for i = 1:nLabels
        label = labels(i);
        
        % convert bounding box to image extent, in x, y and z directions
        i0 = ceil(boxes(i, [3 1]));
        i1 = floor(boxes(i, [4 2]));
        
        bin = img(i0(1):i1(1), i0(2):i1(2)) == label;
        area(i) = sum(bin(:)) * prod(delta);
    end
    
    return;
end


%% Process binary image

% compute area, multiplied by image resolution
area = sum(img(:)) * prod(delta);
labels = 1;

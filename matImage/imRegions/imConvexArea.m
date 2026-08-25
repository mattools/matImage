function [cvx_area, labels] = imConvexArea(img, varargin)
%IMCONVEXAREA Convex area of the region(s) within image.
%
%   CA = imConvexArea(IMG)
%   Computes the convex area of the regions within the image IMG. The
%   convex area of a region is defined as the area of the convex image of
%   the region. 
%   IMG can be either a binary image, or a label map. If IMG is binary, a
%   single area is returned. In the case of a label image, the convex area
%   of each region is returned in a column vector with as many elements as
%   the number of regions.
%
%   Example
%   imConvexArea
%
%   See also
%     imArea, imConvexImage, regionprops
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-18,    using Matlab 25.1.0.2943329 (R2025a)
% Copyright 2026 INRAE.

%% Initializations

% check image dimension
if ndims(img) ~= 2 %#ok<ISMAT>
    error('first argument should be a 2D binary or label image');
end

% default options
labels = [];
spacings = [1 1];

% parse input arguments
while ~isempty(varargin)
    var1 = varargin{1};
    varargin(1) = [];
    
    if size(var1, 2) == 1
        % the labels to compute
        labels = var1;
    elseif all(size(var1) == [1 2])
        % spatial calibration
        spacings = var1;
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
    cvx_area = zeros(nLabels, 1);
    
    % compute bounding box of each region
    boxes = imBoundingBox(img, labels);
    
    % compute area of each region considered as binary image
    for i = 1:nLabels
        label = labels(i);
        
        % convert bounding box to image extent, in x, and y
        i0 = ceil(boxes(i, [3 1]));
        i1 = floor(boxes(i, [4 2]));
        
        bin = img(i0(1):i1(1), i0(2):i1(2)) == label;
        bin2 = imConvexImage(bin);
        cvx_area(i) = sum(bin2(:)) * prod(spacings);
    end
    
    return;
end


%% Process binary image

% compute area, multiplied by image resolution
bin2 = imConvexImage(img);
cvx_area = sum(bin2(:)) * prod(spacings);
labels = 1;

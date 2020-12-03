function [vol, labels] = imVolume(img, varargin)
% Volume of regions within a 3D binary or label image.
%
%   V = imVolume(IMG);
%   Compute volume of the image. IMG is either a binary image, or a label
%   image. In the case of a label image, the area of each labeled area is
%   returned in a column vector with as many elements as the number of
%   labels.
%
%   V = imVolume(IMG, SCALE);
%   Also specify scale of image tile. SCALE si a 1-by-3 array, containing
%   voxel size in each direction.
%   
%   See Also
%   imVolumeDensity, imSurfaceArea, imMeanBreadth
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRAE - Cepia Software Platform.


%% Parse input arguments

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D binary or label image');
end

% the labels to compute
labels = [];

% default spatial calibration
delta = [1 1 1];

% parse parameter name-value pairs
while ~isempty(varargin)
    var1 = varargin{1};
    varargin(1) = [];
    
    if isnumeric(var1)
        % option can be number of directions, spatial calibration, or list
        % of labels
        if all(size(var1) == [1 3])
            % spatial calibration
            delta = var1;
        elseif ~isscalar(var1) && size(var1, 2) == 1
            % list of labels to compute
            labels = var1;
        else
            error('Unable to parse input argument');
        end
    else
        error('Expect numeric input only');
    end
end


%% Process label images

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels if necessary (considers 0 as background)
    if isempty(labels)
        labels = imFindLabels(img);
    end
    
    % allocate memory
    vol = zeros(length(labels), 1);
    
    % iterate over labels
    for i = 1:length(labels)
        vol(i) = imVolume(img==labels(i), delta);
    end
    return;
end


%% Process binary images

% in case of binary image, compute only one label...
labels = 1;

% compute area, multiplied by image resolution
vol = sum(img(:)) * prod(delta);

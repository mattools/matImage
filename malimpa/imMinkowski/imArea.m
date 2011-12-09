function [area labels] = imArea(img, varargin)
% Compute area of binary 2D image 
%
%   A = imArea(IMG);
%   Compute area of the image. IMG is either a binary image, or a label
%   image. In the case of a label image, the area of each labeled area is
%   returned in a column vector with as many elements as the number of
%   labels.
%
%   A = imArea(IMG, SCALE);
%   Also specify scale of image tile. SCALE si a 2x1 array, containing
%   pixel size in each direction.
%   
%   See Also
%   regionprops, imPerimeter, imEuler2d
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=2
    error('first argument should be a 2D binary or label image');
end

% check image resolution
delta = [1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels==0) = [];
    
    % allocate result array
    nLabels = length(labels);
    area = zeros(nLabels, 1);
    
    % compute perimeter of each label considered as binary image
    for i = 1:nLabels
        label = labels(i);
        area(i) = sum(img(:)==label) * prod(delta);
    end
    
    return;
end


% compute area, multiplied by image resolution
area = sum(img(:)) * prod(delta);
labels = 1;

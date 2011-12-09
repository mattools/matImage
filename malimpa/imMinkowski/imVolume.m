function [vol labels] = imVolume(img, varargin)
% Volume measure of a 3D binary structure
%
%   V = imVolume(IMG);
%   Compute volume of the image. IMG is either a binary image, or a label
%   image. In the case of a label image, the area of each labeled area is
%   returned in a column vector with as many elements as the number of
%   labels.
%
%   V = imVolume(IMG, SCALE);
%   Also specify scale of image tile. SCALE si a 3x1 array, containing
%   voxel size in each direction.
%   
%   See Also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=3
    error('first argument should be a 2D binary or label image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    vol = zeros(length(labels), 1);
    for i=1:length(labels)
        vol(i) = imVolume(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% check image resolution
delta = [1 1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% compute area, multiplied by image resolution
vol = sum(img(:))*prod(delta);

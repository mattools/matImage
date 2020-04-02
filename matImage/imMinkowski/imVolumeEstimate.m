function vol = imVolumeEstimate(img, varargin)
%Estimate volume of a 3D binary structure with edge correction
%
%   Vest = imVolumeEstimate(IMG);
%   Vest = imVolumeEstimate(IMG, DELTA);
%
%   Example
%   imVolumeEstimate
%
%   See also
%   imVolume, imSurfaceEstimate

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Input arguments processing

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D binary or label image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    vol = zeros(length(labels), 1);
    for i = 1:length(labels)
        vol(i) = imVolumeEstimate(img==labels(i), varargin{:});
    end
    return;
end

% check image resolution
delta = [1 1 1];
if ~isempty(varargin)
    delta = varargin{1};
end


%% main processing

% compute volume in whole image
vol = sum(img(:));

% compute volume on border faces
f1 = sum(sum(sum(img([1 end], :, :))));
f2 = sum(sum(sum(img(:, [1 end], :))));
f3 = sum(sum(sum(img(:, :, [1 end]))));

% compute volume on border edges
e1 = sum(sum(sum(img(:, [1 end], [1 end]))));
e2 = sum(sum(sum(img([1 end], :, [1 end]))));
e3 = sum(sum(sum(img([1 end], [1 end], :))));

% compute volume on corners
v = sum(sum(sum(img([1 end], [1 end], [1 end]))));

% estimate area using edge weighting according to multiplicity
vol = vol -(f1+f2+f3)/2 + (e1+e2+e3)/4 - v/8;

% multiply by volume of a single voxel
vol = vol * prod(delta);

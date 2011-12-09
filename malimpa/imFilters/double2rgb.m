function rgb = double2rgb(img, map, bounds, varargin)
%DOUBLE2RGB  Create a RGB image from double values
%
%   RGB = double2rgb(IMG, MAP, BOUNDS)
%   Scales the values in IMG between in the interval specified by BOUNDS,
%   then convert each value to the corresponding value of the color map
%   given in MAP.
%   If the image contains inf or NaN values, they stay black.
%
%   RGB = double2rgb(IMG, MAP)
%   Assumes extreme values are given by extreme values in image. Only
%   finite values are used for computing bounds.
%
%   RGB = double2rgb(IMG, MAP, BOUNDS, BACKGROUND)
%   Specifies the value of the background value for Nan and Inf values in
%   IMG. BACKGROUND should be a 1-by-3 row vector with values between 0 
%   and 1.
%
%   Example
%   % Converts peaks to RGB
%     rgb = double2rgb(peaks(128), jet, [-8 8]);
%     imshow(rgb);
%
%   % Display distance map as color image.
%     img = imread('circles.png');
%     bwd = bwdist(img);
%     rgb = double2rgb(bwd, jet, [], [1 1 1]);
%     imshow(rgb);
% 
%   See also
%   ind2rgb, angle2rgb
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% extract background value
bg = [0 0 0];
if ~isempty(varargin)
    bg = varargin{1};
end

% get valid pixels (finite value)
valid = isfinite(img);
if ~exist('bounds', 'var') || isempty(bounds)
    bounds = [min(img(valid)) max(img(valid))];
end

% convert finite values to indices between 1 and map length
n = size(map, 1);
inds = (img(valid) - bounds(1)) / (bounds(end) - bounds(1)) * (n-1);
inds = floor(min(max(inds, 0), n-1))+1;

% compute the 3 bands
dim = size(img);
r = ones(dim)*bg(1); r(valid) = map(inds, 1);
g = ones(dim)*bg(2); g(valid) = map(inds, 2);
b = ones(dim)*bg(3); b(valid) = map(inds, 3);

% concatenate the 3 bands to form an rgb image
if length(dim) == 2
    % case of 2D image
    rgb = cat(3, r, g, b);
    
else
    % case of 3D image: need to play with channels
    dim2 = [dim(1:2) 3 dim(3:end)];
    rgb = zeros(dim2, class(map));
    rgb(:,:,1,:) = r;
    rgb(:,:,2,:) = g;
    rgb(:,:,3,:) = b;
end

function ad = imVolumeDensity(img, varargin)
%Compute volume density of a 3D image
%
%   Vv = imVolumeDensity(IMG)
%
%   Example
%   imVolumeDensity
%
%   See also
%   imVolume, imAreaDensity
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=3
    error('first argument should be a 3D image');
end

% component volume in image
a = imVolume(img);

% total volume of image
totalArea = numel(img);

% compute volume density
ad = a / totalArea;

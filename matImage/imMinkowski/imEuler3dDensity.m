function chi = imEuler3dDensity(img, varargin)
%IMEULER3DDENSITY Compute Euler density in a 3D image
%
%   CHIv = imEuler3dDensity(IMG)
%   CHIv = imEuler3dDensity(IMG, CONN)
%
%   Example
%   imEuler3dDensity
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% check image resolution
delta = [1 1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    epcd = zeros(length(labels), 1);
    for i = 1:length(labels)
        epcd(i) = imEuler3dDensity(img==labels(i), varargin{:});
    end
    return;
end

% Euler-Poincare Cahracteristic of each component in image
chi = imEuler3dEstimate(img, varargin{:});

% total volume of image
totalVolume = numel(img) * prod(delta);

% compute area density
chi = chi / totalVolume;


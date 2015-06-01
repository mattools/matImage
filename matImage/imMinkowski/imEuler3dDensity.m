function chi = imEuler3dDensity(img, varargin)
%IMEULER3DDENSITY Compute Euler density in a 3D image
%
%   CHI_V = imEuler3dDensity(IMG)
%   CHI_V = imEuler3dDensity(IMG, CONN)
%   Compute Euler number estimate in a 3D image, and normalize by the
%   observed volume. This function is well suited for estimating
%   topological properties of a random material observed through a sampling
%   window.
%
%   Example
%   imEuler3dDensity
%
%   See also
%   imEuler3d, imEuler3dEstimate

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
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
obsVolume = prod(size(img) - 1) * prod(delta);

% compute area density
chi = chi / obsVolume;


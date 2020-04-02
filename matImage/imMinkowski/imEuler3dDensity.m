function chi = imEuler3dDensity(img, varargin)
% Compute Euler density in a 3D image.
%
%   CHI_V = imEuler3dDensity(IMG)
%   Compute Euler number estimate in a 3D image, and normalize by the
%   observed volume. This function is well suited for estimating
%   topological properties of a random material observed through a sampling
%   window.
%
%   CHI_V = imEuler3dDensity(IMG, CONN)
%   Specifies the connectivity to use to define whether two voxels are
%   neihbors or not. Can be either 6 (the default) or 26. 
%
%   Example
%   imEuler3dDensity
%
%   See also
%     imEuler3d, imEuler3dEstimate, imSurfaceAreaDensity, imMeanBreadthDensity

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRAE - Cepia Software Platform.


% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
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

% Process user input arguments
delta = [1 1 1];
conn = 6;
while ~isempty(varargin)
    var = varargin{1};
    if ~isnumeric(var)
        error('option should be numeric');
    end
    
    % option is either connectivity or resolution
    if isscalar(var)
        conn = var;
    else
        delta = var;
    end
    varargin(1) = [];
end

% Euler-Poincare Characteristic of each component in image
chi = imEuler3dEstimate(img, conn);

% total volume of image
obsVolume = prod(size(img) - 1) * prod(delta);

% compute area density
chi = chi / obsVolume;

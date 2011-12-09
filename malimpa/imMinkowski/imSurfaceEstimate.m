function [surf labels] = imSurfaceEstimate(img, varargin)
% Estimate surface area of a binary 3D structure
%
%   Usage
%   Sest = imSurfaceEstimate(IMG)
%
%   Descritpion
%   Estimate the surface area of the structure within the image, without
%   measuring surface area of borders.
%
%
%   Example
%   imSurfaceEstimate
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Process input arguments 

% check image dimension
if ndims(img)~=3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    surf = zeros(length(labels), 1);
    for i=1:length(labels)
        surf(i) = imSurfaceEstimate(img==labels(i), varargin{:});
    end
    return;
end


%% Process input arguments

% in case of binary image, compute only one label...
labels = 1;

% default number of directions
ndir = 3;

% default image resolution
delta = [1 1 1];

% Process user input arguments
while ~isempty(varargin)
    var = varargin{1};
    if ~isnumeric(var)
        error('option should be numeric');
    end
    
    % option is either connectivity or resolution
    if isscalar(var)
        ndir = var;
    else
        delta = var;
    end
    varargin(1) = [];
end



%% Process the 3 main space directions

% distances between a pixel and its neighbours.
d1  = delta(1);
d2  = delta(2);
d3  = delta(3);
vol = d1*d2*d3;

% compute number of intersections with lines in the 3 main directions
% (each intersection contribute to an half).
n1 = sum(sum(sum(img(:,1:end-1,:) ~= img(:,2:end,:))))/2;
n2 = sum(sum(sum(img(1:end-1,:,:) ~= img(2:end,:,:))))/2;
n3 = sum(sum(sum(img(:,:,1:end-1) ~= img(:,:,2:end))))/2;

% if only 3 directions are needed, compute the result and return
if ndir==3
    surf = 4/3*(n1/d1 + n2/d2 + n3/d3)*vol;
    return;
end


%% Process the other directions 

% compute intersections with lines contained in the main planes
n4 = sum(sum(sum(img(2:end,1:end-1,:)   ~= img(1:end-1,2:end,:))))/2;
n5 = sum(sum(sum(img(1:end-1,1:end-1,:) ~= img(2:end,2:end,:))))/2;
n6 = sum(sum(sum(img(:,2:end,1:end-1)   ~= img(:,1:end-1,2:end))))/2;
n7 = sum(sum(sum(img(:,1:end-1,1:end-1) ~= img(:,2:end,2:end))))/2;
n8 = sum(sum(sum(img(2:end,:,1:end-1)   ~= img(1:end-1,:,2:end))))/2;
n9 = sum(sum(sum(img(1:end-1,:,1:end-1) ~= img(2:end,:,2:end))))/2;

% compute intersections with lines corresponding to diagonals of the unit
% cube
n10 = sum(sum(sum(img(1:end-1,1:end-1,1:end-1)  ~= img(2:end,2:end,2:end))))/2;
n11 = sum(sum(sum(img(2:end,1:end-1,1:end-1)    ~= img(1:end-1,2:end,2:end))))/2;
n12 = sum(sum(sum(img(1:end-1,2:end,1:end-1)    ~= img(2:end,1:end-1,2:end))))/2;
n13 = sum(sum(sum(img(2:end,2:end,1:end-1)      ~= img(1:end-1,1:end-1,2:end))))/2;

% space between 2 voxels in each direction
d12 = hypot(d1, d2);
d13 = hypot(d1, d3);
d23 = hypot(d2, d3);
d123 = sqrt(d1^2 + d2^2 + d3^2);

% weights corresponding to surface fraction of spherical caps
c = computeDirectionWeights3d13(delta);

% For isotropic case, weights correspond to:
% c1 = 0.04577789120476 * 2;  % Ox
% c2 = 0.04577789120476 * 2;  % Oy
% c3 = 0.04577789120476 * 2;  % Oz
% c4 = 0.03698062787608 * 2;  % Oxy
% c6 = 0.03698062787608 * 2;  % Oxz
% c8 = 0.03698062787608 * 2;  % Oyz
% c10 = 0.03519563978232 * 2;  % Oxyz

% compute the weighted sum of each direction
% intersection count * direction weight / line density
surf = 4*(...
    (n1*c(1)/d1 + n2*c(2)/d2 + n3*c(3)/d3) + ...
    ((n4+n5)*c(4)/d12 + (n6+n7)*c(6)/d13 + (n8+n9)*c(8)/d23) + ...
    ((n10 + n11 + n12 + n13)*c(10)/d123) ) * vol;

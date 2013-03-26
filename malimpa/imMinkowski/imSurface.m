function [surf labels] = imSurface(img, varargin)
%IMSURFACE Surface area of a 3D binary structure
%
%   S = imSurface(IMG)
%   Estimates the surface area of the 3D binary structure represented by
%   IMG.
%
%   S = imSurface(IMG, NDIRS)
%   Specifies the number of directions used for estimating surface area.
%   NDIRS can be either 3 or 13, default is 3.
%
%   S = imSurface(..., RESOL)
%   Specifies image resolution. RESOL is a 1-by-3 row vector containing
%   resolution in the X, Y and Z direction (in that order).
%
%   S = imSurface(LBL)
%   [S L] = imSurface(LBL)
%   When LBL is a label image, returns the surface area of each label in
%   the 3D array, and eventually returns the indices of processed labels.
%
%
%   Example
%     % Create a binary image of a ball
%     [x y z] = meshgrid(1:100, 1:100, 1:100);
%     img = sqrt( (x-50.12).^2 + (y-50.23).^2 + (z-50.34).^2) < 40;
%     % compute surface area of the ball
%     S = imSurface(img)
%     S =
%         20108
%     % compare with theoretical value
%     Sth = 4*pi*40^2;
%     100 * (S - Sth) / Sth
%     ans = 
%         0.0090
%
%   See also
%     imVolume, imMeanBreadth, imSurfaceDensity, imJointSurface
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

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels == 0) = [];
    
    % allocate result array
    nLabels = length(labels);
    surf = zeros(nLabels, 1);

    props = regionprops(img, 'BoundingBox');
    
    % Compute surface area of each label considered as binary image
    % The computation is performed on a subset of the image for reducing
    % memory footprint.
    for i = 1:nLabels
        label = labels(i);
        box = props(label).BoundingBox;
        % convert bounding box to image extent, in x, y and z directions
        i0 = ceil(box([2 1 3]));
        i1 = i0 + box([5 4 6]) - 1;
        % crop image of current label
        bin = img(i0(1):i1(1), i0(2):i1(2), i0(3):i1(3)) == label;
        surf(i) = imSurface(bin, varargin{:});
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


%% Initialisations

% distances between a pixel and its neighbours.
d1  = delta(1);
d2  = delta(2);
d3  = delta(3);

% volume of a voxel (used for computing line densities)
vol = d1*d2*d3;


%% Main processing for 3 directions

% number of voxels
nv = sum(img(:));

% number of connected components along the 3 main directions
% (Use Graph-based formula: chi = nVertices - nEdges)
n1 = nv - sum(sum(sum(img(:,1:end-1,:) & img(:,2:end,:))));
n2 = nv - sum(sum(sum(img(1:end-1,:,:) & img(2:end,:,:))));
n3 = nv - sum(sum(sum(img(:,:,1:end-1) & img(:,:,2:end))));

if ndir == 3
    % compute surface area by averaging over the 3 main directions
    surf = 4/3 * (n1/d1 + n2/d2 + n3/d3) * vol;
    return;
end


%% Additional processing for 13 directions

% Number of connected components along diagonals contained in the three
% main planes
n4 = nv - sum(sum(sum(img(2:end,1:end-1,:)   & img(1:end-1,2:end,:))));
n5 = nv - sum(sum(sum(img(1:end-1,1:end-1,:) & img(2:end,2:end,:))));
n6 = nv - sum(sum(sum(img(:,2:end,1:end-1)   & img(:,1:end-1,2:end))));
n7 = nv - sum(sum(sum(img(:,1:end-1,1:end-1) & img(:,2:end,2:end))));
n8 = nv - sum(sum(sum(img(2:end,:,1:end-1)   & img(1:end-1,:,2:end))));
n9 = nv - sum(sum(sum(img(1:end-1,:,1:end-1) & img(2:end,:,2:end))));

%TODO: add the case of 9 directions ?

% Number of connected components along lines corresponding to diagonals of
% the unit cube
n10 = nv - sum(sum(sum(img(1:end-1,1:end-1,1:end-1) & img(2:end,2:end,2:end))));
n11 = nv - sum(sum(sum(img(2:end,1:end-1,1:end-1) & img(1:end-1,2:end,2:end))));
n12 = nv - sum(sum(sum(img(1:end-1,2:end,1:end-1) & img(2:end,1:end-1,2:end))));
n13 = nv - sum(sum(sum(img(2:end,2:end,1:end-1) & img(1:end-1,1:end-1,2:end))));

% space between 2 voxels in each direction
d12  = hypot(d1, d2);
d13  = hypot(d1, d3);
d23  = hypot(d2, d3);
d123 = sqrt(d1^2 + d2^2 + d3^2);

% Compute weights corresponding to surface fraction of spherical caps
% For isotropic case, weights correspond to:
% c1 = 0.04577789120476 * 2;  % Ox
% c2 = 0.04577789120476 * 2;  % Oy
% c3 = 0.04577789120476 * 2;  % Oz
% c4 = 0.03698062787608 * 2;  % Oxy
% c6 = 0.03698062787608 * 2;  % Oxz
% c8 = 0.03698062787608 * 2;  % Oyz
% c10 = 0.03519563978232 * 2;  % Oxyz
c = computeDirectionWeights3d13(delta);

% compute the weighted sum of each direction
% intersection count * direction weight / line density
surf = 4 * vol * (...
    n1*c(1)/d1 + n2*c(2)/d2 + n3*c(3)/d3 + ...
    (n4+n5)*c(4)/d12 + (n6+n7)*c(6)/d13 + (n8+n9)*c(8)/d23 + ...
    (n10 + n11 + n12 + n13)*c(10)/d123 );


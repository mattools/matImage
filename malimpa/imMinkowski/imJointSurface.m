function surf = imJointSurface(img, L1, L2, varargin)
%IMJOINTSURFACE Surface area of the interface between two labels
%
%   S = imJointSurface(LBL, L1, L2)
%   Estimates the joint surface area between the two labels L1 and L2 in
%   the label ulage LBL.
%
%   S = imJointSurface(LBL, L1, L2, NDIRS)
%   Specifies the number of directions used for estimating surface area.
%   NDIRS can be either 3 or 13, default is 3 directions.
%
%   S = imJointSurface(..., RESOL)
%   Specifies image resolution. RESOL is a 1-by-3 row vector containing
%   resolution in the X, Y and Z direction (in that order).
%
%
%   Example
%     % generate a demo image
%     img = discreteBall(1:10, 1:100, 1:100, [50.12 50.23 50.34 40]);
%     % convert to image with two different labels
%     img2 = uint8(img + 1);
%     % compute joint surface area
%     imJointSurface(img2, 1, 2)
%     ans = 
%         2.0102e+004
%
%   See also
%     imSurface
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


% check image dimension and type
if ndims(img) ~= 3 || islogical(img)
    error('first argument should be a 3D image');
end


%% Process input arguments

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
vol = d1 * d2 * d3;


%% Main processing for 3 directions

% number of transitions along the 3 main directions
n1a = sum(sum(sum(img(:,1:end-1,:)==L1 & img(:,2:end,:)==L2)));
n1b = sum(sum(sum(img(:,1:end-1,:)==L2 & img(:,2:end,:)==L1)));
n2a = sum(sum(sum(img(1:end-1,:,:)==L1 & img(2:end,:,:)==L2)));
n2b = sum(sum(sum(img(1:end-1,:,:)==L2 & img(2:end,:,:)==L1)));
n3a = sum(sum(sum(img(:,:,1:end-1)==L1 & img(:,:,2:end)==L2)));
n3b = sum(sum(sum(img(:,:,1:end-1)==L2 & img(:,:,2:end)==L1)));

if ndir == 3
    % compute surface area by averaging over the 3 main directions
    surf = 4/3 * ((n1a+n1b)/d1 + (n2a+n2b)/d2 + (n3a+n3b)/d3) / 2 * vol;
    return;
end


%% Additional processing for 13 directions

% Number of connected components along diagonals contained in the three
% main planes
n4a = sum(sum(sum(img(2:end,1:end-1,:)==L1   & img(1:end-1,2:end,:)==L2)));
n4b = sum(sum(sum(img(2:end,1:end-1,:)==L2   & img(1:end-1,2:end,:)==L1)));
n5a = sum(sum(sum(img(1:end-1,1:end-1,:)==L1 & img(2:end,2:end,:)==L2)));
n5b = sum(sum(sum(img(1:end-1,1:end-1,:)==L2 & img(2:end,2:end,:)==L1)));
n6a = sum(sum(sum(img(:,2:end,1:end-1)==L1   & img(:,1:end-1,2:end)==L2)));
n6b = sum(sum(sum(img(:,2:end,1:end-1)==L2   & img(:,1:end-1,2:end)==L1)));
n7a = sum(sum(sum(img(:,1:end-1,1:end-1)==L1 & img(:,2:end,2:end)==L2)));
n7b = sum(sum(sum(img(:,1:end-1,1:end-1)==L2 & img(:,2:end,2:end)==L1)));
n8a = sum(sum(sum(img(2:end,:,1:end-1)==L1   & img(1:end-1,:,2:end)==L2)));
n8b = sum(sum(sum(img(2:end,:,1:end-1)==L2   & img(1:end-1,:,2:end)==L1)));
n9a = sum(sum(sum(img(1:end-1,:,1:end-1)==L1 & img(2:end,:,2:end)==L2)));
n9b = sum(sum(sum(img(1:end-1,:,1:end-1)==L2 & img(2:end,:,2:end)==L1)));

%TODO: add the case of 9 directions ?

% Number of connected components along lines corresponding to diagonals of
% the unit cube
n10a = sum(sum(sum(img(1:end-1,1:end-1,1:end-1)==L1 & img(2:end,2:end,2:end)==L2)));
n10b = sum(sum(sum(img(1:end-1,1:end-1,1:end-1)==L2 & img(2:end,2:end,2:end)==L1)));
n11a = sum(sum(sum(img(2:end,1:end-1,1:end-1)==L1 & img(1:end-1,2:end,2:end)==L2)));
n11b = sum(sum(sum(img(2:end,1:end-1,1:end-1)==L2 & img(1:end-1,2:end,2:end)==L1)));
n12a = sum(sum(sum(img(1:end-1,2:end,1:end-1)==L1 & img(2:end,1:end-1,2:end)==L2)));
n12b = sum(sum(sum(img(1:end-1,2:end,1:end-1)==L2 & img(2:end,1:end-1,2:end)==L1)));
n13a = sum(sum(sum(img(2:end,2:end,1:end-1)==L1 & img(1:end-1,1:end-1,2:end)==L2)));
n13b = sum(sum(sum(img(2:end,2:end,1:end-1)==L2 & img(1:end-1,1:end-1,2:end)==L1)));

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
    (n1a+n1b)*c(1)/d1 + (n2a+n2b)*c(2)/d2 + (n3a+n3b)*c(3)/d3 + ...
    (n4a+n4b+n5a+n5b)*c(4)/d12 + (n6a+n6b+n7a+n7b)*c(6)/d13 + ...
    (n8a+n8b+n9a+n9b)*c(8)/d23 + ...
    (n10a + n10b + n11a + n11b + n12a + n12b + n13a + n13b) * c(10) / d123) / 2;


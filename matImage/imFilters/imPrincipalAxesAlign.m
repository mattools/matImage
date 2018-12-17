function res = imPrincipalAxesAlign(img, varargin)
%IMPRINCIPALAXESALIGN Aligns image along principal axes of inertia matrix
%
%   RES = imPrincipalAxesAlign(IMG)
%   RES = imPrincipalAxesAlign(DIM2, IMG)
%   RES = imPrincipalAxesAlign(LX, LY, LZ, IMG)
%
%   (Note: currently only implemented for 3D images)
%
%   Example
%     elli = [50.12 50.23 50.34  30 20 10   30 20 10];
%     img = discreteEllipsoid(1:100, 1:100, 1:100, elli);
%     img2 = imPrincipalAxesAlign(img);
%
%   See also
%     imInertiaEllipsoid
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-12-17,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.

%% Default parameters

% x-axis calibration
% if empty -> lx ly an lz were not initialized
lx = [];

spacing = [1 1 1];

% interpolation method
method = 'linear';


%% Parse inputs

% check if first input contains axes basis
if min(size(img)) == 1
    if size(img, 2) == 3 && nargin >= 2
        % the final size of the image is specified
        lx = (1:img(1)) - img(1)/2;
        ly = (1:img(2)) - img(2)/2;
        lz = (1:img(3)) - img(3)/2;
        img = varargin{1};
        varargin(1) = [];
        
    elseif nargin >= 4
        % the three first arguments contains lx, ly and lz
        lx = img;
        ly = varargin{1};
        lz = varargin{2};
        img = varargin{3};
        varargin(1:3) = [];
        
    else
        error('Unable to define size of resulting image');
    end
end

dim = size(img);

% check image data type
binary = islogical(img);
if ~binary
    error('Requires a binary image as input');
end

% eventually parse interpolation method
if ~isempty(varargin)
    method = varargin{1};
end


%% Computation of Principal axes

% extract points of the current particle
inds = find(img > 0);
[y, x, z] = ind2sub(dim, inds);

% compute approximate location of ellipsoid center
xc = mean(x);
yc = mean(y);
zc = mean(z);

center = [xc yc zc] .* spacing;

% recenter points (should be better for numerical accuracy)
x = (x - xc) * spacing(1);
y = (y - yc) * spacing(2);
z = (z - zc) * spacing(3);

points = [x y z];

% compute the covariance matrix
covPts = cov(points, 1) + diag(1/12 * ones(1, 3));

% perform a principal component analysis with 3 variables,
% to extract inertia axes
[U, S] = svd(covPts); %#ok<ASGLU>


%% Format the transform matrix

% create rotation matrix
rot = [U zeros(3, 1); 0 0 0 1];

% combine with translation
tra = createTranslation3d(center);
trans = tra * rot;


%% Resample original image

% create default grid parameters for resampling
if isempty(lx)
    lx = (1:dim(2)) - dim(2)/2;
    ly = (1:dim(1)) - dim(1)/2;
    lz = (1:dim(3)) - dim(3)/2;
end

% create sampling grid
[x, y, z] = meshgrid(lx, ly, lz);

% transform the sampling grid to correspond to main axes of inertia matrix
[x2, y2, z2] = transformPoint3d(x, y, z, trans);

% create resulting image by interpolation
res = imEvaluate(img, x2, y2, z2, method) > 0.5;

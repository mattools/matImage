function res = imPrincipalAxesAlign(img, varargin)
%IMPRINCIPALAXESALIGN Aligns image along principal axes of inertia matrix
%
%   RES = imPrincipalAxesAlign(IMG)
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

spacing = [1 1 1];

dim = size(img);
binary = islogical(img);
if ~binary
    error('Requires a binary image as input');
end
    

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

% create rotation matrix
rot = [U zeros(3, 1); 0 0 0 1];

% combine with translation
tra = createTranslation3d(center);
trans = tra * rot;

% create sampling grid
lx = -50:50;
[x, y, z] = meshgrid(lx, lx, lx);

% transform the sampling grid to correspond to main axes of inertia matrix
[x2, y2, z2] = transformPoint3d(x, y, z, trans);

% create resulting image by interpolation
res = imEvaluate(img, x2, y2, z2, 'linear') > 0.5;

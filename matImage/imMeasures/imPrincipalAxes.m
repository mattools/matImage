function [center, rotMat] = imPrincipalAxes(img, varargin)
% Computes principal axes of a 2D/3D binary image.
%
%   [CENTER, ROTMAT] = imPrincipalAxes(IMG)
%
%   (Note: currently only implemented for binary images)
%
%   Example
%     % Compute principal axes of a discretized 3D ellipsoid
%     % (requires the MatGeom toolbox)
%     elli = [50.12 50.23 50.34  30 20 10   30 20 10];
%     img = discreteEllipsoid(1:100, 1:100, 1:100, elli);
%     [center, rotMat] = imPrincipalAxes(img);
%     center
%     center =
%        51.1209   51.2245   51.3454
%     rotation3dToEulerAngles(rotMat)
%     ans =
%        30.0107   19.9733   10.0252
%
%
%   See also
%     imEquivalentEllipse, imEquivalentEllipsoid, imMoment, principalAxes
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2019-08-09,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRAE - Cepia Software Platform.

%% Default parameters

spacing = [1 1 1];
origin = [1 1 1];


%% Parse inputs

dim = size(img);

% check image data type
binary = islogical(img);
if ~binary
    error('Requires a binary image as input');
end


%% Computation of Principal axes

if length(dim) == 2
    % extract points of the current particle
    inds = find(img > 0);
    [y, x] = ind2sub(dim, inds);
    
    % convert to user coordinates
    x = x * spacing(1) + origin(1);
    y = y * spacing(2) + origin(2);
    
    % compute approximate location of ellipsoid center
    xc = mean(x);
    yc = mean(y);
    center = [xc yc];
    
    % recenter points (should be better for numerical accuracy)
    x = (x - xc);
    y = (y - yc);
    points = [x y];

    % compute the covariance matrix
    covPts = cov(points, 1) + diag(spacing(1:2) / 12);


elseif length(dim) == 3
    % extract points of the current particle
    inds = find(img > 0);
    [y, x, z] = ind2sub(dim, inds);
    
    % convert to user coordinates
    x = x * spacing(1) + origin(1);
    y = y * spacing(2) + origin(2);
    z = z * spacing(3) + origin(3);
    
    % compute approximate location of ellipsoid center
    xc = mean(x);
    yc = mean(y);
    zc = mean(z);
    center = [xc yc zc];
    
    % recenter points (should be better for numerical accuracy)
    x = (x - xc);
    y = (y - yc);
    z = (z - zc);
    points = [x y z];
    
    % compute the covariance matrix
    covPts = cov(points, 1) +  diag(spacing(1:3) / 12);

else
    error('MatImage:imPrincipalAxes', ...
        'Dimension of input image must be either 2 or 3');
end

% perform a principal component analysis with 3 variables,
% to extract inertia axes
[U, S] = svd(covPts);

% sort axes from greater to lower
[S, ind] = sort(diag(S), 'descend'); %#ok<ASGLU>

% format U to ensure first axis points to positive x direction
U = U(ind, :);
if U(1,1) < 0
    U = -U;
    % keep matrix determinant positive
    U(:,3) = -U(:,3);
end
rotMat = U;


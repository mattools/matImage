function profile = surfaceProfile(img, varargin)
%SURFACEPROFILE compute surface density profile
%
%
%   usage :
%   PROF = surfaceProfile(IMG);
%   return an estimate of the surface density profile of the image,
%   computed by counting intersections with 3D lines, and using discretized
%   version of the Crofton formula.
%
%   PROF = surfaceProfile(IMG, DIR);
%   Specify the direction to operate. By default it is 2, corresponding to
%   x direction.
%
%   PROF = surfaceProfile(IMG, DIR, CONN);
%   Also specify connectivity. Can be either 6 or 26. Default is 6.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/08/2005
%

%   HISTORY


% default values for options 
dir = 2;

% process input variables

% control validity of input image
img = squeeze(img>0);
if ndims(img)~=3
    error('first argument should be a 3D array');
end

profile = zeros(size(img, dir), 1);



% size of image
dim = size(img);

N = dim(dir)-1;

% Compute limits of each subimage. Subimage i will be from xi(i) to xi(i+1)
x1 = [floor(1:dim(dir)/N:dim(dir)) dim(dir)];

% compute minkowski density for each subimage.
for i=1:N
    map = minkmap(img(:, x1(i):x1(i+1), :), 2);
    profile(i) = squeeze(mean(mean(map, 3), 1))';
end

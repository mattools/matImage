function profile = minkProfile(img, varargin)
%MINKPROFILE estimate minkowski densities along image
% 
%   usage :
%   profile = minkProfile(IMG, DIR)
%   IMG : base image
%   DIR : direction of study of gradient (default 2 : eqv to x).
%   result is an array [dim(img,dir) ndims(img)+1] containing minkowski
%   densities computed for each couple of images.
%
%
%   profile = minkProfile(IMG, DIR, N)
%   Eventually specify number of subimages to use.
%
%
%   See also :
%   minkowski, minkMean, minkShell
% 
%
%   TODO :
%   manage dimensions other than 3.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/03/2005.
%

%   HISTORY
%   24/03/2005 rewrite it, cause bugged, test, and rewrite doc


% direction of profile inside image
dir = 2;
if ~isempty(varargin)
    dir = varargin{1};
end

% siez of image
dim = size(img);
ndims = length(dim);

% compute number of subimages
N = dim(dir)-1;
if length(varargin)>1
    N = varargin{2};
end

% Compute limits of each subimage. Subimage i will be from xi(i) to xi(i+1)
x1 = [floor(1:dim(dir)/N:dim(dir)) dim(dir)];

% compute minkowski density for each subimage.
profile = zeros(N, ndims+1);
for i=1:N
    map = minkmap(img(:, x1(i):x1(i+1), :));
    profile(i, 1:ndims+1) = squeeze(mean(mean(map, 3), 1))';
    
    % Cette version est bcp plus lente :
    %
    %im = img(:, x1(i):x1(i+1), :);
    %profile(i, 1) = mean(mean(minkmap(im, 1)));
    %profile(i, 2) = mean(mean(minkmap(im, 2)));
    %profile(i, 3) = mean(mean(minkmap(im, 3)));
    %profile(i, 4) = mean(mean(minkmap(im, 4)));
end



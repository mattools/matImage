function ind = contributingVoxels(pos)
%CONTRIBUTINGVOXELS  find indices of voxels not on image border
%
%   usage :
%   IND = contributingVoxels(POS)
%   where POS is a number between 1 and 27 indicating position of tile with
%   respect to image borders
%   and IND is an array of indices, giving only voxels which are not
%   located on the border of image.
%

% get position wrt edges of image
% if pk==1 -> config is on lower bounds in direction k
% if pk==2 -> config is in the middle of the 2 bounds
% if pk==3 -> config is on greater bound in direction k
pz = floor((pos-1)/9)+1;
pos2 = pos-9*(pz-1);
py = floor((pos2-1)/3)+1;
px = pos2-3*(py-1);

% Flags are set to one for contributions which should be computed
% If configuration is on the edge of image, the contributions of some
% vertices are not computed
flags = ones(1,8);
if px==1; flags([1 3 5 7]) = 0; end
if px==3; flags([2 4 6 8]) = 0; end
if py==1; flags([1 2 5 6]) = 0; end
if py==3; flags([3 4 7 8]) = 0; end
if pz==1; flags([1 2 3 4]) = 0; end
if pz==3; flags([5 6 7 8]) = 0; end

% get indices of pixels whose contribution will be computed
ind = find(flags);

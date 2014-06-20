function varargout = showZSlice(img, sliceIndex)
%SHOWZSLICE Show XY slice of a 3D image
%
%   showZSlice(IMG, INDEX)
%   Display the given slice as a 3D planar image. INDEX is the slice index,
%   between 1 and stackSize(img, 3).
%
%   Example
%   % Display orthoslices of a humain head
%   img = analyze75read(analyze75info('brainMRI.hdr'));
%   figure(1); clf; hold on;
%   showZSlice(img, 13);
%   showXSlice(img, 60);
%   showYSlice(img, 80);
%   axis equal
%   xlabel('x'); ylabel('y'); zlabel('z');
%
%   See also
%   showXSlice, showYSlice, getSlice
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-30,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


%% Extract image info

dim = stackSize(img);

% compute voxel positions
lz = 1:dim(3);

% position vectors of voxel corners
vx = ((0:dim(1)) + .5);
vy = ((0:dim(2)) + .5);

% global parameters for surface display
params = {'facecolor', 'texturemap', 'edgecolor', 'none'};

% compute position of voxel vertices in 3D space
[xy_x xy_y] = meshgrid(vx, vy);
xy_z = ones(size(xy_x)) * lz(sliceIndex);

% extract slice in z direction
slice = stackSlice(img, 'z', sliceIndex);

% eventually converts to uint8, rescaling data between 0 and max value
if ~strcmp(class(slice), 'uint8')
    slice = double(slice);
    slice = uint8(slice * 255 / max(slice(:)));
end

% convert grayscale to rgb (needed by 'surface' function)
if length(size(slice)) == 2
    slice = repmat(slice, [1 1 3]);
end

% repeat slice three times to manage a color image
hs = surface(xy_x, xy_y, xy_z, slice, params{:});


%% process output arguments

if nargout > 0
    varargout = {hs};
end

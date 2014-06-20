function varargout = showXSlice(img, sliceIndex)
%SHOWXSLICE Show YZ slice of a 3D image
%
%   showXSlice(IMG, INDEX)
%   Display the given slice as a 3D planar image. INDEX is the slice index,
%   between 1 and stackSize(img, 1).
%
%   Example
%   % Display 3D orthoslices of a humain head
%   img = analyze75read(analyze75info('brainMRI.hdr'));
%   figure(1); clf; hold on;
%   showZSlice(img, 13);
%   showXSlice(img, 60);
%   showYSlice(img, 80);
%   axis equal
%   xlabel('x'); ylabel('y'); zlabel('z');
%
%   See also
%   showYSlice, showZSlice, getSlice
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
lx = 1:dim(1);

% position vectors of voxel corners
vy = ((0:dim(2)) + .5);
vz = ((0:dim(3)) + .5);

% global parameters for surface display
params = {'facecolor', 'texturemap', 'edgecolor', 'none'};

% compute position of voxel vertices in 3D space
[yz_y yz_z] = meshgrid(vy, vz);
yz_x = ones(size(yz_y)) * lx(sliceIndex);

% extract slice in x direction
slice = stackSlice(img, 'x', sliceIndex);

% eventually converts to uint8, rescaling data between 0 and max value
if ~strcmp(class(slice), 'uint8')
    slice = double(slice);
    slice = uint8(slice * 255 / max(slice(:)));
end

% convert grayscale to rgb (needed by 'surface' function)
if length(size(slice)) == 2
    slice = repmat(slice, [1 1 3]);
end

% display voxel values in appropriate reference space
hs = surface(yz_x, yz_y, yz_z, slice, params{:});


%% process output arguments

if nargout > 0
    varargout = {hs};
end

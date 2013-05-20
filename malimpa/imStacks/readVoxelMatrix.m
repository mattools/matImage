function img = readVoxelMatrix(fname, varargin)
%READVOXELMATRIX Read a 3D image in VoxelMatrix (.vm) format
%
%   IMG = readVoxelMatrix(FILENAME)
%   Reads the 3D image stored in a file in VoxelMatrix format.
%
%   IMG = readVoxelMatrix(FILENAME, TYPE)
%   Specified the datatype to read. By default, 'uint8'.
%
%   Example
%     IMG = readVoxelMatrix('densityMap.vm', 'single');
%     Slicer(IMG);
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-03-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


%% Default settings

% default is uint8
type = 'uint8';
if ~isempty(varargin)
    type = varargin{1};
end


%% Open file and read meta-data

% open file and read data
f = fopen(fname, 'r');
if f == -1
    error(['Unable to open file: ' fname]);
end

% read image dimension, and transform to row vector
dim = fread(f, 3, 'int32');
dim = dim(:)';

% if size is zero, this is a voxel matrix file in the new format
version = 0;
if sum(dim) <= 0
    disp('reading new voxel matrix format');
    
    version = fread(f, 1, 'int32'); %#ok<NASGU>
    typeIndex = fread(f, 1, 'int32');
    switch typeIndex
        case 1
            type = 'int32';
        case {2, 5}
            type = 'single';
        otherwise
            error('Unkown type index: ' + typeIndex');
    end
    dim = fread(f, 3, 'int32');
    dim = dim(:)';  
    
    unitValue = fread(f, 1, 'int32'); %#ok<NASGU>
    resol = fread(f, 3, 'int32');
    resol = resol(:)'; %#ok<NASGU>
end


%% Read image data

% pre-allocate memory
if version == 0
    img = zeros(dim([2 1 3]), type);
else
    img = zeros(dim, type);
end

% add a star before to have same output type as read type
if type(1) ~= '*'
    type = ['*' type];
end

% read image data
img(:) = fread(f, prod(dim), type);

% close file
fclose(f);

if version > 0
    img = permute(img, [2 1 3]);
end


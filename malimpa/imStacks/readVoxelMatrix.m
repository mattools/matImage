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


% default is uint8
type = 'uint8';
if ~isempty(varargin)
    type = varargin{1};
end

% open file and read data
f = fopen(fname, 'r');

% read image dimension, and transform to row vector
dim = fread(f, 3, 'int32');
dim = dim(:)';

% pre-allocate memory
img = zeros(dim([2 1 3]), type);

% add a star before to have same output type as read type
if type(1) ~= '*'
    type = ['*' type];
end

% read image data
img(:) = fread(f, prod(dim), type);

% close file
fclose(f);


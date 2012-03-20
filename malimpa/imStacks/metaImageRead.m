function [img info] = metaImageRead(info, varargin)
%METAIMAGEREAD Read an image in MetaImage format
%
%   IMG = metaImageRead(INFO)
%   Read the image IMG from data given in structure INFO. INFO is typically
%   returned by the metaImageInfo function.
%
%   IMG = metaImageRead(FILENAME)
%   Read the image from a filename. Filename is a text file in metaimage
%   format.
%
%   IMG = metaImageRead(..., PARAM, VALUE)
%   Specify additional parameters for reading. The parameter can
%   complement, or override the parameters given in info file or structure.
%   See the function metaImageInfo for information about supported
%   parameters.
%
%   [IMG INFO] = metaImageRead(...)
%   Also returns the corresponding info structure associated to image IMG.
%
%   
%   Example
%   % first load info, then load data
%   info = metaImageInfo('example.mhd');
%   X = metaImageRead(info);
%
%   % specify only the filename, and specify endianness
%   IMG = metaImageRead('filename.mhd', 'ElementByteOrderMSB', false);
%
%   See also
%   metaImageInfo, readstack, analyze75info
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-27,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


%% Get info structure

% default empty value to avoid errors when user cancels
img = [];

% If the function is called without argument, open a dialog to read a file
if nargin == 0
    [filename, pathname] = uigetfile(...
        {'*.mha;*.mhd', 'Meta-Image data file (*.mha, *.mhd)'}, ...
        'Open Meta-Image data file');
    
    info = [pathname filename];
    if filename == 0
        return;
    end
end

% info should be a structure. If not, assume this is name of info file
if ischar(info)
    % read info strucure from file name
    info = metaImageInfo(info, varargin{:});
end
if ~isstruct(info)
    error('First argument must be a metaimage info structure');
end


%% Pre-compute variables

% determines pixel type
[pixelType isArrayType] = parseMetaType(info.ElementType);

% determines number of channels
nChannels = 1;
if isfield(info, 'ElementNumberOfChannels');
    nChannels = info.ElementNumberOfChannels;
end
if nChannels > 1
    isArrayType = true;
end

% % in the case of array type, need number of channels
% nChannels = 1;
% if isArrayType
%     nChannels = info.ElementNumberOfChannels;
% end

% compute size of resulting array
% (in the case of multi-channel image, use dim=3 for channel dimension).
dims = info.DimSize;
if isArrayType
    dims = [nChannels dims];
end

% allocate memory for data
img = zeros(dims, pixelType);

% Specify little- or big-endian ordering
byteOrder = determineByteOrder(info);


%% Read data file(s)

if ischar(info.ElementDataFile)
    % open data file
    f = fopen(info.ElementDataFile, 'rb');
    if f == -1
        error(['Unable to open data file: ' info.ElementDataFile]);
    end

    % skip header (defined as number of bytes)
    fread(f, info.HeaderSize, 'uint8');

    % read binary data
    img(:) = fread(f, prod(dims), ['*' pixelType], byteOrder);

    % close file
    fclose(f);


    % convert order of elements
    if isArrayType
        % for color images, replace channel dim at third position
        img = permute(img, [3 2 1 4:length(dims)]);
    else
        % permute dims 1 and 2
        img = permute(img, [2 1 3:length(dims)]);
    end

elseif iscell(info.ElementDataFile)
    % filename is given as a cell array containing name of each file
    
    % check dimension are consistent
    if length(info.ElementDataFile) ~= info.DimSize(3)
        error('Number of files does not match image third dimension');
    end
    
    % iterate over the elements in ElementDataFile, extract filename,
    % read image and add corresponding data to the img array.    
    for i = 1:length(info.ElementDataFile)
        filename = info.ElementDataFile{i};
        data = imread(filename);
        
        % use different processing for grayscale and color images
        if isArrayType
            img(:,:,:,i) = data;
        else
            img(:,:,i) = data;
        end
    end
    
else
    error('Unknown type of filename');
end

function [type isArray] = parseMetaType(string)

% % determines if the data type is an array or a scalar
% isArray = false;
% ind = findstr(string, '_ARRAY');
% if ~isempty(ind)
%     isArray = true;
%     string = string(1:ind-1);
% end
isArray = false;

% determines the base data type
switch string
    case 'MET_UCHAR'
        type = 'uint8';
    case 'MET_CHAR'
        type = 'int8';
    case 'MET_USHORT'
        type = 'uint16';
    case 'MET_SHORT'
        type = 'int16';
    case 'MET_UINT'
        type = 'uint32';
    case 'MET_INT'
        type = 'int32';
    case 'MET_FLOAT'
        type = 'single';
    case 'MET_DOUBLE'
        type = 'double';
    otherwise
        error('Unknown element type in metaimage header: %s', string);
end

function byteOrder = determineByteOrder(info)
% Return a character that can be used by fread function

% default byte order given by system
byteOrder = 'n';

% first check the ElementByteOrderMSB field
if isfield(info, 'ElementByteOrderMSB')
    if info.ElementByteOrderMSB
        byteOrder = 'b';
    else
        byteOrder = 'l';
    end
end

% also check the BinaryDataByteOrderMSB field
if isfield(info, 'BinaryDataByteOrderMSB')
    if info.BinaryDataByteOrderMSB
        byteOrder = 'b';
    else
        byteOrder = 'l';
    end
end

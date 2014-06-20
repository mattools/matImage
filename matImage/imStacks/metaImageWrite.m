function metaImageWrite(img, fileName, varargin)
%METAIMAGEWRITE Write header and data files of an image in MetaImage format
%   
%   metaImageWrite(IMG, FILENAME);
%   IMG is a matlab array, and FILENAME is the generic name (without
%   extension) of the metaimage file.
%   The functions tries to determine which parameters are appropriate for
%   the given image.
%
%   metaImageWrite(IMG, FILENAME, INFO);
%   Gives an additional structure as argument, containing additional
%   properties.
%
%   metaImageWrite(..., PARAM, VALUE);
%   Specifies additional properties as parameter key and value pairs. Case
%   is relevant. See http://www.itk.org/Wiki/MetaIO/Documentation for
%   details.
%
%   Example
%   [x y z] = meshgrid(1:80, 1:80, 1:80);
%   img = ((x-40).^2 + (y-40).^2 + (z-40).^2)<1000;
%   img = uint8(img*255);
%   metaImageWrite(img, 'ball');
%   metaImageWrite(img, 'ball.mhd');    % works also, same result
%   metaImageWrite(img, 'ball', 'ElementType', 'MET_USHORT', ...
%       'ElementByteOrderMSB', 'True')
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-02-03,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


%% Initialisations

% extract meta-information
info = struct;
if ~isempty(varargin)
    var = varargin{1};
    if isstruct(var)
        info = var;
        varargin(1) = [];
    end
end

% permute image dimension to use x as first index
img = permute(img, [2 1 3:ndims(img)]);

% extract image dimension
dims = size(img);

% check if image is color
isColor = false;
if length(dims) > 2 && dims(3) == 3
    isColor = true;
    dims = dims([1 2 4:end]);
end
    
nd = length(dims);


%% Process file names

% ensure the filename has no '.mhd' extension
if length(fileName) > 4
    if strcmp(fileName(end-3:end), '.mhd')
        fileName(end-3:end) = [];
    end
end

% split filename and diectory
[path, name] = fileparts(fileName);

% header and binary file names
headerFileName = [name '.mhd'];
binaryFileName = [name '.raw'];


%% Create file info structure

% check main information are present
if ~isfield(info, 'ObjectType')
    info.ObjectType = 'Image';
end
if ~isfield(info, 'NDims')
    info.NDims = nd;
end
if ~isfield(info, 'DimSize')
    info.DimSize = dims;
end
if ~isfield(info, 'ElementType')
    info.ElementType = metaTypeToString(class(img)); 
end
if ~isfield(info, 'ElementDataFile')
    info.ElementDataFile = binaryFileName;
end

if isColor
    info.ElementNumberOfChannels = 3;
end

% add additional varargins
while length(varargin) > 1
    key = varargin{1};
    if ~ischar(key)
        error('following parameter must be a string: %s', key);
    end
    
    info.(key) = varargin{2};
    varargin(1:2) = [];
end

% ensure MSB info is written for data other than 8-bits
elementByteOrderDefined = isfield(info, 'ElementByteOrderMSB');
binaryDataByteOrderDefined = isfield(info, 'BinaryDataByteOrderMSB');
if ~ischar(img) && ~(elementByteOrderDefined || binaryDataByteOrderDefined)
    info.BinaryData = true;
    if ispc
        info.ElementByteOrderMSB = false;
    else
        info.ElementByteOrderMSB = true;
    end
end

% open file
f = fopen(fullfile(path, headerFileName), 'wt');


%% write minimal information tags

fprintf(f, '%s = %s\n', 'ObjectType', 'Image');
fprintf(f, '%s = %d\n', 'NDims', info.NDims);
fprintf(f, '%s =%s\n', 'DimSize', ...
    sprintf(repmat(' %d', 1, info.NDims), info.DimSize));
fprintf(f, '%s = %s\n', 'ElementType', info.ElementType);


%% write each additional tag

names = fieldnames(info);
for i = 1:length(names)
    name = names{i};
    
    % some tags are either in the very beginning or at the end, so they are
    % not processed in the loop
    if ismember(name, {'ObjectType', 'NDims', 'DimSize', 'ElementType', ...
            'ElementDataFile'})
        continue;
    end

    fprintf(f, '%s = %s\n', name, convertToString(info.(name)));
end


%% write binary data info into header

fprintf(f, '%s = %s\n', 'ElementDataFile', binaryFileName);

fclose(f);


%% Write binary data

% Specify little- or big-endian ordering
byteOrder = determineByteOrder(info);

% extract data precision
precision = parseMetaType(info.ElementType);

% open file for binary writing
f = fopen(fullfile(path, binaryFileName), 'wb');

% write image data in correct order
if ~isColor
    % write grayscale data
    fwrite(f, img(:), precision, 0, byteOrder);
else
    % first permute data to write RGB of each element, then x, y, and z
    data = permute(img, [3 1 2 4:ndims(img)]);
    fwrite(f, data(:), precision, 0, byteOrder);
end

% close binary file
fclose(f);


function type = parseMetaType(string)

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
        error('unknown element type in metaimage header: %s', string);
end


function string = metaTypeToString(type)
% convert a matlab class name to MetaImage Type string

switch type
    case 'int8'
        string = 'MET_CHAR';
    case 'uint8'
        string = 'MET_UCHAR';
    case 'int16'
        string = 'MET_SHORT';
    case 'uint16'
        string = 'MET_USHORT';
    case 'int32'
        string = 'MET_INT';
    case 'uint32'
        string = 'MET_UINT';
    case 'single'
        string = 'MET_FLOAT';
    case 'double'
        string = 'MET_DOUBLE';
    otherwise
        error('unknown pixel type: %s', type);
end

function string = convertToString(data)

N = length(data(:));

if ischar(data)
    string = data;
    
elseif islogical(data)
    strings = {'false', 'true'};
    pattern = ['%s' repmat(' %s', 1, N-1)];
    string = sprintf(pattern, strings{data(:)+1});
    
elseif isinteger(data)
    pattern = ['%d' repmat(' %d', 1, N-1)];
    string = sprintf(pattern, data(:));
    
elseif isfloat(data)
    pattern = ['%g' repmat(' %g', 1, N-1)];
    string = sprintf(pattern, data(:));
    
else
    error('Unknwon type of data');
end


function byteOrder = determineByteOrder(info)
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


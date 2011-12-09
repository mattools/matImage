function info = metaImageInfo(fileName, varargin)
%METAIMAGEINFO Read information header of meta image data
%
%   INFO = metaImageInfo(FILENAME)
%   Read and decodes the information stored in metaimage header file.
%
%   Metaimage header files are text files containing parameters name/value
%   pairs in each line. 
%   Example of header file:
%     ObjectType = Image
%     NDims = 3
%     DimSize = 256 256 64
%     ElementType = MET_USHORT
%     HeaderSize = -1
%     ElementSize = 1 1 3
%     ElementSpacing = 1 1 1
%     ElementByteOrderMSB = False
%     ElementDataFile = image.raw
%
%   For information about MetaImage Header format, see:
%   http://www.itk.org/Wiki/MetaIO/Documentation#Quick_Start
%
%   Currently supported tags are:
%     NDims: number of dimensions
%     DimSize 
%     ElementType
%     ElementDataFile
%     HeaderSize
%     ElementSpacing
%     ElementByteOrderMSB
%     ElementNumberOfChannels
%     BinaryData
%     BinaryDataByteOrderMSB
%     CompressedData
%     CompressedDataSize 
%     AnatomicalOrientation
%     CenterOfRotation
%     Offset
%     TransformMatrix
%     ElementDataFile (should be the last tag in the file)
%
%
%   The values supported for 'ElementDataFile' are:
%   * the name of a single data file. Example: 'dataFile.raw'
%   * the keyword 'LIST', followed by the list of file names, one name by
%       line. Example:
%       ElementDataFile = LIST
%       slice-00.tif
%       slice-01.tif
%       slice-02.tif
%       ...
%   * a filename pattern, followed by three values corresponding to index
%       of the first slice, index of the last slice, and step between two
%       consecutive slices. Example: 'slice-%03d.tif 1 50 2'
%   * the 'LOCAL' keyword is not (yet...) supported.
%
%
%   Example
%      info = metaImageInfo('example.hdr');
%      X = metaImageRead(info);
%
%
%   See also
%   metaImageRead, readstack, analyze75info
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-27,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2011-08-17 code cleanup, better initialization of spacing


%% Open info file

% If the function is called without argument, open a dialog to read a file
if nargin == 0
    [filename, pathname] = uigetfile(...
        {'*.mha;*.mhd', 'Meta-Image info file (*.mha, *.mhd)'}, ...
        'Open Meta-Image info file');
    
    info = [pathname filename];
    if filename == 0
        return;
    end
end

% add file extension if not present
ext = [];
if length(fileName) > 3
    ext = fileName(end-3:end);
end
if ~strcmp(ext, '.mhd')
    fileName = [fileName '.mhd'];
end

% get base directory
path = fileparts(fileName);

% open the file for reading
f = fopen(fileName, 'rt');
if f == -1
    error(['Could not find the file: ' fileName]);
end


%% Initialisations

% extract key and value of current line
[tag string] = splitLine(fgetl(f));

% check header file contains an image
if ~strcmp(tag, 'ObjectType') || ~strcmp(string, 'Image')
    error('File should contain image data');
end

% default values
info.ObjectType = 'Image';
info.NDims = 0;
info.DimSize = [];
info.ElementType = 'uint8';
info.ElementDataFile = '';

% setup default values for spatial calibration
info.ElementSpacing = [];
info.ElementSize = [];

% default optional values
info.HeaderSize = 0;


%% Loop over lines in the file

while true
    % read current line, if exists
    line = fgetl(f);
    if line == -1
        break
    end

    % extract key and value of current line
    [tag string] = splitLine(line);
    
    % extract each possible tag
    switch tag
        % First, parse required tags
        case 'NDims'
            % number of dimensions. Used for initializing data structure
            nd = parseInteger(string);
            info.NDims = nd;
            
        case 'DimSize'
            info.DimSize = parseIntegerVector(string);
            
        case 'ElementType'
            info.ElementType = string;
            
        case 'HeaderSize'
            info.HeaderSize = parseInteger(string);
            
        case 'ElementDataFile'
            info.ElementDataFile = computeDataFileName(string, f, path);
            % this tag is supposed to be the last one in the tag list
            break;
            
        % Following tags are optional, but often encountered
        
        case 'ElementSize'
            info.ElementSize = parseFloatVector(string);
            
        case 'ElementSpacing'
            info.ElementSpacing = parseFloatVector(string);
            
        case 'ElementByteOrderMSB'
            info.ElementByteOrderMSB = parseBoolean(string);
            
        case 'ElementNumberOfChannels'
            info.ElementNumberOfChannels = parseInteger(string);
            
        case 'BinaryData'
            info.BinaryData = parseBoolean(string);
            
        case 'BinaryDataByteOrderMSB'
            info.BinaryDataByteOrderMSB = parseBoolean(string);
            
        case 'CompressedData'
            info.CompressedData = parseBoolean(string);
            
        case 'CompressedDataSize'
            info.CompressedData = parseIntegerVector(string);
            
        % Some less common tags, used e.g. by Elastix
        
        case 'AnatomicalOrientation'
            info.AnatomicalOrientation = string;
            
        case 'CenterOfRotation'
            info.CenterOfRotation = parseFloatVector(string);
            
        case 'Offset'
            info.Offset = parseFloatVector(string);
            
        case 'TransformMatrix'
            info.TransformMatrix = parseFloatVector(string);
            
        % And unknown tags
        otherwise
            warning('MetaImageInfo:UnknownTag', ...
                ['Unknown tag in MetaImage header: ' tag]);
            info.(tag) = string;
    end
end

fclose(f);


%% Process optional input arguments

while length(varargin) > 1
    info.(varargin{1}) = varargin{2};
    varargin(1:2) = [];
end


%% Cleanup initialization
if isempty(info.ElementSize) || isempty(info.ElementSpacing)
    if ~isempty(info.ElementSize)
        % init spacing from size
        info.ElementSpacing = info.ElementSize;
        
    elseif ~isempty(info.ElementSpacing)
        % init size from spacing
        info.ElementSize = info.ElementSpacing;
        
    else
        % init both spacing and size from dimension
        siz = ones(1, info.NDims);
        info.ElementSize = siz;
        info.ElementSpacing = siz;
        
    end
end


function name = computeDataFileName(string, f, path)
% compute filename or file name list from pattern and current path

% remove eventual trailing spaces
string = strtrim(string);

if strcmpi(string, 'list')
    % read the list of file names and add the path
    tline = fgetl(f);
    name = {};
    i = 1;
    while ischar(tline)
        name{i} = fullfile(path, tline); %#ok<AGROW>
        i = i + 1;
        tline = fgetl(f);
    end
    
elseif ~isempty(strfind(string, ' '))
    % If filename contains spaces, it is parsed to extract indices
    C = textscan(string, '%s %d %d %d');
    pattern = C{1}{1};
    i0 = C{2};
    iend = C{3};
    istep = C{4};
    
    inds = i0:istep:iend;
    
    name = cell(length(inds), 1);
    
    for i=1:length(inds)
        name{i} = fullfile(path, sprintf(pattern, inds(i)));
    end
    
else
    % Simply use the string as the name of the file
    name = fullfile(path, string);
end


function [tag string] = splitLine(line)
[tag remain] = strtok(line, '=');
tag = strtrim(tag);
string = strtrim(strtok(remain, '='));

function b = parseBoolean(string)
b = strcmpi(string, 'true');

function v = parseInteger(string)
v = sscanf(string, '%d');

function v = parseIntegerVector(string)
v = sscanf(string, '%d', inf)';

function v = parseFloatVector(string)
v = sscanf(string, '%f', inf)';


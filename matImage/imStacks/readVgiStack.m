function [img, info] = readVgiStack(fileName, varargin)
%READVGISTACK Read a 3D stack stored in VGI format
%
%   output = readVgiStack(input)
%
%   Example
%   readVgiStack
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-10-18,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.

%% Initialisations

% Initialize empty stucture 
info.sizeX = 0;
info.sizeY = 0;
info.sizeZ = 0;
info.bitDepth = 0;
info.littleEndian = true;
info.dataFileName = '';
info.spacing = [];
info.unit = '';

% parse optional input arguments
verbose = false;
while length(varargin) >= 2
    name = varargin{1};
    if strcmp(name, 'verbose')
        verbose = varargin{2};
    end
    varargin(1:2) = [];
end


%% Read File info

f = fopen(fileName, 'rt');
if f == -1
    error(['Could not find the file: ' fileName]);
end

% iterate over text lines
lineIndex = 0;
while true
    % read next line
    line = fgetl(f);
    lineIndex = lineIndex + 1;
    
    % end of file
    if line == -1
        break;
    end
    line = strtrim(line);
    
    if startsWith(line, '{') && endsWith(line, '}')
        % start a new volume

    elseif startsWith(line, '[') && endsWith(line, ']')
        % start a new information block
        
    else 
        % process new key-value pair
        [key, value] = strtok(line, '=');
        if isempty(value)
            error('Token count error at line %d: %s', lineIndex, line);
        end
        
        % extract key and value for the current line
        key = strtrim(key);
        value = strtrim(value(2:end));
        
        % switch process depending on key
        if strcmpi(key, 'size')
            % process volume dimension
            tokens = strsplit(value, ' ');
            info.sizeX = str2double(tokens{1});
            info.sizeY = str2double(tokens{2});
            info.sizeZ = str2double(tokens{3});
            
        elseif strcmpi(key, 'bitsperelement')
            info.bitDepth = str2double(value);
            if info.bitDepth ~= 16
                error('Only 16 bits per element are currently supported, not %d', bitDepth);
            end
            
        elseif strcmp(key, 'Name')
            info.dataFileName = value;
            
        elseif strcmpi(key, 'resolution')
            tokens = strsplit(value, ' ');
            if length(tokens) ~= 3
                error('Could not parse spatial resolution from line: %d', line);
            end
            info.spacing(1) = str2num(tokens{1}); %#ok<ST2NM>
            info.spacing(2) = str2num(tokens{2}); %#ok<ST2NM>
            info.spacing(3) = str2num(tokens{3}); %#ok<ST2NM>
            
        elseif strcmpi(key, 'unit')
            info.unit = value;
            
        end
    end
end

% close the file containing information
fclose(f);

%% Read binary data

% read file in same directory as information file.
[baseDir, tmp] = fileparts(fileName); %#ok<ASGLU>
[tmp, fileName, ext] = fileparts(info.dataFileName); %#ok<ASGLU>
filePath = fullfile(baseDir, [fileName ext]);
info.dataFileName = filePath;

% open for for binary reading
f = fopen(filePath, 'rb');
if f == -1
    error(['Unable to open data file: ' info.dataFileName]);
end

% assume little endian is default
byteOrder = 'l';

% read binary data
if verbose
    disp('allocate memory');
end
dims = [info.sizeX info.sizeY info.sizeZ];
pixelType = 'uint16';
img = zeros(dims, pixelType);


if verbose
    disp('read data');
end
img(:) = fread(f, prod(dims), ['*' pixelType], byteOrder);

% close file
fclose(f);

% permute dims 1 and 2
if verbose
    disp('permute');
end
img = permute(img, [2 1 3:length(dims)]);


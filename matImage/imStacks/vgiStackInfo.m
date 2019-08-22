function info = vgiStackInfo(fileName, varargin)
%VGISTACKINFO Read information necessary to load a 3D stack in VGI format
%
%   INFO = vgiStackInfo(FILENAME)
%   INFO = vgiStackInfo(FILENAME, 'verbose', VERB)
%   Also specifies a verbosity level (default: 0).
%
%   Example
%   vgiStackInfo
%
%   See also
%   readVgiStack
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-10-24,    using Matlab 9.5.0.944444 (R2018b)
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
        if verbose > 1
            disp(['start a new volume: ' line(2:end-1)]);
        end

    elseif startsWith(line, '[') && endsWith(line, ']')
        % start a new information block
        if verbose > 1
            disp(['start a new information block: ' line(2:end-1)]);
        end
        
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
                error('Only 16 bits per element are currently supported, not %d', info.bitDepth);
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

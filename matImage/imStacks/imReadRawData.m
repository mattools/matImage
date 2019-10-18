function img = imReadRawData(fileName, varargin)
%IMREADRAWDATA Read image data from raw data file.
%
%   output = imReadRawData(FNMAE, OPTIONS)
%
%   Example
%   imReadRawData
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-10-18,    using Matlab 9.7.0.1190202 (R2019b)
% Copyright 2019 INRA - Cepia Software Platform.

% default parameter values
pixelType = 'uint16';
byteOrder = 'l'; % assume little endian is default
offset = 0;
verbose = false;

% parse input options
while length(varargin) > 1
    name = varargin{1};
    value = varargin{2};
    
    if strcmp(name, 'pixelType')
        pixelType = value;
    elseif strcmp(name, 'dims')
        dims = value;
    elseif strcmp(name, 'offset')
        offset = value;
    elseif strcmp(name, 'verbose')
        verbose = value;
    else
        error(['Unknown parameter name: ' name]);
    end
    
    varargin(1:2) = [];
end

%% Allocate

if verbose
    disp('allocate memory');
end
img = zeros(dims, pixelType);


%% Open

if verbose
    disp('open data file');
end

% open for for binary reading
f = fopen(fileName, 'rb');
if f == -1
    error(['Unable to open data file: ' fileName]);
end

% look for beginning of data
fseek(f, offset, 'bof');



%% Fill array

if verbose
    fprintf('read data...');
end
tic;
img(:) = fread(f, prod(dims), ['*' pixelType], byteOrder);
t = toc;
if verbose
    fprintf(' (%7.3f s)\n', t);
end

%% Cleanup

% close file
fclose(f);

% permute dims 1 and 2
if verbose
    disp('permute');
end
img = permute(img, [2 1 3:length(dims)]);


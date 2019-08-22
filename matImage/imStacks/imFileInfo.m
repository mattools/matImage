function info = imFileInfo(fileName)
%IMFILEINFO Generalization of the imfinfo function
%
%   INFO = imFileInfo(FILENAME)
%
%   Example
%     info = imFileInfo('brainMRI.hdr');
%
%   See also
%     imfinfo, analyze75info, metaImageInfo, vgiStackInfo
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-12-17,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.

% extract extension
[path, name, ext] = fileparts(fileName); %#ok<ASGLU>

% remove dot
ext(1) = [];

switch ext
    case {'tif', 'png', 'jpg', 'bmp'}
        info = imfinfo(fileName);
        
    case 'hdr'
        info = analyze75info(fileName);
        
    case {'mhd', 'mha'}
        info = metaImageInfo(fileName);

    case {'vgi'}
        info = vgiStackInfo(fileName);
        
    otherwise
        error(['Can not manage file ending by ' ext]);
end


function img = imReadRegion3d(fileName, rect)
%IMREADREGION3D Read a specific 3D region of a 3D image
%
%   img = imReadRegion3d(FNAME, RECT);
%
%   Inputs:
%   FNAME the name of the input file
%   RECT  a 6-element vector with the form [XMIN YMIN ZMIN DIMX DIMY DIMZ],
%         these values are specified in spatial coordinates. 
%
%   Example
%     img = imReadRegion3d('mri.tif', [20 30 1 60 50 27]);
%     size(img)
%     ans =
%         50    60    27
%
%   See also
%     readstack, imSize, imReadDownSampled3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-03-27,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.

[path, baseName, ext] = fileparts(fileName); %#ok<ASGLU>


% size of result image (matrix order)
dims = rect([5 4 6]);

if strcmpi(ext, '.tif') || strcmpi(ext, '.tiff') 

    % determine data type from file
    info = imfinfo(fileName);
    if info(1).BitDepth == 8
        dataType = 'uint8';
    elseif info(1).BitDepth == 16
        dataType = 'uint16';
    else
        error(['Unable to process tiff file with bitdepth: ' num2str(info(1).BitDepth)]);
    end
    
    % allocate memory for result
    img = zeros(dims, dataType);
    
    % compute indices of region extent in matrix coordinate system
    boundsI = [rect(2) rect(2)+rect(5)-1];
    boundsJ = [rect(1) rect(1)+rect(4)-1];
    
    for iz = 1:rect(6)
        % read current slice
        index = rect(3) + iz -1;
        img(:,:,iz) = imread(fileName, index, 'PixelRegion', {boundsI, boundsJ});
        
    end
    
    
else
    error(['Unable to manage file format: ' ext]);
end


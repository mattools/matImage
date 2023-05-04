function res = imReadDownSampled3d(fileName, ratio)
%IMREADDOWNSAMPLED3D Read a down-sampled version of a 3D image
%
%   img = imReadDownSampled3d(FNAME, K);
%
%   Inputs:
%   FNAME the name of the input file
%   K     the downsampling factor (as integer larger than 1)
%
%   Example
%     img = imReadDownSampled3d('mri.tif', 2);
%     size(img)
%     ans =
%         64    64    14
%
%     % use different down sampling ratio depending on dimension
%     img = imReadDownSampled3d('mri.tif', [3 2 1]);
%     size(img)
%     ans =
%         43    64    27
%
%   See also
%     readstack, imDownSample, imSize, imReadRegion3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-07-26,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.

[path, baseName, ext] = fileparts(fileName); %#ok<ASGLU>

if isscalar(ratio) 
    ratio = [ratio ratio ratio];
end

if strcmpi(ext, '.tif') || strcmpi(ext, '.tiff') 

    infos = imfinfo(fileName);
    dim = [infos(1).Height infos(1).Width length(infos)];

    dim2 = round(dim ./ ratio);
    img0 = imread(fileName, 1);

    res = zeros(dim2, 'like', img0);

    for i = 1:dim2(end)
        i2 = (i-1) * ratio(3) + 1;
        img = imread(fileName, i2);
        img = imresize(img, dim2(1:2));
        res(:,:,i) = img;
    end
    
else
    error(['Unable to manage file format: ' ext]);
end


function res = imTangentCrop3d(img, pos, boxSize, varargin)
% Crop an image around a point based on local orientation.
%
%   RES = imTangentCrop3d(IMG, BOXCENTER, BOXSIZE)
%   Computes and orientated crop of the input 3D image IMG, by considering
%   all voxels within a oriented box with centered given by BOXCENTER, size
%   given by BOXSIZE, and (3D) orientation evaluated from local gradient of
%   the image at the point POS.
%   
%
%   Example
%     % generate a discretized image of a ball
%     img = uint8(discreteBall([100 100 100], [50 50 50 40])) * 255;
%     % apply slight smoothing to avoid jagging effect
%     imgf = imGaussianFilter(img, [5 5 5], 1.5);
%     % resample image within a box oriented along image gradient
%     % Gradient direction in IMG corresponds to z direction of the result
%     pos = [78 78 50]; % on the boundary of the ball
%     boxSize = [50 50 50];
%     res = imTangentCrop3d(imgf, pos, boxSize);
%     Slicer(res);
%
%   See also
%     imTangentCrop, imCropOrientedBox, imCropBox, imLocalGradient
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2022-06-01,    using Matlab 9.9.0.1570001 (R2020b) Update 4
% Copyright 2022 INRAE.


%% Process input arguments

% parameter for computing local gradient
sigmaGradient = 2;

% optionnally add a rotation around the normal angle
rotZAngle = 0.0;

% parse additional user arguments
while length(varargin) > 1
    name = varargin{1};
    if ~ischar(name)
        error('additional arguments must be given with name-value pairs');
    end
    
    if strcmpi(name, 'sigmaGradient')
        sigmaGradient = varargin{2};
    elseif strcmpi(name, 'rotZAngle')
        rotZAngle = varargin{2};
    else
        error('Unknown parameter name: %s', name);
    end
    varargin(1:2) = [];
end


%% Compute 3D transform matrix

% evaluate gradient within image
grad = normalizeVector3d(imLocalGradient(img, pos, sigmaGradient));

% find a pair of vecors
basisVectors = [1 0 0 ; 0 1 0 ; 0 0 1];
crossProds = crossProduct3d(grad, basisVectors);
[~, ind] = max(vectorNorm3d(crossProds));

% identify two vectors orthogonal to the outwards normal
vt1 = crossProds(ind, :);
vt2 = crossProduct3d(grad, vt1);

% convert to rotation matrix
% (concatenate column vectors corresponding to eigen vectors)
rotMat = [vt1 0 ; vt2 0 ; grad 0 ; 0 0 0 1]';

% create the transform matrix that maps from box coords to global coords
transfo = createTranslation3d(pos) * rotMat * createRotationOz(rotZAngle);


%% Resample within box positions

% generate point coords along each box axis:
% * number of values equals to round(boxSize)
% * use single pixel spacing
radius = round(boxSize) / 2;
lx = -radius(1)+0.5:radius(1)-0.5;
ly = -radius(2)+0.5:radius(2)-0.5;
lz = -radius(3)+0.5:radius(3)-0.5;

% map into global coordinate space
[x, y, z] = meshgrid(lx, ly, lz);
[x, y, z] = transformPoint3d(x, y, z, transfo);

% evaluate within image
res = imEvaluate(img, x, y, z);

function res = imCropBorder(img, pad, varargin)
%IMCROPBORDER Crop the border around a 2D or 3D image
%
%   IMG = imCropBorder(IMG, BORDER)
%   Crop the image by removing BORDER pixels around the image. The size of
%   new image is given by size(IMG)-2*BORDER. 
%   The function works for 2D or 3D images, grayscale or color.
%
%   IMG = imCropBorder(IMG, [BORDER1 BORDER2])
%   IMG = imCropBorder(IMG, [BORDER1 BORDER2 BORDER3])
%   Specifies different sizes for borders in first and second directions
%   (and third direction for 3D images)
%
%   IMG = imCropBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21])
%   IMG = imCropBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21 BORDER30 BORDER31])
%   Specifies different sizes for borders in first and second directions,
%   and in the beginning and at the end in each direction.
%
%
%   Example
%   % Add 20 pixel in each side of rice image
%     img = imread('rice.png');
%     img2 = imAddBorder(img, 20);
%     imshow(img2);
%
%   % add white borders with different sizes
%     img = imread('rice.png');
%     img2 = imAddBorder(img, [10 20 30 40], 255);
%     imshow(img2);
%
%   % add cyan border around a color image
%     img = imread('peppers.png');
%     img2 = imAddBorder(img, [30 20], [0 1 1]);
%     imshow(img2);
%
%   See also
%     imCrop, imAddBorder
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-11-05,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

%   History

%% Initialisations

% size of input image
dim = size(img);
isColor = size(img, 3) == 3;
isPlanar = length(dim) == 2 || (length(dim) == 3 && isColor);

if isPlanar
    %% Planar case 
    
    % convert pad to have 4 values
    if length(pad) == 1
        pad = [pad pad pad pad];
    elseif length(pad)==2
        pad = [pad(1) pad(1) pad(2) pad(2)];
    end

    dim1 = (pad(1)+1):(size(img,1)-pad(2));
    dim2 = (pad(3)+1):(size(img,2)-pad(4));
    
    % fillup result image with initial image
    res = img(dim1, dim2, :);
    
elseif length(dim) - isColor == 3
    %% Case of 3D image
    
    % convert pad to have 6 values
    if length(pad) == 1
        pad = [pad pad pad pad pad pad];
    elseif length(pad) == 3
        pad = [pad(1) pad(1) pad(2) pad(2) pad(3) pad(3)];
    end

    % compute index of voxels to keep along each dimension
    dim1 = (pad(1)+1):(size(img,1)-pad(2));
    dim2 = (pad(3)+1):(size(img,2)-pad(4));
    dim3 = (pad(5)+1):(size(img,3+isColor)-pad(6));

    % select voxels to keep
    if isColor
        res = img(dim1, dim2, :, dim3);
    else
        res = img(dim1, dim2, dim3);
    end
    
else
    error('Image dimension not managed');
end
    

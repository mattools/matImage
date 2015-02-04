function res = imAddBorder(img, pad, varargin)
%IMADDBORDER  Add a border around a 2D or 3D image
%
%   IMG = imAddBorder(IMG, BORDER)
%   Adds BORDER pixels around the image. The size of new image is given by
%   size(IMG)+2*BORDER. 
%   The function works for 2D or 3D images, grayscale or color.
%
%   IMG = imAddBorder(IMG, [BORDER1 BORDER2])
%   IMG = imAddBorder(IMG, [BORDER1 BORDER2 BORDER3])
%   Specifies different borders for borders in first and second directions
%   (and third direction for 3D images)
%
%   IMG = imAddBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21])
%   IMG = imAddBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21 BORDER30 BORDER31])
%   Specifies different borders for borders in first and second directions,
%   and in the beginning and at the end in each direction.
%
%   IMG = imAddBorder(..., BACKGROUND)
%   specifies the value of the background color.
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
%   padarray (does nearly similar job)
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-08-24,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

%   History
%   2012.08.03 add support for color images

%% Initialisations

% extract background value
background = 0;
if ~isempty(varargin)
    background = varargin{1};
end    

% size of input image
dim = size(img);
isColor = size(img, 3) == 3;
isPlanar = length(dim) == 2 || (length(dim) == 3 && isColor);

% in case of color image, ensure background is in the same range as image
if max(background) <= 1 && max(img(:)) > 1
    background = background * 255;
end


if isPlanar
    %% Planar case 
    
    % convert pad to have 4 values
    if length(pad) == 1
        pad = [pad pad pad pad];
    elseif length(pad)==2
        pad = [pad(1) pad(1) pad(2) pad(2)];
    end

    % compute new dimension
    dim2 = dim;
    dim2(1:2) = dim2(1:2) + [sum(pad(1:2)) sum(pad(3:4))];

    % create result image
    if islogical(img)
        res = false(dim2);
    else
        res = ones(dim2, class(img)); %#ok<ZEROLIKE>
    end
    
    % fill result with background color
    if isColor && length(background) > 1
        for c = 1:3
            res(:,:,c) = background(c);
        end
    else
        res(:) = background;
    end
    
    % fillup result image with initial image
    res((1:size(img, 1))+pad(1), (1:size(img, 2))+pad(3), :) = img;
    
    
elseif length(dim) - isColor == 3
    %% Case of 3D image
    
    % convert pad to have 6 values
    if length(pad) == 1
        pad = [pad pad pad pad pad pad];
    elseif length(pad) == 3
        pad = [pad(1) pad(1) pad(2) pad(2) pad(3) pad(3)];
    end

    % compute new dimension
    if isColor
        dim2 = dim + [sum(pad(1:2)) sum(pad(3:4)) 0 sum(pad(5:6))];
    else
        dim2 = dim + [sum(pad(1:2)) sum(pad(3:4)) sum(pad(5:6))];
    end

    % create result image
    if islogical(img)
        res = false(dim2);
    else
        res = ones(dim2, class(img)); %#ok<ZEROLIKE>
    end
    
    % fill result with background color
    if isColor && length(background) > 1
        for c = 1:3
            res(:,:,c,:) = background(c);
        end
    else
        res(:) = background;
    end
    
    % fillup result image with initial image
    if isColor
        res((1:size(img, 1)) + pad(1),...
            (1:size(img, 2)) + pad(3), ...
            :, ...
            (1:size(img, 4)) + pad(5)) = img;
    else
        res((1:size(img, 1)) + pad(1),...
            (1:size(img, 2)) + pad(3), ...
            (1:size(img, 3)) + pad(5)) = img;
    end
    
else
    error('Image dimension not managed');
end
    

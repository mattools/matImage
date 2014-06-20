function res = imOverlay(img, varargin)
%IMOVERLAY Add colored markers to an image (2D or 3D, grayscale or color)
%
%   Usage
%   OVR = imOverlay(IMG, MASK);
%   OVR = imOverlay(IMG, MASK, COLOR);
%   OVR = imOverlay(IMG, MASK1, COLOR1, MASK2, COLOR2...);
%   OVR = imOverlay(IMG, RED, GREEN, BLUE);
%   
%   Description
%   OVR = imOverlay(IMG, MASK);
%   where IMG and MASK are 2 images the same size, returns the image BASE
%   with red markers given by MASK superposed on it.
%   IMG can be either color or gray-scale image, 2D or 3D (actually
%   Ny*Nx*3*Nz in the case of 3D color image)
%   MASK is a binary image with same size as IMG 
%   OVR is a color image, the same size as the original image
%
%   OVR = imOverlay(IMG, MASK, COLOR);
%   assumes that binary image MASK and image BASE have the same size,
%   replace all pixels of MASK by the color COLOR. The argument COLOR is
%   either a vector with 3 elements, or a character belonging to {'r', 'g',
%   'b', 'c', 'm', 'y', 'k', 'w'}.
%
%   This syntax can be repeated:
%   OVR = imOverlay(IMG, MASK1, COLOR1, MASK2, COLOR2, MASK3, COLOR3)
%
%   OVR = imOverlay(IMG, RED, GREEN, BLUE);
%   where RED, GREEN and BLUE are binary images the same size as IMG image,
%   puts 3 overlays of different colors on the base image.
%   It is possible to specify only one overlay by using empty data:
%   OVR = imOverlay(BASE, [], [], BLUE);
%
%
%   Example
%   %% Display two binary overlays on a grayscale image
%   % Read demo image and binarize it
%   img = imread('coins.png');
%   bin = imfill(img>100,'holes');
%   % compute disc boundary
%   circ = bin ~= imdilate(bin, [0 1 0;1 1 1;0 1 0]);
%   % compute inluence zone o feach disc
%   wat = watershed(bwdist(bin), 8);
%   % compute and display overlay as 3 separate bands
%   res = imOverlay(img, circ, [], wat==0);
%   figure; imshow(res);
%   % display result with different colors
%   res = imOverlay(img, circ, 'y', wat==0, [1 0 1]);
%   figure; imshow(res);
%
%   %% colorize a part of a grayscale image
%   % read input grayscale image
%   img = imread('cameraman.tif');
%   % create a colorized version of the grayscale image
%   yellow = cat(3, img, img, zeros(size(img), 'uint8'));
%   % compute binary a mask around the head of the cameraman
%   mask = false(size(img));
%   mask(20:120, 80:180) = true;
%   % compute and show the overlay
%   imshow(imOverlay(img, mask, yellow));
%
%   %% Compute overlay on a 3D image
%   metadata = analyze75info('brainMRI.hdr');
%   I = analyze75read(metadata);    % read 3D data
%   se = ones([3 3 3]);
%   bin = imclose(I>0, se);         % binarize, remove small holes
%   bnd = imerode(bin, se)~=bin;    % compute boundary
%   ovr = imOverlay(I*3, bnd);      % compute overlay
%   montage(ovr);                   % display each slice
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 11/12/2003.
% Copyright 2010 INRA - Cepia Software Platform.

% HISTORY
% 01-04-2004 add support for three color overlays, with possibility of
%   empty ones
% 10-06-2004 correct bug for 3D RGB images
% 25-06-2004 small bug for 3D color images
% 29-06-2004 add possibility to use binary images
% 15-11-2004 reduce memory used by program
% 08-08-2006 add support for floating point images
% 29-08-2007 major rewriting, add possibility to specify couples of mask
%   and colors
% 23-07-2009 update doc
% 06-01-2010 cleanup
% 19-07-2010 major rewriting, add tests


if length(varargin)==1
    % If only one input => this is the mask, the color is assumed to be red
    res = imOverlay(img, varargin{1}, [1 0 0]);
    return;

elseif length(varargin)==3
    % If three inputs are given, there are supposed to be the red, green
    % and blue mask, in that order, possibly empty
    res = img;
    if ~isempty(varargin{1})
        res = imOverlay(res, varargin{1}, [1 0 0]);
    end
    if ~isempty(varargin{2})
        res = imOverlay(res, varargin{2}, [0 1 0]);
    end
    if ~isempty(varargin{3})
        res = imOverlay(res, varargin{3}, [0 0 1]);
    end
    return;
end

    
% Ensure input image has uint8 type
img = im2uint8(img);


%% Initializations

% compute size and info flags
[dim isColor is3D] = computeImageInfo(img);


% initialize each band of the result image with the original image
if isColor
    red     = squeeze(img(:,:,1,:));
    green   = squeeze(img(:,:,2,:));
    blue    = squeeze(img(:,:,3,:));
else
    red     = img;
    green   = img;
    blue    = img;
end


%% Main processing

% Recursively process input arguments
% As long as we find inputs, mask is extracted and overlaid on result image
while ~isempty(varargin)
    % First argument is the mask, second argument specifies color
    mask    = varargin{1};
    [r g b]  = parseOverlayBands(varargin{2});
    
    varargin(1:2) = [];
    
    % type cast
    mask = uint8(mask);
        
    % update each band
    red     = red.*uint8(mask==0)   + mask.*r;
    green   = green.*uint8(mask==0) + mask.*g;
    blue    = blue.*uint8(mask==0)  + mask.*b;
end


% create result image by concatenating all bands
if is3D
    res = zeros([dim(1:2) 3 dim(3)], 'uint8');
    res(:,:,1,:) = red;
    res(:,:,2,:) = green;
    res(:,:,3,:) = blue;
else
    res = cat(3, red, green, blue);
end



function [dim isColor is3D] = computeImageInfo(img)
% Compute image size, and determines if image is 3D and/or color
% Returns the dimension of image witghout the color channel, and two binary
% flags indicating if image is color, and 3D.


% size of matlab matrix
dim0    = size(img);

% detect 3D and color image
if length(dim0)==2
    % Default case: planar grayscale image
    dim     = dim0(1:2);
    isColor = false;
    is3D    = false;
    
elseif length(dim0)==3
    % either 3D grayscale, or planar color image
    if dim0(3)==3
        % third dimension equals 3 ==> color image
        dim     = dim0(1:2);
        isColor = true;
        is3D    = false;
    else
        % third dimension <> 3 ==> gray-scale 3D image
        dim     = dim0;
        isColor = false;
        is3D    = true;
    end
    
elseif length(dim0)==4
    % 3D color image
    dim     = dim0([1 2 4]);
    isColor = true;
    is3D    = true;
    
else
    error('Unprocessed dimension');
end


function [r g b] = parseOverlayBands(color)
% determines r g and b values from argument value
%
% argument COLOR can be one of:
% - a 1*3 row vector containing rgb values between 0 and 1
% - a string containing color code
% - a grayscale image
% - a color image
%
% The result are the R, G and B values coded as uint8 between 0 and 255
%

if ischar(color)
    % parse character to  a RGB triplet
    [r g b] = parseColorString(color);
    
elseif isnumeric(color)
    if size(color, 1)==1
        % normalize color between 0 and 255
        if max(color)<=1
            color = color*255;
        end
        
        % extract each component
        r = color(1);
        g = color(2);
        b = color(3);
    else
        % otherwise, color is another image
        [dim isColor is3D] = computeImageInfo(color); %#ok<ASGLU>
        if isColor
            if is3D
                r = squeeze(color(:,:,1,:));
                g = squeeze(color(:,:,2,:));
                b = squeeze(color(:,:,3,:));
            else
                r = color(:,:,1);
                g = color(:,:,2);
                b = color(:,:,3);
            end
        else
            r = color;
            g = color;
            b = color;
        end
    end
else
    error('Wrong data type for specifying color');
end

            
function varargout = parseColorString(color)
% PARSECOLOR Parse color character to  a RGB triplet, between 0 and 1

% process special colors
if strcmp(color, 'black')
    color = 'k'; 
end

% tests the first character of the string
color = color(1);
switch color
    case 'r', r=1; g=0; b=0;
    case 'g', r=0; g=1; b=0;
    case 'b', r=0; g=0; b=1;
    case 'c', r=0; g=1; b=1;
    case 'm', r=1; g=0; b=1;
    case 'y', r=1; g=1; b=0;
    case 'k', r=0; g=0; b=0;
    case 'w', r=1; g=1; b=1;
end

% convert to uint8
r = uint8(r*255);
g = uint8(g*255);
b = uint8(b*255);

% format output 
if nargout==3
    varargout{1} = r;
    varargout{2} = g;
    varargout{3} = b;
else
    varargout{1} = [r g b];
end

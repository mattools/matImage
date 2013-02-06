function img = imCreate(size, type, varargin)
%IMCREATE Create a new image with given the size and type
%
%   IMG = imCreate(SIZE, TYPE)
%   IMG = imCreate(SIZE, TYPE, INITIALVALUE)
%   
%   Description
%   IMG = imCreate(SIZE, TYPE)
%   SIZE is a row vector containing the size of the result image, and TYPE
%   is a string representating the class of result image.
%   The size is given in XY or XYZ order, contrary to creation using the
%   ones or zeros functions. The objectiove is to have a unified function
%   for creating 2D or 3D images, with different number of channels.
%
%   Examples
%   % create uint8 image
%   img = imCreate([256 256], 'uint8');
%   imshow(img);
%
%   % create binary image
%   img = imCreate([256 256], 'logical');
%   imshow(img);
%
%   % create an image with same size and type as another image
%   baseImage = imread('peppers.png');
%   img = imCreate(imSize(baseImage), class(baseImage));
%   imshow(img);
%
%   % create uint8 image filled with dark gray pixels
%   img = imCreate([256 256], 'uint8', 100);
%   imshow(img);
%
%   See also
%   zeros, ones, false
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% default output type is uint8
if nargin < 2
    type = 'uint8';
end

% copnvert from XYZ to Matlab ordering
dim = size([2 1 3:end]);

% add a color component if requested
color = false;
if strcmp(type, 'color') || strcmp(type, 'rgb')
    dim = [dim(1:2) 3 dim(3:end)];
    type = 'uint8';
    color = true;
end

% allocate memory depending on type
if strcmp(type, 'logical')
    img = false(dim);
else
    img = zeros(dim, type);
end

% initialize with given value
if ~isempty(varargin)
    if color
        init = varargin{1};
        if isscalar(init)
            init = [init init init];
        end
        img(:,:,1) = init(1);
        img(:,:,2) = init(2);
        img(:,:,3) = init(3);
    else
        img(:) = varargin{1};
    end
end

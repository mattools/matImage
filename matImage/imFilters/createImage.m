function img = createImage(size, type, varargin)
%CREATEIMAGE Create a new image with given size and type
%
%   Deprecated, use 'imCreate' instead.
%
%   Usage
%   IMG = createImage(SIZE, TYPE)
%   IMG = createImage(SIZE, TYPE, VALUE)
%   
%   Description
%   IMG = createImage(SIZE, TYPE)
%   SIZE is a row vector containing the size of the result image, and TYPE
%   is a string representating the class of result image.
%   The effect is similar to the function 'zeros' or 'false', but attends
%   to provide a unified method to create image.
%
%   Example
%   % create uint8 image
%   img = createImage([256 256], 'uint8');
%   imshow(img);
%
%   % create binary image
%   img = createImage([256 256], 'logical');
%   imshow(img);
%
%   % create an image with same size and type as another image
%   baseImage = imread('cameraman.tif');
%   img = createImage(size(baseImage), class(baseImage));
%   imshow(img);
%
%   % create uint8 image filled with dark gray pixels
%   img = createImage([256 256], 'uint8', 100);
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

warning('malimpa:imFilters:createImage:deprecated', ...
    'function createImage is obsolete, use imCreate instead');

% allocate memory depending on type
if strcmp(type, 'logical')
    img = false(size);
else
    img = zeros(size, type);
end

% initialiaze with given value
if ~isempty(varargin)
    img(:) = varargin{1};
end

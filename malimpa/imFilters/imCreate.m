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
%   The effect is similar to the function 'zeros' or 'false', but attends
%   to provide a unified method to create image.
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
%   baseImage = imread('cameraman.tif');
%   img = imCreate(size(baseImage), class(baseImage));
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

% allocate memory depending on type
if strcmp(type, 'logical')
    img = false(size);
else
    img = zeros(size, type);
end

% initialize with given value
if ~isempty(varargin)
    img(:) = varargin{1};
end

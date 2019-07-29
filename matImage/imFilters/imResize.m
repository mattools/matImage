function res = imResize(img, varargin)
%IMRESIZE Resize 2D or 3D image.
%
%   RES = imResize(IMG, SCALE)
%   Returns an image that is SCALE times the size of IMG. IMG can be a
%   grayscale, RGB, or binary image, with 2 or 3 spatial dimensions.
%
%   This function is simply a wrapper to the original 'imresize' or
%   'imresize3' functions, depending on the dimension of the input array.
%
%   Example
%   imResize
%
%   See also
%     imresize, imDownSample
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-07-29,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.

if is3DImage(img)
    res = imresize3(img, varargin{:});
else
    res = imresize(img, varargin{:});
end
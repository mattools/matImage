function b = isColorImage(img)
%ISCOLORIMAGE  Check if an image is a color image
%
%   B = isColorImage(IMG);
%   Returns TRUE if the image IMG is color image. An image is assumed to be
%   color if all conditions are satisfied: 
%   - number of dimensions is >= 3
%   - size of third dimension is equal to 3
%   - other dims are not equal to 3 (a 3x3x3 matrix is assumed to be 3D).
%
%   Example
%   isColorImage(imread('cameraman.tif'))
%   ans =
%       0
%
%   isColorImage(imread('peppers.png'))
%   ans =
%       1
%
%   See also
%   is3DImage
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

b = true;

% check number of dimension
dim = size(img);
if length(dim)<3
    b = false;
    return
end

% check third dimension
if dim(3)~=3
    b = false;
    return
end

% check other dimensions
if sum(dim([1:2 4:end])~=3)==0
    b = false;
    return
end


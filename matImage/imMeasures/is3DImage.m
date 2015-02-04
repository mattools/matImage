function b = is3DImage(img)
%IS3DIMAGE  Check if an image is 3D
%
%   B = isColorImage(IMG);
%   Returns TRUE if the image IMG is 3D. An image is assumed to be 3D if
%   all conditions are satisfied:
%   - number of dimensions is >= 3
%   - size of third dimension is not equal to 3, or all sizes equal 3
%
%   Example
%   % planar image
%   is3DImage(imread('cameraman.tif'))
%   ans = 
%       0
%
%   % Three-D image
%   is3DImage(ones(5, 5, 5))
%   ans =
%       1
%
%   % planar color image
%   is3DImage(ones(5, 5, 3))
%   ans =
%       0
%
%   Three-D color image
%   is3DImage(ones(5, 5, 3, 4));
%   ans =
%       1
%
%   See also
%     isColorImage
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check number of dimension
dim = size(img);
if length(dim) < 3
    b = false;
    return
end

% check all dimensions equal to 3
if sum(dim([1:2 4:end])~=3) == 0
    b = true;
    return
end

% check third dimension
if dim(3) == 3
    dim(3) = [];
end

% 3D if 3 dimensions...
b = length(dim) == 3;

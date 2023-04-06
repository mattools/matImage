function slice = imMiddleSlice(img)
%IMMIDDLESLICE Extract the middle slice of a 3D stack
%
%   SLICE = imMiddleSlice(STACK)
%
%   Example
%   imMiddleSlice
%
%   See also
%   imStacks, stackSlice
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-06-05,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.

switch ndims(img)
    case 3
        slice = img(:,:,round(size(img, 3) / 2));
    case 4
        slice = img(:,:,:,round(size(img, 4) / 2));
    otherwise
        error('Requires an input image with 3 or 4 dimensions');
end
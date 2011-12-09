function color = isColorStack(img)
%ISCOLORSTACK  Check if a 3D stack is color or gray-scale
%
%   COL = isColorStack(IMG)
%   Returns TRUE if the 3D image has a color dimension, or FASLE if the
%   image is gray scale image.
%
%   This function was mainly created for simplifying the listings of other
%   functions in the same package.
%
%   Example
%   img = analyze75read(analyze75info('brainMRI.hdr'));
%   isColorStack(img)
%   ans = 
%       0
%
%
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-02,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.

dim = size(img);
color = length(dim)>3;
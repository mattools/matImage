function varargout = imFind(img)
%IMFIND Return coordinates of non-zero pixels in an image
%
%   PTS = imFind(IMG)
%   Identify the pixels whose value is different from zero, and returns
%   their coordinates in a N-by-2 or N-by-3 array, depending on the image
%   dimension.
%   This function is mainly a wrapper to the native 'find' function, that
%   returns result in a more intuitive way when working with images.
%
%   [X Y] = imFind(IMG)
%   [X Y Z] = imFind(IMG)
%   Returns the coordinates in different arrays.
%
%   Example
%     % Identifies pixels with high values in cameraman image
%     img = imread('cameraman.tif');
%     figure; imshow(img);
%     pts = imFind(img > 240);
%     hold on; drawPoint(pts)
%     % alternative usage:
%     [x y] = imFind(img > 240);
%     plot(x, y, 'm.')
%
%   See also
%     find

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-08-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

if islogical(img)
    inds = find(img);
else
    inds = find(img > 0);
end

dim = size(img);
nd = length(dim);

% convert indices to coords
if nd == 2
    [y, x] = ind2sub(dim, inds);
else
    [y, x, z] = ind2sub(dim, inds);
end

% format output
if nargout <= 1
    if nd == 2
        varargout = {[x y]};
    else
        varargout = {[x y z]};
    end
else
    if nd == 2
        varargout = {x, y};
    else
        varargout = {x, y, z};
    end
end

function s = imMin(img, varargin)
%IMMIN Minimum value of a grayscale image, or of each color component
%
%   S = imMin(IMG)
%   Computes the minimum value of pixels in image IMG. If image is grayscale
%   image, the result is a scalar. If image is a color image, the result is
%   1-by-3 row vector, each componenent corresponding to one color of the
%   image.
%
%   S = imMin(IMG, MASK)
%   Computes the minimum value only in the area specified by MASK.
%
%   S = imMin(..., 'color', COL)
%   Forces the function to consider the image as color (if COL is TRUE) or
%   as grascale (if COL is FALSE). This can be useful for vector image with
%   more than 3 color components. 
%
%
%   Example
%   % apply to cameraman image
%   img = imread('cameraman.tif');
%   imMin(img)
%   ans =
%       253
%
%   % apply to a RGB image
%   img = imread('peppers.png');
%   imMin(img)
%   ans =
%       255   255   255
%
%   See also
%   imMax, imMedian, imMean
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Process input arguments

% detect if image is color
color = isColorImage(img);

% check if user specified 'color' option
if length(varargin)>1
    var = varargin{end-1};
    if ischar(var)
        if strcmpi(var, 'color')
            color = varargin{end};
            varargin(end-1:end) = [];
        end
    end
end


%% Process color image

if color
    % If image is color, process each band separately

    % compute image size and dimension (including color dimension)
    dim = size(img);
    nd = length(dim);
    
    % create idnexing structure
    inds = cell(1, nd);
    for i=1:nd
        inds{i} = 1:dim(i);
    end
    
    % iterate on colors
    nc = dim(3);
    s = zeros(1, nc);
    for i=1:nc
        % modify the indexing structure to work on the i-th component
        inds{3} = i;
        s(i) = imMin(img(inds{:}), varargin{:});
    end
    
    return;
end


%% process grayscale image

if isempty(varargin)
    % compute min over all image
    s = min(img(:));
else
    % use first argument as mask
    s = min(img(varargin{1}));
end

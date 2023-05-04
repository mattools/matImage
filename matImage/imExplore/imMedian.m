function s = imMedian(img, varargin)
%IMMEDIAN Median value of a grayscale image, or of each color component
%
%   S = imMedian(IMG)
%   Computes the median value of pixels in image IMG. If image is grayscale
%   image, the result is a scalar. If image is a color image, the result is
%   1-by-3 row vector, each componenent corresponding to one color of the
%   image.
%
%   S = imMedian(IMG, MASK)
%   Computes the median value only in the area specified by MASK.
%
%   S = imMedian(..., 'color', COL)
%   Forces the function to consider the image as color (if COL is TRUE) or
%   as grascale (if COL is FALSE). This can be useful for vector image with
%   more than 3 color components. 
%
%
%   Example
%   % apply to cameraman image
%   img = imread('cameraman.tif');
%   imMedian(img)
%   ans =
%       144
%
%   % apply to a RGB image
%   img = imread('peppers.png');
%   imMedian(img)
%   ans =
%       90    43    60
%
%   See also
%   imMin, imMax, imMean, imMode
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
        s(i) = imMedian(img(inds{:}), varargin{:});
    end
    
    return;
end


%% process grayscale image

if isempty(varargin)
    % compute sum over all image
    s = median(img(:));
else
    % use first argument as mask
    s = median(img(varargin{1}));
end

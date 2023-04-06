function s = imStd(img, varargin)
%IMSTD Standard deviation of pixel values
%
%   S = imStd(IMG)
%   Computes the standard deviation of pixel values in image IMG. If image
%   is grayscale image, the result is a scalar. If image is a color image,
%   the result is 1-by-3 row vector, each componenent corresponding to one
%   color of the image.
%
%   S = imStd(IMG, MASK)
%   Computes the standard deviation only in the area specified by MASK.
%
%   S = imStd(..., 'color', COL)
%   Forces the function to consider the image as color (if COL is TRUE) or
%   as grascale (if COL is FALSE). This can be useful for vector image with
%   more than 3 color components. 
%
%
%
%   Example
%   % apply to cameraman image
%   img = imread('cameraman.tif');
%   imStd(img)
%   ans =
%       62.3417
%
%   % apply to a RGB image
%   img = imread('peppers.png');
%   imStd(img)
%   ans =
%       66.5441   51.1968   41.4824
%
%   See also
%   imMean, imVar
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
        s(i) = imStd(img(inds{:}), varargin{:});
    end
    
    return;
end


%% process grayscale image

if isempty(varargin)
    % compute mean over all image
    s = std(double(img(:)));
else
    % use first argument as mask
    s = std(double(img(varargin{1})));
end

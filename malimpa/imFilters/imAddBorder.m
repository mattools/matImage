function res = imAddBorder(img, pad, varargin)
%IMADDBORDER  Add a border around a 2D or 3D image
%
%   IMG = imAddBorder(IMG, BORDER)
%   adds BORDER pixels around the image. The size of new image is given by
%   size(IMG)+2*BORDER. 
%   The function works for 2D or 3D images.
%
%   IMG = imAddBorder(IMG, [BORDER1 BORDER2])
%   or
%   IMG = imAddBorder(IMG, [BORDER1 BORDER2 BORDER3])
%   Specifies different borders for borders in first and second directions
%   (and third direction for 3D images)
%
%   IMG = imAddBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21])
%   or
%   IMG = imAddBorder(IMG, [BORDER10 BORDER11 BORDER20 BORDER21 BORDER30 BORDER31])
%   Specifies different borders for borders in first and second directions,
%   and in the beginning and at the end in each direction.
%
%   IMG = imAddBorder(..., BACKGROUND)
%   specifies the value of the background color.
%
%   Example
%   % Add 3 pixel in each side of a square
%   img = imAddBorder(ones(4, 4), 3);
%   imshow(img);
%
%   % add borders with different sizes
%   img = imAddBorder(ones(5, 5), [3 4 5 6]);
%   imshow(img);
%
%
%   See also
%   padarray (does nearly similar job)
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-08-24,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"

% extract background value
background = 0;
if ~isempty(varargin)
    background = varargin{1};
end    

% size of input image
dim = size(img);

if length(dim)==2
    % convert pad to have 4 values
    if length(pad)==1
        pad = [pad pad pad pad];
    elseif length(pad)==2
        pad = [pad(1) pad(1) pad(2) pad(2)];
    end

    % compute new dimension
    dim2 = dim + [sum(pad(1:2)) sum(pad(3:4))];

    % create result image
    if islogical(img)
        res = false(dim2);
    else
        res = ones(dim2, class(img));
    end
    res(:) = background;
    
    % fillup result image with initial image
    res((1:size(img, 1))+pad(1), (1:size(img, 2))+pad(3)) = img;
    
elseif length(dim)==3
    % convert pad to have 6 values
    if length(pad)==1
        pad = [pad pad pad pad pad pad];
    elseif length(pad)==3
        pad = [pad(1) pad(1) pad(2) pad(2) pad(3) pad(3)];
    end

    % compute new dimension
    dim2 = dim + [sum(pad(1:2)) sum(pad(3:4)) sum(pad(5:6))];

    % create result image
    if islogical(img)
        res = false(dim2);
    else
        res = ones(dim2, class(img));
    end
    res(:) = background;
    
    % fillup result image with initial image
    res((1:size(img, 1))+pad(1),...
        (1:size(img, 2))+pad(3), ...
        (1:size(img, 3))+pad(5)) = img;
    
else
    error('Image dimension not managed');
end
    

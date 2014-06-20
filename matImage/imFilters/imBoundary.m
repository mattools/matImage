function bnd = imBoundary(img, varargin)
%IMBOUNDARY  Compute the boundary image of a binary image
%
%   BND = imBoundary(IMG)
%   IMG is a boundary image with one or several structures of interest
%   coded as 1 (white) over a 0 (black) background.
%   BND is the set of boundary pixel of the structure, that is the pixels
%   that belongs to the structure and that touch the background.
%
%   BND = imBoundary(IMG, CONN)
%   Specifies the connectivity to use. CONN can be 4 or 8 for planar
%   images, 6 or 26 for 3D images.
%
%   BND = imBoundary(IMG, SE)
%   Specify the structuring element that will be used for detecting
%   neighborhood.
%
%   BND = imBoundary(IMG, TYPE)
%   Specifies whether the function should compute the outer or inner
%   boundary. TYPE can be either 'outer' or 'inner'.
%
%   The function works for binary 2D or 3D images. It should work with
%   images of greater dimension by supplying appropriate structuring
%   element.
%
%   Example
%   BW = imread('circles.png');
%   figure;
%   subplot(121);imshow(imBoundary(BW)); title('inner boundary');
%   subplot(122);imshow(imBoundary(BW, 'outer')); title('outer boundary');
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-14,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% default parameters

% number of dimensions
nd = ndims(img);

% default structuring element
if nd==2
    se = [0 1 0;1 1 1;0 1 0];
elseif nd==3
    se = cross3d;
else
    se = ones(3*ones(1, nd));
end

% operation to perform
op = @imerode;


%% Process input arguments

while ~isempty(varargin)
    var = varargin{1};
    if isnumeric(var)
        if length(var)==1
            switch var
                case 4
                    se = [0 1 0;1 1 1;0 1 0];
                case 8
                    se = ones(3,3);
                case 6
                    se = cross3d;
                case 26
                    se = ones([3 3 3]);
                otherwise
                    error('unknown value for connectivity');
            end
        else
            se = var;
        end
    elseif ischar(var)
        switch var
            case 'outer'
                op = @imdilate;
            case 'inner'
                op = @imerode;
            otherwise
                error('unknown string option');
        end
    end
    
    varargin(1) = [];
end

%% Process

% erode the structure and compare with original
bnd = op(img, se) ~= img;


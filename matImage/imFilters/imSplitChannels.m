function [r, g, b] = imSplitChannels(rgb)
%IMSPLITCHANNELS Split the 3 channels of a 2D or 3D image
%
%   [R, G, B] = imSplitChannels(RGB);
%   
%   Example
%   img = imread('peppers.png');
%   [r, g, b] = imSplitChannels(img);
%   figure; imshow(r); title('red');
%   figure; imshow(g); title('green');
%
%   See also
%     imMergeChannels

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-02-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

if ndims(rgb) == 3
    % process planar image
    r = rgb(:,:,1);
    g = rgb(:,:,2);
    b = rgb(:,:,3);
    
elseif ndims(rgb) == 4
    % process 3D image
    r = squeeze(rgb(:,:,1,:));
    g = squeeze(rgb(:,:,2,:));
    b = squeeze(rgb(:,:,3,:));
else 
    error('unprocessed image dimension');
end

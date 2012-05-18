function res = imFlip(img, dim)
%IMFLIP Flip an image along one of its dimensions
%
%   IMG2 = imFlip(IMG, DIM);
%   Flips the image IMG with respect to the axis DIM.
%   D=1 corresponds to x axis
%   D=2 corresponds to y axis
%   D=3 (for 3D images) corresponds to z axis
%
%   IMG2 = imFlip(img);
%   flip with respect to first axis (horizontal flip)
%
%   Example
%     % flip an image in the x and y axes
%     img = imread('cameraman.tif');
%     subplot(1, 3, 1); imshow(img);
%     subplot(1, 3, 2); imshow(imFlip(img, 1)); title('Horiz. Flip');
%     subplot(1, 3, 3); imshow(imFlip(img, 2)); title('Vert. Flip');
%
%     % display slice of a flipped stack
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     % flip in the Y direction
%     I2 = imFlip(I, 2);
%     figure;
%     subplot(121); imshow(I(:,:,13));
%     subplot(122); imshow(I2(:,:,13));
%
%   See also
%   imRotate90, flipdim
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-05-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% ensure dimension is given
if nargin == 1
    dim = 1;
end

% number of physical dimensions
nd = ndims(img);
if isColorImage(img)
    nd = nd - 1;
end

% check dim
if dim > nd
    error('Can not flip a dimension greater than image dimension');
end

% convert indices
inds = [2 1 4 3 5];
dim = inds(dim);

% create result image
res = flipdim(img, dim);

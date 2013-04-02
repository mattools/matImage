function bin = imCropLabel(img, label)
%IMCROPLABEL Extract the portion of image that contains the specified label
%
%   BIN = imCropLabel(IMG, LABEL)
%   Crops the regions in original label image IMG that corresponds to the
%   label given by the index LABEL. Works for 2D and 3D images.
%   The result is a binary image. A 1-pixel thick boundary is left around
%   the binary result, unless the label touches original image borders.
%
%   Example
%     % read and segment a demo image
%     img = imread('coins.png');
%     bin = imFillHoles(imOtsuThreshold(img));
%     lbl = bwlabel(bin, 4);
%     % crop region corresponding to label 3
%     bin3 = imCropLabel(lbl, 3);
%     imshow(bin3);
%
%   See also
%   imcrop, label2rgb
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-04-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


% get image size and dimension
dim = size(img);
nd = length(dim);

% binarize image
bin = img == label;

if nd == 2
    % first array direction
    l1 = sum(bin, 2);
    i0(1) = find(l1, 1, 'first');
    i1(1) = find(l1, 1, 'last');
    
    % second array direction
    l1 = sum(bin, 1);
    i0(2) = find(l1, 1, 'first');
    i1(2) = find(l1, 1, 'last');
    
    % try to add one pixel if not outside boundary
    inds = i0 > 1;
    i0(inds) = i0(inds) - 1;
    inds = i1 < dim;
    i1(inds) = i1(inds) + 1;
    
    % extract only the necessary part of image
    bin = bin(i0(1):i1(1), i0(2):i1(2));

    
elseif nd == 3
    % first array direction
    l1 = sum(sum(bin, 2), 3);
    i0(1) = find(l1, 1, 'first');
    i1(1) = find(l1, 1, 'last');
    
    % second array direction
    l1 = sum(sum(bin, 1), 3);
    i0(2) = find(l1, 1, 'first');
    i1(2) = find(l1, 1, 'last');
    
    % third array direction
    l1 = sum(sum(bin, 1), 2);
    i0(3) = find(l1, 1, 'first');
    i1(3) = find(l1, 1, 'last');
    
    % try to add one pixel if not outside boundary
    inds = i0 > 1;
    i0(inds) = i0(inds) - 1;
    inds = i1 < dim;
    i1(inds) = i1(inds) + 1;
    
    % extract only the necessary part of image
    bin = bin(i0(1):i1(1), i0(2):i1(2), i0(3):i1(3));

else
    error('Can not manage dimensions other than 2 or 3');
end

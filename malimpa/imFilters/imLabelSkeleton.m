function lbl = imLabelSkeleton(skel)
%IMLABELSKELETON Label skeleton pixels according to local topology
%
%   LBL = imLabelSkeleton(SKEL)
%   Associates a label to each pixel of the binary imag SKEL, depending on
%   the local topology:
%   0 -> background pixel
%   1 -> extremity pixel, with one neighbor
%   2 -> edge pixel, with two neighbors
%   3 -> intersection pixel, with at least 3 neighbors.
%
%   Example
%   % Color representation of a skeleton
%     img = imread('circles.png');
%     skel = imSkeleton(img);
%     lbl = imLabelSkeleton(skel);
%     rgb = label2rgb(lbl, [1 0 0;0 1 0;0 0 1], [1 1 1]);
%     imshow(rgb);
%
%   % overlay on binary image
%     ovr = imOverlay(img, skel, rgb);
%     figure; imshow(ovr);
%
%   See also
%     imSkeleton, label2rgb
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-08-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

lbl = min(imfilter(double(skel), ones(3, 3)) - 1, 3);
lbl(~skel) = 0;

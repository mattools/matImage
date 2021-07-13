function res = imSkeleton(img, varargin)
% Homothopic skeleton of a binary image.
%
%   SK = imSkeleton(IMG)
%   Computes the skeleton of the binary image IMG. The skeleton is computed
%   by iterative homothopic thinning of the input image.
%   Basically, this is just a wrapper for the "bwmorph" function. If the
%   "bwskel" function (introduced in 2018) is found, it is used instead.
%
%   Example
%     img = imread('circles.png');
%     skel = imSkeleton(img);
%     ovr = imOverlay(img, skel);
%     imshow(ovr)
%
%   See also
%     bwmorph, bwskel, imLabelSkeleton, imBoundary, imOverlay
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-05-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

if exist('bwskel', 'file')
    res = bwskel(img);
else
    res = bwmorph(img, 'thin', Inf);
end

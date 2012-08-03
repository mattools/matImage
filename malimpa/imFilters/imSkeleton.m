function res = imSkeleton(img, varargin)
%IMSKELETON  Homothopic skeleton of a binary image 
%
%   SK = imSkeleton(IMG)
%   Computes the skeleton of the binary image IMG. The skeleton is computed
%   by iterative homothopic thinning of the input image.
%   Basically, this is a wrapper for the "bwmorph" function.
%
%   Example
%     img = imread('circles.png');
%     skel = imSkeleton(img);
%     ovr = imOverlay(img, skel);
%     imshow(ovr)
%
%   See also
%     bwmorph, imLabelSkeleton, imBoundary, imOverlay
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-05-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

res = bwmorph(img, 'thin', Inf);

function res = imFillHoles(img, varargin)
%IMFILLHOLES  Fill holes in a binary image
%
%   RES = imFillHoles(IMG)
%   Mainly a wrapper for the function imfill, that is more generic.
%
%   Example
%     img = imread('circles.png');
%     img2 = imFillHoles(img);
%     figure; imshow(img2);
%
%   See also
%   imSkeleton, imfill
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-05-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

res = imfill(img, 'holes');

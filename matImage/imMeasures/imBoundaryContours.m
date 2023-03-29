function [B, L, N, A] = imBoundaryContours(bin, varargin)
%IMBOUNDARYCONTOURS Extract polygonal contours of a binary image.
%
%   CNTS = imBoundaryContours(BIN)
%   Computes a set of contours corresponding to the structures in binary
%   image BIN. The result CNTS is a cell array of polygons, each polygon
%   being a N-by-2 array containing the vertex coordinates.
%
%   This function is mainly a wrapper to the 'bwboundaries' function, that
%   returns the resulting set of contours in a different format.
%   
%
%   Example
%     % draw the polygon corresponding to a single region
%     img = imread('circles.png');
%     polys = imContours(img);
%     figure; imshow(img); hold on;
%     drawPolygon(polys, 'r')
%
%   See also
%     bwboundaries, imcontour, imOtsuThreshold, imContourLines
%     contourMatrixToPolylines (MatGeom toolbox)
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-07-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% check input image is binary
if ~isempty(varargin)
    error('Requires input image to be binary.'); 
end

% call the native bwboundaries function
[B, L, N, A] = bwboundaries(bin);

% object boundaries
for i = 1:N
    bnd = B{i};
    B{i} = bnd(:, [2 1]);
end

% hole boundaries
for i = N+1:length(B)
    bnd = B{i};
    B{i} = bnd([1 end:-1:2], [2 1]);
end

function polys = imContourLines(img, v, varargin)
%IMCONTOURLINES Extract iso contours of an image as polylines.
%
%   POLYS = imContourLines(IMG, ISOVALUE)
%   Computes isocontours at ISOVALUE value in the grayscale or intensity
%   image IMG. The result is given as a cell array, each cell contains a
%   N-by-2 numeric array representing vertices of the contour.
%   The resulting polygons may be plotted using the polt function, or one
%   of the functions from the "matGeom" library.
%
%   POLYS = imContourLines(LX, LY, IMG, ISOVALUE)
%   Specifies the values of the x- and y-axes.
%
%
%   Example
%     % create intensity image from a distance map
%     img = imread('circles.png');
%     distMap = imDistanceMap(~img);
%     figure; imshow(distMap, []); colormap('parula')
%     % compute isocontour lines, and display as overlay
%     polys = imContourLines(distMap, 10);
%     hold on; drawPolyline(polys, 'r')
%
%   See also
%     imBoundaryContours
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-03-29,    using Matlab 9.13.0.2049777 (R2022b)
% Copyright 2023 INRAE.


%% Compute contour matrix
% Use the "contourc" function to compute a 2-by-N contour matrix.

% switch call depending on input argument count.
if nargin == 2
    C = contourc(img, [v v]);

elseif nargin == 4
    lx = img;
    ly = v;
    img = varargin{3};
    v = varargin{4};
    C = contourc(lx, ly, img, [v v]);
end


%% convert Coutour matrix to polyline list
% Each polyline may be closed or open. Closed polyline have same vertex at
% the end and at the beginning.

% size of the contour matrix array
nCoords = size(C, 2);

% first, compute the number of contours
nContours = 0;
offset = 1;
while offset < nCoords
    nContours = nContours + 1;
    offset = offset + C(2, offset) + 1;
end

% extract each contour as a polygon or polyline
polys = cell(nContours, 1);
offset = 1;
for iContour = 1:nContours
    nv = C(2, offset);
    polys{iContour} = C(:, offset + (1:nv))';
    offset = offset + nv + 1;
end

function varargout = imChainPixels(img, varargin)
%IMCHAINPIXELS Chain neighbor pixels in an image to form a contour
%
%   POINTS = imChainPixels(IMG)
%   [PX, PY] = imChainPixels(IMG)
%   returns a list of points, chaining points visible in the image.
%   IMG shoud be a binary image, containing a single 8-connected loop.
%
%   Example
%     img = imread('circles.png');
%     img = imFillHoles(img);
%     bnd = imSkeleton(imBoundary(img));
%     figure; subplot(1, 3, 1); imshow(img);
%     subplot(1, 3, 2); imshow(imOverlay(img, bnd));
%     pts = imChainPixels(bnd);
%     subplot(1, 3, 3); imshow(img); hold on; 
%     drawPolygon(pts, 'g', 'linewidth', 2);
%
%   See Also
%     imFillHoles, imSkeleton, bwboundaries
%
%   -----
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 01/11/2003.
%

%   HISTORY
%   2004-04-06 add to graph lib, correct x-y ordering, and add doc.
%   2012-05-16 rename from findContour to imChainPixels


% set to logical
img = img ~= 0;

% find points in the image
[pty, ptx] = find(img);


% Initialize iteration: first set the initial point
points = zeros(length(ptx), 2);
x0 = ptx(1);
y0 = pty(1);
points(1, 1) = x0;
points(1, 2) = y0;

% Then set the second point, in the neighbourhood of the first point
vois = findNeighbors(img, [x0 y0]);
x = vois(1, 1);
y = vois(1, 2);
points(2, 1) = x;
points(2, 2) = y;

% For each point, find all neighbours (should be only 2)
% Compare with point previously processed, and choose the other one.
% then shift points references, and loop until all points are processed.
for p=3:length(points)
    vois = findNeighbors(img, [x y]);
    if vois(1,1)==x0 && vois(1,2)==y0
        x0 = x;
        y0 = y;
        x = vois(2, 1);
        y = vois(2, 2);
    else
        x0 = x;
        y0 = y;
        x = vois(1, 1);
        y = vois(1, 2);
    end
    points(p, 1) = x;
    points(p, 2) = y;
end


% format results to match output
if nargout==1
    varargout{1} = points;
elseif nargout==2
    varargout{1} = points(:, 1);
    varargout{2} = points(:, 2);
end


return



function neighList = findNeighbors(img, coord)

xp = coord(1);
yp = coord(2);
neighList = [];
nv = 0;

for x = xp-1:xp+1
    if img(yp-1, x)
        nv = nv+1;
        neighList(nv, 1) = x; %#ok<AGROW>
        neighList(nv, 2) = yp-1; %#ok<AGROW>
    end
    if img(yp+1, x)
        nv = nv+1;
        neighList(nv, 1) = x; %#ok<AGROW>
        neighList(nv, 2) = yp+1; %#ok<AGROW>
    end
end

if img(yp, xp-1)
    nv = nv+1;
    neighList(nv, 1) = xp-1;
    neighList(nv, 2) = yp;
end
if img(yp, xp+1)
    nv = nv+1;
    neighList(nv, 1) = xp+1;
    neighList(nv, 2) = yp;
end

function [points, labels] = imCentroid(img, varargin)
% Centroid of regions in a label image.
%
%   CENTRO = imCentroid(IMG)
%   Compute the centroid (center of mass) of each region in the label
%   image IMG. IMG can also be a binary image, in this case only one
%   centroid will be returned. The same result can be obtained with the
%   'regionprops' function, but extracting the centroids may be tedious.
%   
%   The result CENTRO is a N-by-2 array containing coordinates of particle
%   centroids. First column contains X coordinates, second column Y
%   coordinates.
%
%   If IMG is a 3D image (label or binary), the result is a N-by-3 array
%   containing x-, y- and z-ccordinates of the 3D centroids.
%
%   CENTRO = imCentroid(IMG, SPACING, ORIGIN)
%   Specifies the spatial calibration of the image. SPACING and ORIGIN must
%   be 1-by-ND row vectors.
%
%   CENTRO = imCentroid(IMG, LABELS)
%   Specify the labels for which the centroids needs to be computed. The
%   result is a N-by-2 or N-by-3 array with as many rows as the number of
%   labels.
%
%   [CENTRO, LABELS] = imCentroid(...)
%   Also returns the label for which a centroid was computed. Can be useful
%   in case of a label image with 'missing' labels.
%
%   Example
%   % Draw a commplex particle together with its centroids
%     img = imread('circles.png');
%     imshow(img); hold on;
%     pts = imCentroid(img);
%     drawPoint(pts, '+')
%
%   % Compute and display the centroid of several particles
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     lbl = bwlabel(img2 > 50, 4);
%     centroids = imCentroid(lbl);
%     imshow(img); hold on;
%     drawPoint(centroids, 'marker', '+', 'linewidth', 2);
%
%   See also
%     regionprops, drawPoint, imBoundingBox, imEquivalentEllipse
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-03-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Process input arguments

% default spatial calibration
nd = ndims(img);
spacing = ones(1, nd);
origin  = ones(1, nd);
calib   = false;

% extract spacing
if ~isempty(varargin) && all(size(varargin{1}) == [1 nd])
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = zeros(1, nd);
    
    % extract origin
    if ~isempty(varargin) && all(size(varargin{1}) == [1 nd])
        origin = varargin{1};
        varargin(1) = [];
    end
end

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);

% allocate memory for result
nd = ndims(img);
points = zeros(nLabels, nd);
    
if nd == 2
    if isnumeric(img) || islogical(img)
        for i = 1:nLabels
            % extract points of the current particle
            [y, x] = find(img==labels(i));
            
            % coordinates of particle centroid
            xc = mean(x);
            yc = mean(y);
            
            points(i, :) = [xc yc];
        end
        
    elseif isstruct(img)
        % process a CC structure (see bwconncomp)
        for i = 1:nLabels
            [y, x] = ind2sub(img.ImageSize, img.PixelIdxList{i});
            % coordinates of particle centroid
            xc = mean(x);
            yc = mean(y);
            points(i, :) = [xc yc];
        end
    end
    
elseif nd == 3
    dim = size(img);
    if isnumeric(img) || islogical(img)
        for i = 1:nLabels
            % extract points of the current particle
            inds = find(img==labels(i));
            [y, x, z] = ind2sub(dim, inds);
            
            % coordinates of particle centroid
            xc = mean(x);
            yc = mean(y);
            zc = mean(z);
            
            points(i, :) = [xc yc zc];
        end
        
    elseif isstruct(img)
        % process a CC structure (see bwconncomp)
        for i = 1:nLabels
            [y, x, z] = ind2sub(img.ImageSize, img.PixelIdxList{i});
            % coordinates of particle centroid
            xc = mean(x);
            yc = mean(y);
            zc = mean(z);
            
            points(i, :) = [xc yc zc];
        end
    end
    
else    
    error('Input image must be 2D or 3D');
    
end

% calibrate result
if calib
    points = bsxfun(@plus, bsxfun(@times, points-1, spacing), origin);
end

function [diam, varargout] = imMaxFeretDiameter(img, varargin)
% Maximum Feret diameter of a binary or label image.
%
%   FD = imMaxFeretDiameter(IMG)
%   Computes the maximum Feret diameter of regions in a label image IMG.
%   The result is a N-by-1 column vector, containing the Feret diameter of
%   each region in IMG.
%
%   [FD, THETAMAX] = imMaxFeretDiameter(IMG)
%   Also returns the direction for which the diameter is maximal. THETAMAX
%   is given in degrees, between 0 and 180.
%
%   FD = imMaxFeretDiameter(IMG, LABELS)
%   Specify the labels for which the Feret diameter needs to be computed.
%   The result is a N-by-1 array with as many rows as the number of labels.
%
%
%   Example
%     img = imread('circles.png');
%     diam = imMaxFeretDiameter(img)
%     diam =
%         272.7144
%
%   See also
%     imFeretDiameter, imOrientedBox
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-07-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Process input arguments

nd = ndims(img);

% extract orientations (for 2D Feret Diameters)
thetas = 180;
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    thetas = varargin{1};
    varargin(1) = [];
end

if isscalar(thetas)
    % assume this is the number of directions to use
    thetas = linspace(0, 180, thetas+1);
    thetas = thetas(1:end-1);
end

% default spatial calibration
spacing = ones(1, nd);
origin  = ones(1, nd);
calib   = false;

% extract spacing
if ~isempty(varargin) && sum(size(varargin{1}) == [1 nd]) == nd
    spacing = varargin{1};
    varargin(1) = [];
    calib = true;
    origin = zeros(1, nd);
    
    % extract optional origin
    if ~isempty(varargin) && sum(size(varargin{1}) == [1 nd]) == nd
        origin = varargin{1};
        varargin(1) = [];
    end
end

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end


%% Initialisations

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end
nLabels = length(labels);


%% Process
if nd == 2
    % allocate memory for result
    diam = zeros(nLabels, 1);
    thetaMax = zeros(nLabels, 1);

    % for each label, compute set of diameters, and keep the max
    for i = 1:nLabels
        if calib
            diams = imFeretDiameter(img == labels(i), thetas, spacing, origin);
        else
            diams = imFeretDiameter(img == labels(i), thetas);
        end

        % find max diameters, with indices
        [diam(i), ind] = max(diams, [], 2);

        % keep max orientation
        thetaMax(i) = thetas(ind);
    end

    if nargout > 1
        varargout = {thetaMax};
    end

else

    
    % init
    maxDist = zeros(nLabels,1); 
    indMax1 = -1 * ones(nLabels,1); 
    indMax2 = -1 * ones(nLabels,1);

    dims = size(img);
    
    % for each label, compute set of diameters, and keep the max
    for i = 1:nLabels
        % retrieve boundary points
        bin = img == labels(i);
        [y1, x1, z1] = ind2sub(dims - [0 1 0], find(bin(:,1:end-1, :) & ~bin(:,2:end, :)));
        [y2, x2, z2] = ind2sub(dims - [0 1 0], find(bin(:,2:end, :) & ~bin(:,1:end-1, :)));
        [y3, x3, z3] = ind2sub(dims - [1 0 0], find(bin(2:end,:, :) & ~bin(1:end-1,:, :)));
        [y4, x4, z4] = ind2sub(dims - [1 0 0], find(bin(1:end-1,:, :) & ~bin(2:end,:, :)));
        [y5, x5, z5] = ind2sub(dims - [0 0 1], find(bin(:, :,1:end-1) & ~bin(:, :,2:end)));
        [y6, x6, z6] = ind2sub(dims - [0 0 1], find(bin(:, :,2:end) & ~bin(:, :,1:end-1)));
        boundaryPoints = [...
            x1+0.5 y1 z1; x2+0.5 y2 z2; ...
            x3 y3+0.5 z3; x4 y4+0.5 z4; ...
            x5 y5 z5+0.5; x6 y6 z6+0.5; ...
            ];

        % compute convex hull
        tri = convhulln(boundaryPoints);
        vertexIndices = unique(tri(:));

        % iterate over pairs of vertices
        nv = length(vertexIndices);
        for iv1 = 1:nv-1
            p1 = boundaryPoints(vertexIndices(iv1), :);
            for iv2 = iv1+1:nv
                p2 = boundaryPoints(vertexIndices(iv2), :);
                dist = sum((p1 - p2).^2, 2);
                if dist > maxDist
                    maxDist = dist;
                    indMax1(i) = iv1;
                    indMax2(i) = iv2;
                end
            end
        end
    end

    % convert to Euclidean distance
    diam = sqrt(maxDist);

    if nargout > 1
        varargout = {boundaryPoints(vertexIndices(indMax1), :), boundaryPoints(vertexIndices(indMax2), :)};
    end
end

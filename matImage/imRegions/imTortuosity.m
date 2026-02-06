function res = imTortuosity(img, varargin)
% Tortuosity of the region(s) within binary or label image.
%
%   TOR = imTortuosity(IMG)
%   Computes the tortuosity of each region within the binary or label image
%   IMG. In the case of a binary image, only one region is considered.
%   The tortuosity is comouted as the ratio of the maximum Feret diameter
%   over the Geodesic diameter.
%
%   Example
%   % compute tortuosity of a single binary region
%   img = imread('circles.png');
%   imTortuosity(img)
%   ans =
%       1.5043
%
%   % compute tortuosity of each region within a label image
%   img = imread('coins.png');
%   [~, seg] = imOtsuThreshold(imFillHoles(imclose(img, ones(3, 3))));
%   lbl = bwlabel(seg, 4);
%   res = imTortuosity(lbl)
%   res =
%       1.0282
%       1.0190
%       1.0231
%       1.0237
%       1.0292
%       1.0188
%       1.0236
%       1.0180
%       1.0140
%       1.0220
%
%   See also
%     imMaxFeretDiameter, imGeodesicDiameter

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-02-06,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.


%% Initialisations

% check if labels are specified
labels = [];
if ~isempty(varargin) && size(varargin{1}, 2) == 1
    labels = varargin{1};
end

% extract the set of labels, without the background
if isempty(labels)
    labels = imFindLabels(img);
end


%% Main processing

fd = imMaxFeretDiameter(img, labels);
if islogical(img)
    img = uint8(img);
end
gd = imGeodesicDiameter(img);

res = gd ./ fd;
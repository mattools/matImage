function [res labels1 labels2] = imGeodesicDistance(mask, marker1, marker2, varargin)
%IMGEODESICDISTANCE Compute geodesic distance between 2 markers
%
%   RES = imGeodesicDistance(MASK, MARKER1, MARKER2);
%   Computes the geodesic distance between 2 markers with respect to the
%   given mask.
%   The function is defined for both 2D and 3D images
%
%
%   Example
%   mask = [...
%       0 0 0 0 0 0 0;...
%       0 1 0 1 1 1 0;...
%       0 1 0 1 0 1 0;...
%       0 1 1 1 0 1 0;...
%       0 0 0 0 0 0 0];
%   marker1 = zeros(size(mask));
%   marker1(2, 2) = 1;
%   marker2 = zeros(size(mask));
%   marker2(4, 6) = 2;
%   % result using quasi-euclidean distance equals 4*sqrt(2) + 2
%   imGeodesicDistance(mask, marker1, marker2)
%   ans =
%       7.6569
%   % result using orthogonal distance equals 4*sqrt(2) + 2
%   imGeodesicDistance(mask, marker1, marker2, [1 Inf])
%   ans =
%       10
%
%   See also
%   imGeodesics, imChamferDistance, imChamferDistance3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-12-07,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

% ensure mask is binary
mask = mask > 0;

% list of labels in each marker image
labels1 = unique(marker1);
labels2 = unique(marker2);
labels1(labels1==0) = [];
labels2(labels2==0) = [];

% number of labels for each marker image
N1 = length(labels1);
N2 = length(labels2);

% allocate memory for result
res = zeros(N1, N2);

% iterate on labels of first marker image
if ndims(mask) == 2
    for i = 1:N1
        dist = imChamferDistance(mask, marker1==labels1(i), varargin{:});

        for j = 1:N2
            res(i, j) = min(dist(marker2 == labels2(j)));
        end
    end
else
    for i = 1:N1
        dist = imChamferDistance3d(mask, marker1==labels1(i), varargin{:});

        for j = 1:N2
            res(i, j) = min(dist(marker2 == labels2(j)));
        end
    end
end

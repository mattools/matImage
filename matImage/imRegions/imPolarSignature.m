function [res, thetaList] = imPolarSignature(img, varargin)
%IMPOLARSIGNATURE Polar signature of region contour.
%
%   Syntax:
%   SIG = imPolarSignature(IMG)
%   SIG = imPolarSignature(IMG, ANGLES)
%   SIG = imPolarSignature(IMG, ANGLES, REF_POINT)
%   [SIG, ANGLES] = imPolarSignature(...)
%
%   SIG = imPolarSignature(IMG)
%   Computes the polar signature of the contour of the region within the
%   binary image IMG. The polar signature is obtained by computing the
%   distance between a reference point (usually the region centroid) and
%   contour points in regularly spaced directions. IMG must be a 2D binary
%   image. Uses 360 angles, ranging from 0 to 359 degrees.
%   The result SIG is a row vector containing for each angle the distance
%   to the boundary point in the directions given by the angle.
%   
%   SIG = imPolarSignature(IMG, ANGLES)
%   Specifies the angles to consider for computing the polar signature.
%   ANGLES can be either a scalar corresponding to the number of angles, or
%   a row vector containing the angles to consider.
%
%   SIG = imPolarSignature(IMG, ANGLES, REF_POINT)
%   Specifies the point to use as reference.
%
%   [SIG, ANGLES] = imPolarSignature(...)
%   Also returns the row vector containing the angles used for computing
%   the signature. ANGLES has as many elements as SIG.
%
%   Requires the "MatGeom" library for computation.
%
%   Example
%     img = zeros([200 200], 'uint8');
%     img(50:150, 50:150) = 255;
%     signature = imPolarSignature(img);
%     figure; subplot(1,2,1); imshow(imcomplement(img))
%     subplot(1,2,2); plot(signature); 
%     xlim([0 360]); ylim([0 100]);
%     set(gca, 'XTick', 0:45:360)
%
%
%   See also
%     polygonSignature, signatureToPolygon
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-20,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.

% choose regular basis of angles
thetaList = 0:359;
refPoint = [];

% get user-defined angle list
if ~isempty(varargin)
    var = varargin{1};
    if isscalar(var)
        thetaList = linspace(0, 360, var+1);
        thetaList(end) = [];
    else
        thetaList = var;
    end
end

% also extract reference point if needed
if nargin > 2
    refPoint = varargin{2};
end


% allocate memory for result
nTheta = length(thetaList);
res = NaN * ones(1, nTheta);

% use region centroid as default reference point
if isempty(refPoint)
    refPoint = imCentroid(img);
end

% compute contour (keep only the largest one)
polys = imBoundaryContours(img);
[~, indMax] = max(cellfun(@length, polys));
poly = polys{indMax};

% iterate on angles
for i = 1:length(thetaList)
    theta = deg2rad(thetaList(i));
    ray = [refPoint cos(theta) sin(theta)];

    ptInt = intersectRayPolygon(ray, poly);
    if ~isempty(ptInt)
        res(i) = distancePoints(refPoint, ptInt(end,:));
    end
end

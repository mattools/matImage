function [gr, vols] = imGranuloByRegion(img, lbl, granuloType, strelShape, strelSizes)
%IMGRANULOBYREGION Granulometry curve for each region of label image
%
%   GRANULO = imGranulo(IMG, ROILIST, GRTYPE, STRELSHAPE, SIZES)
%
%   Example
%     % Compute granulometric curve by ope,ing on rice image
%     img = imread('rice.png');
%     gr = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     plot(2*(1:20)+1, gr);
%
%
%   See also
%     imGranulo, granuloMeanSize
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


nSizes = length(strelSizes);

% number of labels in image
labels = unique(lbl(:));
labels(labels==0) = [];
nLabels = length(labels);

% initialize list of indices for each ROI to accelerate computation of
% granulometry curves
indList = cell(nLabels, 1);
for j = 1:nLabels
    indList{j} = find(lbl == labels(j));
end

% compute reference volume
vols0 = zeros(nLabels, 1);
for j = 1:nLabels
    vols0(j) = sum(img(indList{j}));
end

% allocate memory
vols = zeros(nLabels, nSizes + 1);
vols(:, 1) = vols0;

% iterate over strel sizes
for i = 1:nSizes
    radius = strelSizes(i);
    diam = 2 * radius + 1;
    
    % create current strel 
    switch lower(strelShape)
        case 'square'
            se = strel('square', diam);
        case {'octagon', 'diamond', 'ball'}
            se = strel(lower(strelShape), radius);
        case 'lineh'
            se = ones(1, diam);
        case 'linev'
            se = ones(diam, 1);
        otherwise
            error(['Could not process strel type: ' strelShape]);
    end
    
    % compute morphological operation
    switch lower(granuloType)
        case 'opening'
            img2 = imopen(img, se);
        case 'closing'
            img2 = imclose(img, se);
            
        otherwise
            error(['Could not process granulometry type: ' granuloType]);
    end
    
    % compute local volumes
    for j = 1:nLabels
        vols(j, i+1) = sum(img2(indList{j}));
    end
end

% compute granulometry curve by finit difference of local volumes
vols2 = bsxfun(@rdivide, bsxfun(@minus, vols, vols0) , vols(:, end) - vols0);
gr = 100 * diff(vols2')';


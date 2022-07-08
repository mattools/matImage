function [gr, diams, vols] = imGranuloByRegion(img, indList, granuloType, strelShape, strelSizes)
% Granulometry curve for each region of label image.
%
%   GRANULO = imGranulo(IMG, REGIONS, GRTYPE, STRELSHAPE, SIZES)
%   Computes the granulometry curves from gray levels image IMG within each
%   region specified by REGION. REGION can be either a label image, or a
%   cell array containing the linear indices corresponding to each region.
%
%   [GRANULO, DIAMS] = imGranulo(...)
%   Also returns the diameters of the structuring elements for each step of
%   the analysis.
%
%   Example
%     % Compute granulometric curve by opening on rice image
%     img = imread('rice.png');
%     gr = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     plot(2*(1:20)+1, gr);
%
%
%   See also
%     imGranulometry, imGranulo, granuloMeanSize
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRAE - Cepia Software Platform.


% if regions are specified as label image, need to convert to list of
% linear indices for each region
if isnumeric(indList)
    lbl = indList;
    
    % check inputs have same size
    if any(size(lbl) ~= size(img))
        error('matImage:imGranuloByRegion:InputArgumentError', ...
            'Gray level and label images must have same size');
    end
    
    % number of labels in image
    labels = unique(lbl(:));
    labels(labels==0) = [];
    nLabels = length(labels);
    
    % initialize list of indices for each ROI
    indList = cell(nLabels, 1);
    for j = 1:nLabels
        indList{j} = find(lbl == labels(j));
    end
else
    nLabels = length(indList);
end

% compute diameters
nSizes = length(strelSizes);
diams = 2 * strelSizes + 1;

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
        case 'disk'
            % do not use simplification, as it is not suitable for
            % granulometries
            se = strel('disk', radius, 0);
        case {'octagon', 'diamond', 'ball'}
            se = strel(lower(strelShape), radius);
        case 'lineh'
            se = ones(1, diam);
        case 'linev'
            se = ones(diam, 1);
        case 'lineu' % line in the direction of upper diagonal
            len = diam * sqrt(2);
            se = strel('line', len, 45);
        case 'lined' % line in the direction of down diagonal
            len = diam * sqrt(2);
            se = strel('line', len, 135);
        otherwise
            error(['Could not process strel type: ' strelShape]);
    end
    
    % compute morphological operation
    switch lower(granuloType)
        case 'opening'
            img2 = imopen(img, se);
        case 'closing'
            img2 = imclose(img, se);
        case 'dilation'
            img2 = imopen(img, se);
        case 'erosion'
            img2 = imopen(img, se);
            
        otherwise
            error(['Could not process granulometry type: ' granuloType]);
    end
    
    % compute local volumes
    for j = 1:nLabels
        vols(j, i+1) = sum(img2(indList{j}));
    end
end

% compute granulometry curve by finite difference of local volumes
vols2 = bsxfun(@rdivide, bsxfun(@minus, vols, vols0) , vols(:, end) - vols0);
gr = 100 * diff(vols2')';


function [gr vols] = imGranuloByRegion(img, lbl, granuloType, strelShape, strelSizes)
%IMGRANULO Compute granulometry curve of a given image
%
%   output = imGranulo(IMG, GRTYPE, STRELSHAPE, SIZES)
%
%   Example
%     % Compute granulometric curve by ope,ing on rice image
%     img = imread('rice.png');
%     gr = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     plot(2*(1:20)+1, gr);
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


nSizes = length(strelSizes);

% number of labels in image
labels = unique(lbl(:));
labels(labels==0) = [];
nLabels = length(labels);


% compute reference volume
vols0 = zeros(nLabels, 1);
for j = 1:nLabels
    vols0(j) = sum(img(lbl == labels(j)));
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
        vols(j, i+1) = sum(img2(lbl == labels(j)));
    end
end

% compute granulometry curve
vols2 = bsxfun(@rdivide, bsxfun(@minus, vols, vols0) , vols(:, end) - vols0);
gr = 100 * diff(vols2')';


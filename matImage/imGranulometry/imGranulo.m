function [gr vols] = imGranulo(img, granuloType, strelShape, strelSizes)
%IMGRANULO Compute granulometry curve of a given image
%
%   output = imGranulo(IMG, GRTYPE, STRELSHAPE, SIZES)
%
%   Example
%     % Compute granulometric curve by opening with square structuring
%     % element on rice image 
%     img = imread('rice.png');
%     gr = imGranulo(img, 'opening', 'square', 1:20);
%     % display as a function of strel diameter
%     plot(2*(1:20)+1, gr);
%     xlabel('Strel diameter (pixel)'); ylabel('Percentage of Variations');
%
%   See also
%     granuloMeanSize, imGranuloByRegion
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


nSizes = length(strelSizes);

% allocate memory
vols = zeros(1, nSizes + 1);

% initialize reference volume
vol0 = sum(img(:));
vols(1) = vol0;

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
    
    % compute local volume
    vols(i+1) = sum(img2(:));
end

% compute granulometry curve
vol0 = sum(img(:));
vols2 = (vols - vol0) / (vols(end) - vol0);
gr = 100 * diff(vols2);


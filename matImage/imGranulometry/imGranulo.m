function [gr, vols] = imGranulo(img, granuloType, strelShape, strelSizes, varargin)
%IMGRANULO Compute granulometry curve of a given image
%
%   GR = imGranulo(IMG, GRTYPE, STRELSHAPE, SIZES)
%   Computes the granulometry curve for input imag IMG, using the operation
%   GRTYPE, the shape of structuring element given by STRELSHAPE, and the
%     list of structuring element sizes given by SIZES.
%   IMG should be a 2D image (binary, grayscale or color)
%   GRTYPE can be one of {'opening', 'closing', 'erosion', 'dilation'}.
%   STRELSHAPE can be one of {'square', 'octagon', 'diamond', 'disk',
%     'lineh', 'linev'}.
%   SIZES are given as radius. Diameters of strels are obtained as 2*R+1.
%   The result GR is a 1-by-N array with as many columns as the number of
%     elements provided in SIZES array.
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
%     imGranulometry, granuloMeanSize, imGranuloByRegion
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.

% parse input arguments
verbose = false;
while length(varargin) > 1
    switch lower(varargin{1})
        case 'verbose', verbose = varargin{2};
        otherwise
            error(['Can not understand option: ' varargin{1}]);
    end
    varargin(1:2) = [];
end
    
% number of structuring element sizes
nSizes = length(strelSizes);

% allocate memory
vols = zeros(1, nSizes + 1);

% initialize reference volume
vol0 = sum(img(:));
vols(1) = vol0;

for i = 1:nSizes
    
    radius = strelSizes(i);
    diam = 2 * radius + 1;
    
    if verbose 
        fprintf('iter %d/%d, radius = %f\n', i, nSizes, radius);
    end
    
    % create current strel 
    switch lower(strelShape)
        case 'square'
            se = strel('square', diam);
        case {'octagon', 'diamond'}
            se = strel(lower(strelShape), radius);
        case 'disk'
            % do not use simplification, as it is not suitable for
            % granulometries
            se = strel('disk', radius, 0);
        case 'lineh'
            se = ones(1, diam);
        case 'linev'
            se = ones(diam, 1);
        otherwise
            error(['matImage:' mfilename], ...
                ['Could not process strel type: ' strelShape]);
    end
    
    % compute morphological operation
    switch lower(granuloType)
        case 'opening'
            img2 = imopen(img, se);
        case 'closing'
            img2 = imclose(img, se);
        case 'dilation'
            img2 = imdilate(img, se);
        case 'erosion'
            img2 = imerode(img, se);
            
        otherwise
            error(['matImage:' mfilename], ...
                ['Could not process granulometry type: ' granuloType]);
    end
    
    % compute local volume
    vols(i+1) = sum(img2(:));
end

% compute granulometry curve
vol0 = sum(img(:));
vols2 = (vols - vol0) / (vols(end) - vol0);
gr = 100 * diff(vols2);


function [gr, diams, vols] = imGranulo(img, granuloType, strelShape, strelSizes, varargin)
% Compute granulometry curve of a given image.
%
%   GR = imGranulo(IMG, GRTYPE, STRELSHAPE, SIZES)
%   Computes the granulometry curve for the input image IMG, using the
%   operation GRTYPE, the shape of structuring element given by STRELSHAPE,
%   and the list of structuring element sizes given by SIZES.
%   IMG should be a 2D image (binary or grayscale)
%   GRTYPE can be one of {'opening', 'closing', 'erosion', 'dilation'}.
%   STRELSHAPE can be one of {'square', 'octagon', 'diamond', 'disk',
%     'lineh', 'linev'}.
%   SIZES are given as radius. Diameters of strels are obtained as 2*R+1.
%   The result GR is a 1-by-N array with as many columns as the number of
%     elements provided in SIZES array.
%
%   [GR, DIAMS] = imGranulo(...)
%   Also returns the diameters of the structuring elements for each step of
%   the analysis. DIAMS is 1-by-N array with the same number of columns as
%   the GR array.
%
%   [GR, DIAMS, VOLS] = imGranulo(...)
%   Also returns the array of volume curves, corresponding to the sum of
%   gray levels at each step of the granulometry.
%
%   ... = imGranulo(..., 'verbose', TF)
%   If TF is true, displays the iteration steps on the command window.
%
%
%   Example
%     % Compute granulometric curve by opening on coins image (with two
%     % distinct sizes), using disk structuring element 
%     img = imread('coins.png');
%     Rmax = 50;
%     gr = imGranulo(img, 'opening', 'disk', 1:Rmax);
%     % display as a function of strel diameter
%     figure; plot(2*(1:Rmax)+1, gr); xlim([0 2*Rmax]);
%     xlabel('Strel diameter (pixel)'); ylabel('Percentage of Variations');
%     title('Granulometry on "coins" image');
%
%   See also
%     imGranulometry, granuloMeanSize, imGranuloByRegion
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2014-05-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRAE - Cepia Software Platform.


%% Parse input arguments

% check ROI
roi = true(size(img));
if ~isempty(varargin) 
    var1 = varargin{1};
    if islogical(var1) && all(size(var1) == size(img))
        roi = var1;
        varargin(1) = [];
    end
end

% check additional input arguments
verbose = false;
while length(varargin) > 1
    switch lower(varargin{1})
        case 'verbose', verbose = varargin{2};
        otherwise
            error(['Can not understand option: ' varargin{1}]);
    end
    varargin(1:2) = [];
end

% create structuring element factory, as a function handle that returns a
% strel object (or an array) from the radius of the strel.
if isa(strelShape, 'functionHandle')
    strelMaker = strelShape;
else
    % create factory from strel name
    switch lower(strelShape)
        case 'square'
            strelMaker = @(r) strel('square', 2*r+1);
        case {'octagon', 'diamond'}
            strelMaker = @(r) strel(lower(strelShape), r);
        case 'disk'
            % do not use simplification, as it is not suitable for
            % granulometries
            strelMaker = @(r) strel('disk', r, 0);
        case 'lineh'
            strelMaker = @(r) ones(1, 2*r+1);
        case 'linev'
            strelMaker = @(r) ones(2*r+1, 1);
        otherwise
            error(['matImage:' mfilename], ...
                ['Could not process strel type: ' strelShape]);
    end
end

% create funtion handle for morphological operation
if isa(granuloType, 'functionHandle')
    morphoOp = granuloType;
else
    switch lower(granuloType)
        case 'opening'
            morphoOp = @imopen;
        case 'closing'
            morphoOp = @imclose;
        case 'dilation'
            morphoOp = @imdilate;
        case 'erosion'
            morphoOp = @imerode;
            
        otherwise
            error(['matImage:' mfilename], ...
                ['Could not process granulometry type: ' granuloType]);
    end
end


%% Initialize

% number of structuring element sizes
nSizes = length(strelSizes);

% compute the associated diameter list (for output)
diams = 2 * strelSizes + 1;

% allocate memory for volume curves (sum of gray levels)
vols = zeros(1, nSizes + 1);

% initialize reference volume
vol0 = sum(img(roi));
vols(1) = vol0;


%% Iteration over structuring element sizes

% iterate
for i = 1:nSizes
    % size of strel for current iteration
    radius = strelSizes(i);
    
    if verbose 
        fprintf('iter %2d/%d, radius = %f\n', i, nSizes, radius);
    end
    
    % create current strel 
    se = strelMaker(radius);
    
    % compute morphological operation
    img2 = morphoOp(img, se);
    
    % sum of gray levels within each region
    vols(i+1) = sum(img2(roi));
end

% compute granulometry curve
vols2 = (vols - vol0) / (vols(end) - vol0);
gr = 100 * diff(vols2);


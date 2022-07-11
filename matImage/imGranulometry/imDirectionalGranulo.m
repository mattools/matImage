function [res, orientList] = imDirectionalGranulo(img, nOrients, grType, LMax, varargin)
% Directional granulometries for several orientations.
%
%   Compute typical size of bright or dark structures within images by
%   performing gray-level granulometries with linear elements with various
%   orientations. 
%   The function "imOrientedGranulo" is an alternative approach based on
%   rotations of the original image.
%
%   Usage:
%   RES = imDirectionalGranulo(IMG, NORIENT, GRTYPE, LMAX)
%
%   Input parameters:
%   IMG:       The input 2D gray-level image.
%   NORIENT:   The number of orientations to consider.
%   GRTYPE:    The type of granulometry. Can be one of 'opening', 'closing',
%              'dilation', 'erosion', or a function handle to a function
%              that accepts an image and a structuring element. 
%   LMAX:      The maximum size of line SE. Structuring elements use a
%              number of pixels such that equivalent length of the line is
%              as close as possible to the LMAX value.
%
%   Example
%     imDirectionalGranulo
%
%   See also
%     imGranulometry, orientedLineStrel, imOrientedGranulo
%
%   Reference
%   The methodology is described in the following article:
%   "Oriented granulometry to quantify fibre orientation distributions in
%   synthetic and plant fibre composite preforms", by V. Gager, D. Legland,
%   A. Bourmaud, A. Le Duigou, F. Pierre, K. Behlouli and C. Baley. (2020),
%   Industrial Crops and Products 152, p. 112548. 
%   doi: https://doi.org/10.1016/j.indcrop.2020.112548
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2018-12-18,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.


%% Parse input arguments

% create funtion handle for morphological operation
if isa(grType, 'functionHandle')
    morphoOp = grType;
else
    switch lower(grType)
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
                ['Could not process granulometry type: ' grType]);
    end
end


%% Initialization

dim = size(img);

% create the list of angles
orientList = linspace(0, 180, nOrients+1);
orientList(end) = [];

% create the list of line diameters 
% (consider only odd values to ensure symetry of the strel)
diamList = 1:2:LMax;
nSteps = length(diamList);

% allocate memory for global result
res = zeros([dim nOrients], 'double');
    
% allocate memory for intermediate results
resOp = zeros([dim nSteps+1], 'double');

% image for normalizing granulometry curves
refImage = double(img);
refImage(img <= 0) = 1;


%% Main processing 

% iterate over orientations
for iOrient = 1:nOrients
    disp(sprintf('Orient: %d/%d', iOrient, nOrients)); %#ok<DSPS>
  
    % angles from horizontal, in degrees, in CW order 
    % (correspond to CCW when visualizing image results)
    theta = -orientList(iOrient);

    % iterate over granulometry steps to create a stack of results
    for i = 1:nSteps
        se = orientedLineStrel(diamList(i), theta);
        resOp(:,:,i) = morphoOp(img, se);
    end
    
    % compute granulometry curve for each pixel
    gr = bsxfun(@rdivide, cat(3, zeros(dim), diff(-resOp, 1, 3)), refImage) * 100;

    % compute mean size for each position
    meanSizes = granuloMeanSize(reshape(gr, [numel(img) nSteps+1]), [diamList LMax]);
    
    % stores the mean size for the current orientation
    res(:,:,iOrient) = reshape(meanSizes, size(img));
end


function [res, orientList] = imDirectionalGranulo(img, nOrients, grType, LMax, varargin)
% Directional granulometries for several orientations.
%
%   Usage:
%   RES = imDirectionalGranulo(IMG, NORIENT, GRTYPE, LMAX)
%
%   Input parameters:
%   IMG:     input image, 2D gray-level
%   NORIENT: the number of orientations to consider
%   GRTYPE:  the type of granulometry to perform. Can be one of 'opening'
%            or 'closing'.
%   LMAX:    the maximum size of the linear structuring elements used for
%            computing granulometries. Larger lines can be more precise for 
%            computing equivalent size, but requires more computation time.
%
%
%   Example
%     imDirectionalGranulo
%
%   See also
%     imGranulo, orientedLineStrel
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


%% Initialization

% retrieve input image size
dim = size(img);
if length(dim) ~= 2
    error('Requires a 2D grayscale or intensity image as first input');
end

% create the list of angles
orientList = linspace(0, 180, nOrients+1);
orientList(end) = [];

% create the list of line diameters 
% (consider only odd values to ensure symetry of the strel)
diamList = 1:2:LMax;
nSteps = length(diamList);

% allocate memory for global result
res = zeros([dim nOrients], 'double');
    
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

    % allocate memory for intermediate results
    % (requires double for computation of diff)
    resOp = zeros([dim nSteps+1], 'double');
    resOp(:,:,1) = img;

    % iterate over structuring element lengths to create a stack of results
    if strcmpi(grType, 'opening')
        for i = 1:nSteps
            se = orientedLineStrel(diamList(i), theta);
            resOp(:,:,i+1) = imopen(img, se);
        end
    elseif strcmpi(grType, 'closing')
        for i = 1:nSteps
            se = orientedLineStrel(diamList(i), theta);
            resOp(:,:,i+1) = imclose(img, se);
        end
    elseif strcmpi(grType, 'dilation')
        for i = 1:nSteps
            se = orientedLineStrel(diamList(i), theta);
            resOp(:,:,i+1) = imdilate(img, se);
        end
    elseif strcmpi(grType, 'erosion')
        for i = 1:nSteps
            se = orientedLineStrel(diamList(i), theta);
            resOp(:,:,i+1) = imerode(img, se);
        end
    else
        error('Unknown operation type: %s', grType);
    end
    
    % compute granulometry curve for each pixel
    if ismember(lower(grType), {'opening', 'erosion'})
        % values are decreasing over strel length, so we need to invert the
        % difference
        gr = bsxfun(@rdivide, diff(-resOp, 1, 3), refImage) * 100;
    else
        gr = bsxfun(@rdivide, diff(resOp, 1, 3), refImage) * 100;
    end
    
    % compute mean size for each position
    meanSizes = granuloMeanSize(reshape(gr, [numel(img) nSteps]), diamList);
    
    % stores the mean size for the current orientation
    res(:,:,iOrient) = reshape(meanSizes, size(img));
end


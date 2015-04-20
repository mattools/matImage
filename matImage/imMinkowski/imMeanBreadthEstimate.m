function [breadth, labels] = imMeanBreadthEstimate(img, varargin)
%IMMEANBREADTHESTIMATE Estimate mean breadth of a binary structure
%
%   BREADTH = imMeanBreadthEstimate(IMG)
%   The aim of this function is to be called by the "imMeanBreadthDensity"
%   function, for providing an estimate of mean breadth density within a
%   representative volume of interest.
%
%   BREADTH = imMeanBreadthEstimate(IMG, RESOL)
%   Also specifies the resolution of input image.
%
%   BREADTH = imMeanBreadthEstimate(IMG, RESOL, NDIRS)
%   Also specifies the number of directions used for computation. Can be
%   either 3 or 13 (the default).
%
%   Example
%   imMeanBreadthEstimate
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-20,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

%% Basic error checking

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % identify the labels in image
    labels = imFindLabels(img);
    
    % allocate result array
    nLabels = length(labels);
    breadth = zeros(nLabels, 1);
    
    % compute bounding box of each label
    boxes = imBoundingBox(img);
    
    % Compute mean breadth of each label considered as binary image
    % The computation is performed on a subset of the image for reducing
    % memory footprint.
    for i = 1:nLabels
        label = labels(i);
        
        % convert bounding box to image extent, in x, y and z directions
        box = boxes(i,:);
        i0 = ceil(box([3 1 5]));
        i1 = floor(box([4 2 6]));

        % crop image of current label
        bin = img(i0(1):i1(1), i0(2):i1(2), i0(3):i1(3)) == label;
        breadth(i) = imMeanBreadthEstimate(bin, varargin{:});
    end

    return;
end

%% Process input arguments

% in case of binary image, compute only one label...
labels = 1;

% default number of directions
nDirs = 3;

% default image resolution
delta = [1 1 1];

% Process user input arguments
while ~isempty(varargin)
    var = varargin{1};
    if ~isnumeric(var)
        error('option should be numeric');
    end
    
    % option is either connectivity or resolution
    if isscalar(var)
        nDirs = var;
    else
        delta = var;
    end
    varargin(1) = [];
end


%% Compute mean breadth estimate using Look-up-Table

histo = imBinaryConfigHisto(img);

lut = imMeanBreadthLut(delta, nDirs);

breadth = sum(histo .* lut);


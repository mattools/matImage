function [len labels] = imLengthDensity(img, varargin)
%Estimate length density of a binary 1D structure using edge correction
%
%   LEN = imLengthDensity(IMG);
%   When IMG is a binary image, returns the total length of the structure,
%   equal to the number of pixels.
%   This function is intended to be used for debugging purpose.
%   
%   [LEN LABELS] = imLengthDensity(LBL, ...);
%   When LBL is a label image, returns the total length of each label
%   different from 0. Returns also the set of unique values in LBL.
%
%   
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY

% check image dimension
if ndims(img)>2 || min(size(img))>1
    error('first argument should be a 1D image');
end

% in case of a label image, return a vector with a set of results
labels = 1;
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    
    len = zeros(length(labels), 1);
    for i=1:length(labels)
        len(i) = imLengthDensity(img==labels(i), varargin{:});
    end
    return;
end

% Total length of stucture is equal to the number of vertices multiplied by
% the resolution, using edge correction
len = sum(img(:)) / numel(img); 

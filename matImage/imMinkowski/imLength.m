function [len, labels] = imLength(img, varargin)
% Compute total length of a binary 1D structure
%
%   LEN = imLength(IMG);
%   When IMG is a binary image, returns the total length of the structure,
%   equal to the number of pixels.
%   This function is intended to be used for debugging purpose.
%   
%   LEN = imLength(IMG, RESOL);
%   Compute the length in user unit, by multiplying length in pixel by the
%   resolution.
%
%   [LEN LABELS] = imLength(LBL, ...);
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
if ndims(img)>2 || min(size(img))>1 %#ok<ISMAT>
    error('first argument should be a 1D image');
end

% in case of a label image, return a vector with a set of results
labels = 1;
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    
    len = zeros(length(labels), 1);
    for i=1:length(labels)
        len(i) = imLength(img==labels(i), varargin{:});
    end
    return;
end

% extract resolution if present
resol = 1;
if ~isempty(varargin)
    resol = varargin{1};
end

% Total length of stucture is equal to the number of vertices multiplied by
% the resolution
len = sum(img(:)) * resol;

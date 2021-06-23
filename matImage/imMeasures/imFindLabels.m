function labels = imFindLabels(img)
% Find unique labels within a label image.
%
%   LABELS = imFindLabels(IMG)
%   Finds the unique labels in the label image IMG. The result can be
%   obtained using the "unique" function, but a special processing is added
%   to avoid using too much memory.
%
%   Example
%   imFindLabels
%
%   See also
%     imCentroid, imBoundingBox, imFeretDiameter, imOrientedBox, imRAG

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2013-07-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% Switch determination of labels depending on data type of image array
if islogical(img)
    % in case of logical array, the only label is 1.
    labels = 1;
    
elseif isfloat(img)
    % for floating point values, use the 'unique' function
    labels = unique(img(:));
    labels(labels==0) = [];
    
elseif isstruct(img) && isfield(img, 'NumObjects')
    % if the array was obtained from a connected-components algorithms, the
    % result is stored on the resulting struct
    labels = (1:img.NumObjects)';
    
elseif isinteger(img)
    % in the case of integer array, switch to a memory-frugal algorithm
    maxLabel = double(max(img(:)));
    labels = zeros(maxLabel, 1);
    
    nLabels = 0;
    
    for i = 1:maxLabel
        if any(img(:) == i)
            nLabels = nLabels + 1;
            labels(nLabels) = i;
        end
    end
    
    labels = labels(1:nLabels);
    
else
    error('MatImage:imMeasures:imFindLabels', ...
        'Can not process images with datatype: %s', class(img));
end

function labels = imFindLabels(img)
%IMFINDLABELS  Find unique labels in a label image
%
%   LABELS = imFindLabels(IMG)
%   Finds the unique labels in the label image IMG. The result can be
%   obtained using the unique function, but a special processing is added
%   to avoid using too much memory.
%
%   Example
%   imFindLabels
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2013-07-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

if islogical(img)
    labels = 1;
    return;
end

if isfloat(img)
    labels = unique(img(:));
    labels(labels==0) = [];
    return;
end

if isstruct(img) && isfield(img, 'NumObjects')
    labels = (1:img.NumObjects)';
    return;
end

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
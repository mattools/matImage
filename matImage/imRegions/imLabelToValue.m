function map = imLabelToValue(lbl, values, varargin)
%IMLABELTOVALUE Convert label image to parametric map
%
%   MAP = imLabelToValue(LBL, VALUES)
%   Convert label image LBL to a parametric map MAP, that contains for each
%   pixel the value corresponding to the value indexed by the label, or the
%   value NaN if label is zero. More formally:
%   relationship:
%     MAP(i,j) <- VALUES(LBL(i,j)) if LBL(i,j)>0
%     MAP(i,j) <- NaN              otherwise
%
%
%   MAP = imLabelToValue(LBL, VALUES, BG)
%   Also specifies the output value.
%
%
%   Example
%     % read rice image, apply segmentation, and display map of semi major
%     % axis length
%     img = imread('rice.png');
%     imth = imtophat(img, ones(50, 50)); % remove background
%     lbl = bwlabel(imAreaOpening(imth > 50, 5), 4); % labeling
%     props = regionprops(lbl, {'MajorAxisLength'}); % measure value
%     map = imLabelToValue(lbl, [props.MajorAxisLength], 0); % compute map
%     figure; imshow(map, [], 'colormap', [1 1 1 ; jet(256)]); % display
%
%   See also
%     imFilters, imLUT, label2rgb, label2rgb3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-09-15,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

% eventually extract background value
bgValue = NaN;
if ~isempty(varargin)
    bgValue = varargin{1};
end

% check validity of label image
if max(lbl(:)) > length(values)
    error('matImage:imLabelToValue:InedxOutOfBounds', ...
        'max label index exceeds number of values');
end

% allocate memory
map = bgValue * ones(size(lbl), class(values));

% apply mapping
map(lbl>0) = values(lbl(lbl>0));

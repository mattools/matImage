function bin = imAttributeOpening(lbl, att, op, val, varargin)
%IMATTRIBUTEOPENING Filter regions on a size or shape criterium
%
%   BIN = imAttributeOpening(IMG, ATT, OP, VAL)
%   Applies attribute opening on the binary or label image IMG. 
%
%   Example
%   % Apply area opening on text image
%     img = imread('text.png');
%     res = imAttributeOpening(img, 'Area', @gt, 10);
%     imshow(res);
%
%   See also
%     imAreaOpening, imLargestRegion, imKillBorders
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% in case of binary image, compute labels
if islogical(lbl)
    lbl = labelmatrix(bwconncomp(lbl, varargin{:}));
end

% compute attribute for each label
props = regionprops(lbl, att);
props = [props.(att)];

% apply attribute filtering
res = feval(op, props, val);

% convert to indices
inds = find(res);

% convert result to binary image
bin = ismember(lbl, inds);

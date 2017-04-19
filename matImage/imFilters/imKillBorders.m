function lbl = imKillBorders(lbl, varargin)
%IMKILLBORDERS Remove regions on the border of an image
%
%   Replaced by 'imKillBorerRegions'
%
%   LBL2 = imKillBorders(LBL);
%   LBL is a labeled image, or a binary image. Image can be 2D or 3D.
%   In the case of binary image, the image is labeled using 4-adjacency for
%   2D images, or 6-adjacency for 3D images.
%   The regions which touch the border of the image are removed, and the
%   remaining regions are re-labeled. Result has the same class than the
%   original image.
%
%   LBL2 = imKillBorders(LBL, BORDERS);
%   Specifies which borders need to be removed. BORDERS is a cell array of
%   strings, with each string corresponding to a border:
%   'left':     all pixels with x=1
%   'right':    all pixels with x=last
%   'top':      all pixels with y=1
%   'bottom':   all pixels with y=last
%
%   For 3D images, 2 additonal borders can be removed:
%   'front':    all pixels with z=1
%   'back':     all pixels with z=last
%
%   LBL2 = imKillBorders(LBL, BORDERS, RELABEL);
%   where RELABEL is a logical, specifies wheter remaining regions should
%   be relabeled or not (default is TRUE).
%
%   Example
%     img = imread('rice.png');
%     bin = imOtsuThreshold(imtophat(img, ones(30, 30)));
%     bin2 = imKillBorders(bin);
%     imshow(bin2);
% 
%   See also:
%   bwmorph, imreconstruct, imAreaOpening, imLargestRegion
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 23/04/2007
%

% HISTORY :
%   19/07/2007 add possibility to specify borders
%   07/08/2007 relabeling is now optional
%   01/02/2008 return binImg image if input is binImg
%   25/05/2011 rename from removeBorderRegions to imKillBorders, cleanup


%% Process inputs

warning('matImage:imKillBorders:deprecated', ...
    'function imKillBorders is obsolete, use imKillBorderRegions instead');

% default values
binImg  = false;
relabel = true;

% If image is binImg, convert to labeled image
if islogical(lbl)
    binImg = true;
    relabel = false;
    if ndims(lbl) == 2 %#ok<ISMAT>
        lbl = bwlabel(lbl, 4);
    elseif ndims(lbl) == 3
        lbl = bwlabeln(lbl, 6);
    end
end

% check if relabel flag is present
if ~isempty(varargin)
    if islogical(varargin{end})
        relabel = varargin{end};
        varargin(end) = [];
    end
end


%% Build binary mask

% find borders to remove
borders = {'top', 'bottom', 'left', 'right'};
if ~isempty(varargin)
    if iscell(varargin{1})
        borders = varargin{1};
    else
        borders = varargin;
    end
end

% create mask for borders
mask = false(size(lbl));
if ndims(lbl) == 2 %#ok<ISMAT>
    for i = 1:length(borders)
        switch lower(borders{i})
            case 'left'
                mask(:,1) = true;
            case 'right'
                mask(:,end) = true;
            case 'top'
                mask(1,:) = true;
            case 'bottom'
                mask(end,:) = true;
        end
    end
else
    for i = 1:length(borders)
        switch lower(borders{i})
            case 'left'
                mask(:,1,:) = true;
            case 'right'
                mask(:,end,:) = true;
            case 'top'
                mask(1,:,:) = true;
            case 'bottom'
                mask(end,:,:) = true;
            case 'front'
                mask(:,:,1) = true;
            case 'back'
                mask(:,:,end) = true;
        end
    end
end


%% Main processing

% find labels of regions touching borders
lbl2 = unique(lbl(mask));

% remove label '0', which corresponds to background
if lbl2(1) == 0 
    lbl2 = lbl2(2:length(lbl2));
end

% set labels of border regions to 0
indices = ismember(lbl, lbl2);
lbl(indices) = 0;


%% Optional relabeling

% Eventually relabel remaining regions by shifting labels
if relabel && ~isempty(lbl2)
    % For remaining regions, shift the labels
    for i = 1:length(lbl2)-1
        indices = lbl > lbl2(i) & lbl <= lbl2(i+1);
        lbl(indices) = imsubtract(lbl(indices), i);
    end

    % Shift labels for regions whose index is greater than last index of LBL2.
    indices = lbl > lbl2(length(lbl2));
    lbl(indices) = imsubtract(lbl(indices), length(lbl2));
end

% convert to binImg image if needed
if binImg
    lbl = lbl > 0;
end

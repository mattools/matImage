function varargout = imWeightedHistogram(img, weights, varargin)
% Weighted histogram of 2D/3D grayscale image.
%
%   H = imWeightedHistogram(IMG, WEIGHTS)
%   Compute the weighted histogram of the values within the image IMG,
%   using the weights specified in the WEIGHTS array. Both IMG and WEIGHTS
%   must have the same size.
%
%   [H, C] = imWeightedHistogram(...)
%   Also returns the bin centers into the array C.
%
%
%   Example
%     % compute histogram weighted by distance to middle y line
%     img = imread('rice.png');
%     [x, y] = meshgrid(1:size(img, 2), 1:size(img,1));
%     y2 = 128 - abs(y - 128);
%     [histo, binCenters] = imWeightedHistogram(img, y2);
%     figure; 
%     subplot(211); imHistogram(img); title('Raw Histogram');
%     subplot(212); imWeightedHistogram(img, y2); title('Weighted Histogram');
%
%   See also
%     imHistogram, imhist, hist, imQuantile
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2018-07-20,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRAE - Cepia Software Platform.

% default number of histogram bins
N = 256;

% physical dimension of image
imgSize = size(img);

% compute intensity bounds, based either on type or on image data
if isinteger(img)
    type = class(img);
    minimg = intmin(type);
    maximg = intmax(type);
else
    minimg = min(img(:));
    maximg = max(img(:));
end

%% Process input arguments

% process each argument
while ~isempty(varargin)
    var = varargin{1};
    
    if isempty(var)
        % if an empty variable is given, assumes gray level bounds must be
        % recomputed from image values
        minimg = min(img(:));
        maximg = max(img(:));
        
    elseif isnumeric(var) && length(var) == 1
        % argument is number of bins
        N = var;
        
    elseif isnumeric(var) && length(var) == 2
        % argument is min and max of values to compute
        minimg = var(1);
        maximg = var(2);
        
    elseif islogical(var)
        % argument is a ROI
        roi = var;
        
        % compute roi physical size
        roiSize = size(roi);
        if colorImage && length(roiSize) > length(imgSize)
            roiSize(3) = [];
        end
        
        % check roi size
        if any(roiSize ~= imgSize)
            error('ROI and image must have same size');
        end
        
    elseif isnumeric(var)
        % argument is value for histogram bins
        x = var;
        minimg = var(1);
        maximg = var(end);
        N = length(x);
    end
    
    % remove processed argument from the list
    varargin(1) = [];
end

% compute bin centers if they were not specified
if ~exist('x', 'var')
    x = linspace(double(minimg), double(maximg), N);
end


%% Main processing 

h = zeros(size(x));

for i = 1:numel(img)
    value = img(i);
    % index of bin with closest value
    [tmp, ind] = min((double(value) - x).^2); %#ok<ASGLU>
    h(ind) = h(ind) + weights(i);
end

h = h / sum(weights(:));


%% Process output arguments

% In case of no output argument, display the histogram
if nargout == 0
    % display histogram in current axis
    bar(gca, x, h, 'hist');
    % use jet color to avoid gray display
    colormap jet;
    
    % setup histogram bounds
    if maximg > minimg
        xlim([minimg maximg]);
    end
    
elseif nargout == 1
    % return histogram
    varargout = {h};
elseif nargout == 2
    % return histogram and x placement
    varargout = {h, x};
end


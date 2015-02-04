function [gmin, gmax] = imGrayscaleExtent(img, varargin)
%IMGRAYSCALEEXTENT Grayscale extent of an image
%
%   [GMIN, GMAX] = imGrayscaleExtent(IMG)
%   Compute grayscale extent of a grayscale image.
%
%   [GMIN, GMAX] = imGrayscaleExtent(IMG, ALPHA)
%   Compute grayscale extent of the image, such that ALPHA pixel lie out of
%   the range. ALPHA can be a scalar, or a pair. If ALPHA is scalar,
%   ALPHA/2 percent will be ignored on each side of the distribution.
%
%   LIMITS = imGrayscaleExtent(...)
%   Packs the result into a single row vector with 2 elements.
%
%
%   Example
%   % compute for cameraman
%     img = imread('cameraman.tif');
%     imGrayscaleExtent(img)
%     ans =
%         7   253
%   
%   % compute for image 'pout', and adjust grayscale range (same values as
%   % matlab help for stretchlim).
%     img = imread('pout.tif');
%     bounds = imGrayscaleExtent(img, .02);
%     img2 = imRescale(img, bounds);
%     figure;
%     subplot(121);imshow(img);
%     subplot(122);imshow(img2);
%
%   See also
%   imRescale, imadjust, stretchlim
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-11-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% compute min and max of image
gmin = min(img(isfinite(img)));
gmax = max(img(isfinite(img)));
    
if ~isempty(varargin)
    % If alpha is specified, we compute the percentage of pixels outside of
    % the range
    alpha = varargin{1};
    if length(alpha)==1
        alpha = [alpha alpha]/2;
    end
    
    % compute image histogram
    % compute histogram
    x = linspace(double(gmin), double(gmax), 10000);
    h = hist(double(img(isfinite(img))), x);
    
    % special case of images with black background: do not take into
    % account the 0-values
    if h(1) > sum(h)*.2
        x = x(2:end);
        h = h(2:end);
    end
    
    % normalisation of grayscale distribution function
    cumh    = cumsum(h);
    cdf     = cumh / cumh(end);
    
    % find indices of extreme values
    ind1    = find(cdf >= alpha(1),   1, 'first');
    ind2    = find(cdf <= 1-alpha(2), 1, 'last');
    
    % compute grayscale extent
    gmin    = floor(x(ind1));
    gmax    = ceil(x(ind2));
end

% small checkup on output values
if abs(gmax - gmin) < 1e-12
    warning('imGrayscaleExtent:ExtentTooSmall', ...
        'Could not determine grayscale extent from data');
    gmin = 0;
    gmax = 1;
end

% format output argument if needed
if nargout <= 1
    gmin = [gmin gmax];
end

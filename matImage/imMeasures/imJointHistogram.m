function res = imJointHistogram(img1, img2, varargin)
% Joint histogram of two images.
%
%   HIST = imJointHistogram(IMG1, IMG2)
%   IMG1 and IMG2 are two images with the same size, HIST is a 256*256
%   array containing number of pixels for each combination of values.
%
%   HIST = imJointHistogram(IMG1, IMG2, NBINS)
%   Also specify the number of bins of the histogram. The result is a
%   square matrix with NBINS rows and NBINS columns. Default is 256.
%
%   HIST = imJointHistogram(IMG1, IMG2, NBINS1, NBINS2)
%   Specify different number of bins for each image.
%
%   HIST = imJointHistogram(IMG1, IMG2, BINS1, BINS2)
%   Directly specify the bins used for each image. The result is a matrix
%   with length(BINS1) rows and length(BINS2) columns. Default bins are
%   computed from 0 to maximal values (either maximal integer value for
%   integer images, or maximal image value for floating point images).
%   Image values that are below the first element of the corresponding bin
%   are dropped during the computation.
%
%   Works for 2D and 3D images, for grayscales (integer) and for intensity
%   (float) images.
%
%   Example
%     img = imread('cameraman.tif');
%     img2 = img(2:end, 3:end);
%     img2(256, 256) = 0;
%     h = imJointHistogram(img, img2);
%     imshow(h2, []); colormap([0 0 0;jet]);
%     colormap jet
%
%   See also
%   imhist, imHistogram, imJointEntropy
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-12-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRAE - Cepia Software Platform.

%   HISTORY
%   2010-08-24 add support for 16 bits and double images, for user-defined
%       histogram bins, and update doc


% check input dimensions
if sum(size(img1) ~= size(img2)) > 0
    error('Inputs must have same size');
end

% default is no ROI (use the whole pixels in images)
roi = ones(size(img1));

% default number of intervals for computing values
q1 = 256;
q2 = 256;

% compute maximum gray values of each image
if isinteger(img1)
    maxVal1 = intmax(class(img1));
else
    maxVal1 = max(img1(:));
end
if isinteger(img2)
    maxVal2 = intmax(class(img2));
else
    maxVal2 = max(img2(:));
end

% init to empty array
vals1 = [];

% check if a ROI is specified
if ~isempty(varargin) && sum(size(img1) ~= size(varargin{1})) == 0
    roi = varargin{1};
    varargin(1) = [];
end

% extract user-specified number of bins, or bin values
if length(varargin)==1
    var = varargin{1};
    if length(var)==1
        q1 = var;
        q2 = var;
    else
        vals1 = var;
        vals2 = var;
    end
elseif length(varargin)==2
    var1 = varargin{1};
    var2 = varargin{2};
    if length(var1)==1 && length(var2)==1
        q1 = var1;
        q2 = var2;
    else
        vals1 = var1;
        vals2 = var2;
    end
end

% compute grayscale limits if needed
if isempty(vals1)
    vals1 = linspace(0, double(maxVal1)+1, q1+1);
    vals2 = linspace(0, double(maxVal2)+1, q2+1);
    vals1(end) = [];
    vals2(end) = [];
end

% initialize result array
res = zeros(length(vals1), length(vals2));

% linear indices of pixels to consider
inds = find(roi);

if q1==256 && q2==256 && maxVal1==255 && maxVal2 == 255
    % Standard case: iterate over all pixels, use true value
    for i = 1:length(inds)
        % get each value, and convert to index
        v1 = img1(inds(i)) + 1;
        v2 = img2(inds(i)) + 1;
        
        % increment corresponding histogram
        res(v1, v2) = res(v1, v2)+1;
    end
else
    for i = 1:length(inds)
        % get each value, and convert to index
        v1 = find(img1(inds(i))>=vals1, 1, 'last');
        v2 = find(img2(inds(i))>=vals2, 1, 'last');

        % increment corresponding histogram
        res(v1, v2) = res(v1, v2)+1;
    end
end

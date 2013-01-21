function histo = imColorHistogram(img, varargin)
%IMCOLORHISTOGRAM Plot 3D histogram of a color image
%
%   imColorHistogram(IMG);
%   Displays the color histogram of the given image. Input image must be
%   color.
%
%   imColorHistogram(IMG, NBINS);
%   Specifies a different number of bins for each channel. Default number
%   is 8. Using a number of bins greater than 20 often results in slow
%   display.
%
%   HISTO = imColorHistogram(IMG)
%   Returns the color histogram as a 3D array.
%
%
%   Example
%   img = imread('peppers.png');
%   figure;
%   imColorHistogram(img);
%
%   % Plot Color histogram of pear image
%     img = imread('pears.png');
%     histo = imColorHistogram(img);
%     
%   See also
%   imHistogram
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-01-10,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

nBins = 16;
if ~isempty(varargin)
    nBins = varargin{1};
end

histo = zeros(nBins, nBins, nBins);

% The coefficient to convert from [0 255] to [0 nBins-1]
ratio = nBins / 256;

if ndims(img) == 3
    % Process planar image
    for i = 1:size(img, 1)
        for j = 1:size(img, 2);
            ir = floor(double(img(i, j, 1)) * ratio) + 1;
            ig = floor(double(img(i, j, 2)) * ratio) + 1;
            ib = floor(double(img(i, j, 3)) * ratio) + 1;

            histo(ir, ig, ib) = histo(ir, ig, ib) + 1;
        end
    end

elseif ndims(img) == 4
    
    % Process 3D image
    for i = 1:size(img, 1)
        for j = 1:size(img, 2);
            for k = 1:size(img, 4);
                ir = floor(double(img(i, j, 1, k)) * ratio) + 1;
                ig = floor(double(img(i, j, 2, k)) * ratio) + 1;
                ib = floor(double(img(i, j, 3, k)) * ratio) + 1;
                
                histo(ir, ig, ib) = histo(ir, ig, ib) + 1;
            end
        end
    end
end

if nargout == 0
    plotColorHistogram(histo)
end


function plotColorHistogram(histo)

% compute RGB grid
lr = (.5:size(histo,1)-.5) / size(histo, 1);
lg = (.5:size(histo,2)-.5) / size(histo, 2);
lb = (.5:size(histo,3)-.5) / size(histo, 3);
[g r b] = meshgrid(lg, lr, lb);

% extract colors
rgb = [r(:) g(:) b(:)];

% get values greater than given threshold
vals = histo(:);
inds = find(vals > 0);
vals2 = vals(inds) / max(vals(:));

% scales coordinates betwenn 0 and 255
r2 = r(inds) * 256;
g2 = g(inds) * 256;
b2 = b(inds) * 256;
rgb2 = rgb(inds, :);

% scatter plot of each color
figure; 
% scatter3(r2, g2, b2, vals2*1000, 'filled', 'CData', rgb2);
scatter3(r2, g2, b2, 20, 'filled', 'Marker', 'o', 'CData', rgb2);
 
% display settings
axis([0 255 0 255 0 255]);

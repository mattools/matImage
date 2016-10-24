function [res, index] = imKirschFilter(img)
%IMKIRSCHFILTER Extract image edges using Kirsch directional filters
%
%   output = imKirschFilter(input)
%
%   Example
%     img = imread('rice.png');
%     imgf = imKirschFilter(img);
%     figure; imshow(imgf);
%
%   See also
%     imRobinsonFilter, imGradientFilter
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-05-06,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

g1 = [ 5  5  5 ; -3 0 -3 ; -3 -3 -3];
g2 = [ 5  5 -3 ;  5 0 -3 ; -3 -3 -3];
g3 = [ 5 -3 -3 ;  5 0 -3 ;  5 -3 -3];
g4 = [-3 -3 -3 ;  5 0 -3 ;  5  5 -3];
g5 = [-3 -3 -3 ; -3 0 -3 ;  5  5  5];
g6 = [-3 -3 -3 ; -3 0  5 ; -3  5  5];
g7 = [-3 -3  5 ; -3 0  5 ; -3 -3  5];
g8 = [-3  5  5 ; -3 0  5 ; -3 -3 -3];

kernels = {g1, g2, g3, g4, g5, g6, g7, g8};

res = zeros(size(img), class(img));
index = zeros(size(img), 'int8');
for i = 1:8
    imgf = imfilter(img, kernels{i}, 'replicate');
    inds = imgf >= img;
    res(inds) = imgf(inds);
    index(inds) = i;
end

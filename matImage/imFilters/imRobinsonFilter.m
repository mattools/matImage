function [res, index] = imRobinsonFilter(img)
%IMROBINSONFILTER Extract image edges using Robinson directional filters
%
%   output = imRobinsonFilter(input)
%
%   Example
%     img = imread('rice.png');
%     imgf = imRobinsonFilter(img);
%     figure; imshow(imgf);
%
%   See also
%     imKirschFilter, imGradientFilter
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-05-06,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

g1 = [ 1  2  1 ;  0 0  0 ; -1 -2 -1]; % N
g2 = [ 2  1  0 ;  1 0 -1 ;  0 -1 -2]; % NE
g3 = [ 1  0 -1 ;  2 0 -2 ;  1  0 -1]; % E
g4 = [ 0 -1 -2 ;  1 0 -1 ;  2  1  0]; % SE
g5 = [-1 -2 -1 ;  0 0  0 ;  1  2  1]; % S
g6 = [-2 -1  0 ; -1 0  1 ;  0  1  2]; % SW
g7 = [-1  0  1 ; -2 0  2 ; -1  0  1]; % W
g8 = [ 0  1  2 ; -1 0  1 ; -2 -1  0]; % NW

kernels = {g1, g2, g3, g4, g5, g6, g7, g8};

res = zeros(size(img), class(img)); %#ok<ZEROLIKE>
index = zeros(size(img), 'int8');
for i = 1:8
    imgf = imfilter(img, kernels{i}, 'replicate');
    inds = imgf >= img;
    res(inds) = imgf(inds);
    index(inds) = i;
end

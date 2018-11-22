%DEMOIMBOXFILTER  One-line description here, please.
%
%   output = demoImBoxFilter(input)
%
%   Example
%   demoImBoxFilter
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-11-22,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2018 INRA - Cepia Software Platform.

% reference image of fixed size
img = zeros([500, 500], 'double');
img(200:300, 200:300) = 255;

% kernel sizes
kernelSizes = 3:2:191;
nSizes = length(kernelSizes);

resRef = zeros(1, nSizes);
resBox = zeros(1, nSizes);

for i = 1:nSizes
    disp(sprintf('iter %d/%d', i, nSizes));
    
    dim = kernelSizes(i);
    kernel = ones([dim dim]) / (dim*dim);
    tic; resf = imfilter(img, kernel); resRef(i) = toc;
    
    tic; resf2 = imBoxFilter(img, [dim dim]); resBox(i) = toc;
end

figure; hold on;
plot(kernelSizes, resRef, 'k');
plot(kernelSizes, resBox, 'b');
legend({'imfilter', 'imBoxFilter'});

function e = imEntropy(img)
%IMENTROPY Compute entropy of an image
%
%   output = imEntropy(input)
%
%   Example
%   imEntropy
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% first compute histogram
h = imHistogram(img);

% keep only positive values, and normalize by 1 to have density
h(h==0) = [];
h = h/sum(h);

% compute entropy
e = -sum(h.*log(h));

function mi = imMutualInformation(img1, img2)
%IMMUTUALINFORMATION  Mutual information between two images
%
%   MI = imMutualInformation(IMG1, IMG2)
%
%   Example
%   imMutualInformation
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% entropy of each image
h1 = imEntropy(img1);
h2 = imEntropy(img2);

% joint entropy between images
h12 = imJointEntropy(img1, img2);

% compute mutual information
mi = h1 + h2 - h12;

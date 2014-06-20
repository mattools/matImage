function [chi labels] = imEuler1dEstimate(img, varargin)
% Compute Euler number of a binary 1D image
%
%   The function computes the Euler number, or Euler-Poincare
%   characteristic, of a binary 2D image. The result corresponds to the
%   number of connected components in the image.
%
%   CHI = imEuler1dEstimate(IMG);
%   return the Euler-Poincaré Characteristic, which is the number of
%   connected components.
%   IMG must be a binary image.
%
%   [CHI LABELS] = imEuler1dEstimate(LBL);
%   When LBL is a label image, returns the euler number of each label
%   different from 0. Returns also the set of unique values in LBL.
%
%   
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    chi = zeros(length(labels), 1);
    for i=1:length(labels)
        chi(i) = imEuler1dEstimate(img==labels(i), varargin{:});
    end
    return;
end

labels = 1;

% Compute Euler number by using graph formula: CHI = Nvertices - Nedges
chi = sum(img(:)) - sum(img(1:end-1) & img(2:end)) - (img(1) + img(end))/2;


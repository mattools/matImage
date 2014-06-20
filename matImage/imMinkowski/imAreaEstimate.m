function a = imAreaEstimate(img, varargin)
%Estimate area of binary 2D structure with edge correction
%
%   Aest = imAreaEstimate(IMG)
%   Aest = imAreaEstimate(IMG, DELTA)
%
%   Example
%   imAreaEstimate
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Input arguments processing

% check image dimension
if ndims(img)~=2
    error('first argument should be a 2D binary or label image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    a = zeros(length(labels), 1);
    for i=1:length(labels)
        a(i) = imAreaEstimate(img==labels(i), varargin{:});
    end
    return;
end

% check image resolution
delta = [1 1];
if ~isempty(varargin)
    delta = varargin{1};
end


%% Main processing 

% compute area in whole image
a = sum(img(:));

% compute area on borders
a1 = sum(sum(img([1 end], :)));
a2 = sum(sum(img(:, [1 end])));

% compute area on corners
a0 = sum(sum(img([1 end], [1 end])));

% estimate area using edge weighting according to multiplicity
a = a -(a1+a2)/2 + a0/4;

% multiply by area of a single pixel
a = a*prod(delta);

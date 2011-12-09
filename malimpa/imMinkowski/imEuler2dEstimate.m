function [chi labels] = imEuler2dEstimate(img, varargin)
%Estimate Euler number in a 2D image
%
%   CHIest = imEuler2dEstimate(IMG)
%   CHIest = imEuler2dEstimate(IMG, CONN)
%
%   Example
%   imEuler2dEstimate
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=2
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    chi = zeros(length(labels), 1);
    for i = 1:length(labels)
        chi(i) = imEuler2dEstimate(img == labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label...
labels = 1;

% Euler-Poincare Characteristic of the binary structure in image
chi     = imEuler2d(img, varargin{:});

% compute EPC on each border of image, and keep the average
chix    = mean([ imEuler1d(img(1,:)) imEuler1d(img(end,:)) ]);
chiy    = mean([ imEuler1d(img(:,1)) imEuler1d(img(:,end)) ]);

% compute EPC on each corner of image, and keep the average
chixy   = mean([ ...
    img( 1,  1), ...
    img(end,  1), ...
    img( 1, end), ...
    img(end, end) ]);

% estimate EPC in image using mean edge correction
chi = chi - chix - chiy + chixy;



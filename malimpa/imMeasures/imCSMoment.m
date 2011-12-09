function mu = imCSMoment(img, p, q, varargin)
%IMCSMOMENT  Compute centered and scaled moment of an image
%   MU = imCSMoment(IMG, P, Q)
%   compute (p+q)-th centered moment of image IMG.
%
%   MU = imCSMoment(IMG, P, Q, CENTER, MASS)
%   where CENTER = [CX CY], provides pre-computed center of mass.
%
%   Example
%   imCMoment
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-10-08,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"



% get the centroid, either by argument, or by computation
if ~isempty(varargin)
    var = varargin{1};
    if length(var)>1
        cx = var(1);
        cy = var(2);
        varargin(1) = [];
    else
        cx = var;
        cy = varargin{2};
        varargin(1:2) = [];
    end
else
    s = sum(img(:));
    cx = imMoment(img, 1, 0)/s;
    cy = imMoment(img, 0, 1)/s;
end

if ~isempty(varargin)
    m00 = varargin{1};
else
    m00 = sum(img(:));
end


% image dimension
dim = size(img);
Dy = dim(1);
Dx = dim(2);

% compute x and y for each pixel
Ix = repmat((1:Dx), [Dy 1])-cx;
Iy = repmat((1:Dy)', [1 Dx])-cy;

% compute moment
mu = zeros(size(p));
for i=1:length(p(:))
    d = (p(i)+q(i))/2+1;
    mu(i) = sum(Ix(:).^p(i) .* Iy(:).^q(i) .* img(:)) / m00^d;
end


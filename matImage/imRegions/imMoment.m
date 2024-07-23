function m = imMoment(img, p, q)
%IMMOMENT  Compute simple moment(s) of an image
%
%   M_PQ = imMoment(IMG, P, Q)
%   P is order for x coord, Q is order for y coord.
%
%   Example
%   % generate image
%   img = zeros([5 6]);
%   img(2:3, 2:5) = 1;
%   % compute total mass of image
%   m00  = imMoment(img, 0, 0);
%   % compute centroid
%   cx  = imMoment(img, 1, 0)/m00;
%   cy  = imMoment(img, 0, 1)/m00;
%   
%
%   See also
%     imEquivalentEllipse, imPrincipalAxes
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-10-08,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% image dimension
dim = size(img);
Dx = dim(2);
Dy = dim(1);

% compute x and y for each pixel
Ix = repmat((1:Dx), [Dy 1]);
Iy = repmat((1:Dy)', [1 Dx]);

% compute moment
m = zeros(size(p));
for i=1:length(p(:))
    m(i) = sum(Ix(:).^p(i) .* Iy(:).^q(i) .* img(:));
end

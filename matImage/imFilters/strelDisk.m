function im = strelDisk(radius)
%STRELDISK Discrete disk structuring element
%   STREL = strelDisk(RADIUS)
%
%   Compute a structuring element approximating a disk. 
%   The center of the disk is slighty shifted with respect to the pixel
%   center. The resulting stucturing element is not symetrical, but its
%   variations when increasing the circle radius are smoother than with
%   matlab 'strel' function, and result for increasing radii are always
%   contained inside each other.
%
%   The size of the structuring element has always the form
%   (2*N+1)*(2*N+1), with N integer.
%
%   Example
%   strelDisk(2)
%   ans =
%      0     0     0     0     0
%      0     1     1     1     0
%      0     1     1     1     1
%      0     1     1     1     1
%      0     0     1     1     0
%   strelDisk(2.5)
%   ans =
%      0     0     1     1     0
%      0     1     1     1     1
%      1     1     1     1     1
%      1     1     1     1     1
%      0     1     1     1     1
%
%   See also
%   strel
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-03-07,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"


% basic shifts of circle center in each dimension
d1 = 0.31;
d2 = 0.19;

% compute size of structuring element (2*N+1)x(2*N+1)
N = floor(radius+d2);

% compute coordinates of pixel centers
l1 = -N:N;
l2 = -N:N;
[X2, X1] = meshgrid(l1, l2);

% compute distance of each pixel center to circle center, and threshold
im      = false(size(X1));
im(:)   = hypot(X1(:)-d1, X2(:)-d2) < radius;


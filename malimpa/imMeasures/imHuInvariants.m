function hu = imHuInvariants(img)
%IMHUINVARIANTS  Compute Hu's invariant for an image
%   HU = imHuInvariants(IMG)
%   HU is a row vector with 12 elements.
%
%   Example
%   imHuInvariants
%
%   See also
%
%   Current implementation is based on the paper:
%   "Noise tolerance of moment invariants in pattern recognition"
%   I. Baslev, Pattern Recognition Letters 19 (1998): 1183-1189
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-10-08,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"



%% Compute image moments

% total mass of image
m00 = sum(img(:));

% center of mass (first order non-centered moment)
cx = imMoment(img, 1, 0)/m00;
cy = imMoment(img, 0, 1)/m00;

% second-order centered and scaled moments
m02 = imCSMoment(img, 0, 2, [cx cy], m00);
m11 = imCSMoment(img, 1, 1, [cx cy], m00);
m20 = imCSMoment(img, 2, 0, [cx cy], m00);

% third-order centered and scaled moments
m30 = imCSMoment(img, 3, 0, [cx cy], m00);
m21 = imCSMoment(img, 2, 1, [cx cy], m00);
m12 = imCSMoment(img, 1, 2, [cx cy], m00);
m03 = imCSMoment(img, 0, 3, [cx cy], m00);

% fourth-order centered and scaled moments
m40 = imCSMoment(img, 4, 0, [cx cy], m00);
m31 = imCSMoment(img, 3, 1, [cx cy], m00);
m22 = imCSMoment(img, 2, 2, [cx cy], m00);
m13 = imCSMoment(img, 1, 3, [cx cy], m00);
m04 = imCSMoment(img, 0, 4, [cx cy], m00);

%% computation shortcuts

% degree 2
a40 = m20 + m02;
a42 = m20 - m02;
b42 = 2*m11;

% degree 3
a51 = m30 + m12;
b51 = m21 + m03;
a53 = m30 - m12;
b53 = 3*m21 - m03;

% degree 4
a60 = m40 + 2*m22 + m04;
a62 = m40 - m04;
b62 = 2*(m31 + m13);
a64 = m40 - 6*m22 + m04;
b64 = 4*(m31 - m13);


%% Compute Hu's invariants

% init size
hu = zeros(1, 12);

% degree 2
hu(1)   = a40;
hu(2)   = a42^2 + b42^2;
hu(3)   = a42*(a51^2-b51^2) + 2*a51*b51*b42;

% degree 3
hu(4)   = a51^2 + b51^2;
hu(5)   = a53^2 + b53^2;
hu(6)   = a51*a53*(a51^2 - 3*b51^2) + b51*b53*(3*a51^2 - b51^2);
hu(7)   = a51*b53*(a51^2 - 3*b51^2) - b51*a53*(3*a51^2 - b51^2);

% degree 4
hu(8)   = a60;
hu(9)   = a62^2 + b62^2;
hu(10)  = a64^2 + b64^2;
hu(11)  = a64*(a62^2-b62^2) + 2*a62*b62*b64;
hu(12)  = b64*(a62^2-b62^2) - 2*a62*b62*b64;


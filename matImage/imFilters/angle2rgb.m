function rgb = angle2rgb(img, varargin)
%ANGLE2RGB  Convert an image of angles to color image
%
%   RES = angle2rgb(IMG);
%   IMG is an image containing angle values, in radians.
%   RES is a RGB image with the same size a IMG, with 3 channels for
%   dimension 3, containing colors corresponding to each angle, based on
%   the 'hsv' colormap:
%   0       -> red
%   pi/3    -> yellow
%   2*pi/3  -> green
%   pi      -> cyan
%   4*pi/3  -> blue
%   5*pi/3  -> magenta
%   2*pi    -> red again
%   Angle values are considered modulo 2*pi.
%
%   RES = angle2rgb(IMG, MAXANGLE)
%   Also specifies the value of the maximal angle. Can be PI, in this case
%   the function considers unoriented angles, or 360, in this case consider
%   degrees instead of radians.
%
%   Example
%   % show angle of complex values around origin
%     [x y] = meshgrid(-50:50, -50:50);
%     a = angle(x+i*y);
%     imshow(angle2rgb(a));
%
%   % show hue value of a color image
%     img = imread('peppers.png');
%     hsv = rgb2hsv(img);
%     % convert hue value, coded between 0 and 1, into RGB
%     rgbHue = angle2rgb(hsv(:,:,1), 1);
%     subplot(121);imshow(img); subplot(122); imshow(rgbHue);
%
%   See also
%   deg2rad, rad2deg, angle, imGetHue
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2009-02-06,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"


% rename as rad2rgb ?

% extract value for normalizing angles
maxi = 2*pi;
if ~isempty(varargin)
    var =  varargin{1};
    maxi = var(end);
end

% normalise between 0 and 255
img = uint8(floor(256*mod(mod(img, maxi) + maxi, maxi)/maxi));

% build the color map
map = hsv(256);

% apply colormap to normalised image
rgb = ind2rgb(img, map);


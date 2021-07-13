function img = imGray12ToGray8(img)
% Convert a 12 bits gray scale image to 8 bits gray scale.
%
%   Usage:
%   RES = imGray12ToGray8(IMG);
%   IMG is a 12-bits grayscale image with 4096 different values. For
%   simplicity, they are stored as 16-bits images. For some obscure
%   reasons, the gray levels range from 32768 to 65535.
%   This function converts gray values between 0 and 255, and return an
%   uint8 image.
%
%   The applied operation is:
%   RES = (IMG-32768)/16
%   
%
%   Example
%     imGray12ToGray8;
%
%
%   See also
%     imAdjustDynamic

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2008-01-08,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
      
img = uint8((double(img) - 32768) / 16);   

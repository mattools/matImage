function map = blue2red(varargin)
%BLUE2RED  colormap showing a gradient from blue to green to red.
%
%   MAP = blue2red
%   return a 256x3 array which can be used with colormap.
%   map(1,:)    corresponds to blue color,
%   map(64,:)   corresponds to cyan color,
%   map(128,:)  corresponds to green color,
%   map(192,:)  corresponds to yellow color,
%   map(256,:)  corresponds to red color,
%   and all indices inbetween are gradient between the 2 extremes colors.
%
%
%   Example
%   colormap(blue2red);
%
%   See also
%   colormap
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-05-24
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


r = zeros(256,1);
r(128:192) = linspace(0, 1, 65);
r(192:256)=1;

g = zeros(256,1);
g(1:64) = linspace(0,1,64);
g(64:192)=1;
g(192:256) = linspace(1, 0, 65);

b = zeros(256,1);
b(1:64)=1;
b(64:128) = linspace(1,0,65);

map = [r g b];
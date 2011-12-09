function img = imDrawLine(img, pos1, pos2, varargin)
%IMDRAWLINE Draw a line between two points in the image
%
%   IMG2 = imDrawLine(IMG, P1, P2);
%   IMG2 = imDrawLine(IMG, X1, Y1, X2, Y2);
%
%   [X, Y] = imDrawLine(X1, X2, Y1, Y2) computes an
%   approximation to the line segment joining (X1, Y1) and
%   (X2, Y2) with integer coordinates.  X1, X2, Y1, and Y2
%   should be integers.  imDrawLine is reversible; that is,
%   imDrawLine(X1, X2, Y1, Y2) produces the same results as
%   FLIPUD(imDrawLine(X2, X1, Y2, Y1)).
%
%   Example
%     % read image
%     img = imread('cameraman.tif');
%     % draw white line
%     img = imDrawLine(img, [10 30], [150 110], 255);
%     % draw also a black line
%     img = imDrawLine(img, [10 30], [100 210], 0);
%     % display result
%     imshow(img);
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%   Function adapted from the 'strel' function of matlab.



%% Input argument extraction

% extract coordinates
if isscalar(pos1)
    if nargin < 5
        error('Please give coordinates either as 2 points, or as 4 coords');
    end
    x1 = pos1;
    y1 = pos2;
    x2 = varargin{1};
    y2 = varargin{2};
    varargin(1:2) = [];
    
else
    x1 = pos1(1);
    y1 = pos1(2);
    x2 = pos2(1);
    y2 = pos2(2);
end

% extract color
color = 255;
if ~isempty(varargin)
    color = varargin{1};
end


%% Pre-processing

dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case
if dx == 0 && dy == 0
    return;
end


%% Coordinates computation

flip = 0;
if dx >= dy
    % process "horizontal" lines
    
	% eventually swap coordinates to draw from left to right.
    if x1 > x2
        [x1 x2] = swap(x1, x2);
        [y1 y2] = swap(y1, y2);
        flip = 1;
    end
    
    % compute line slope, and y from x
    s = (y2 - y1) / (x2 - x1);
    x = (x1:x2)';
    y = round(y1 + s * (x - x1));
    
else
    % process "vertical" lines
    
    if y1 > y2
        % swap coordinates to draw from bottom to top.
        [x1 x2] = swap(x1, x2);
        [y1 y2] = swap(y1, y2);
        flip = 1;
    end
    
    % compute line slope, and x from y
    s = (x2 - x1) / (y2 - y1);
    y = (y1:y2)';
    x = round(x1 + s * (y - y1));
end

% ensure correct ordering
if flip
    x = x(end:-1:1);
    y = y(end:-1:1);
end


%% remove line pixels outside image

xOut = x < 1 | x > size(img, 2); 
yOut = y < 1 | y > size(img, 1); 
x(xOut | yOut) = [];
y(xOut | yOut) = [];


%% Write the line into image

if size(img, 3) == 1
    for i = 1:length(x)
        img(y(i), x(i)) = color;
    end
else
    for i = 1:length(x)
        img(y(i), x(i), :) = color(:);
    end
end


% Swaping functions
function [a2 b2] = swap(a, b)
a2 = b;
b2 = a;

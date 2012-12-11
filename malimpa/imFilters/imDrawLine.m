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
%   % Draw some lines to make a diamond
%     img = imCreate([16 16], 'uint8');
%     img = imDrawLine(img, [8 1], [16 8]);
%     img = imDrawLine(img, [16 8], [8 16]);
%     img = imDrawLine(img, [8 16], [1 8]);
%     img = imDrawLine(img, [1 8], [8 1]);
%     image(img);
% 
%   % Overlay some lines on a grayscale image
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
%     bresenhamLine
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Input argument extraction

% process case of input given as imDrawLine(IMG, X1, Y1, X2, Y2)
if isscalar(pos1)
    if nargin < 5
        error('Please give coordinates either as 2 points, or as 4 coords');
    end
    pos1 = [pos1 pos2];
    pos2 = [varargin{1} varargin{2}];
    varargin(1:2) = [];    
end

% extract color
color = 255;
if ~isempty(varargin)
    color = varargin{1};
end


%% Coordinates computation

% coordinates of pixels
[x y] = bresenhamLine(pos1, pos2, varargin{:});

% remove line pixels outside image
xOut = x < 1 | x > size(img, 2); 
yOut = y < 1 | y > size(img, 1); 
x(xOut | yOut) = [];
y(xOut | yOut) = [];


%% Write the line into image

if size(img, 3) == 1
    % grayscale image
    for i = 1:length(x)
        img(y(i), x(i)) = color;
    end
    
else
    % color image
    for i = 1:length(x)
        img(y(i), x(i), :) = color(:);
    end
end



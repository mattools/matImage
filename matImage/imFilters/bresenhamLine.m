function [x y] = bresenhamLine(pos1, pos2, varargin)
%BRESENHAMLINE Integer coordinates of a bresenham line
%
%   [X Y] = bresenhamLine(POS1, POS2)
%   PTS = bresenhamLine(POS1, POS2)
%
%   Example
%     bresenhamLine([1 8], [8 1])
%     ans =
%          1     8
%          2     7
%          3     6
%          4     5
%          5     4
%          6     3
%          7     2
%          8     1
%        
%   See also
%     imDrawLine
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-12-11,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

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
    
else
    x1 = pos1(1);
    y1 = pos1(2);
    x2 = pos2(1);
    y2 = pos2(2);
end


%% Pre-processing

% direction vector
dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case
if dx == 0 && dy == 0
    x = x1; y = y1;
    if nargout <= 1
        x = [x y];
    end
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


%% Process output

if nargout <= 1
    x = [x y];
end


% Swaping functions
function [a2 b2] = swap(a, b)
a2 = b;
b2 = a;

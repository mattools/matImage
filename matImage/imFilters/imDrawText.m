function res = imDrawText(img, pos, text, varargin)
%IMDRAWTEXT Draw some text in an image
%
%   output = imDrawText(IMG, POS, TEXT)
%
%   Example
%     img = imread('rice.png');
%     img2 = imDrawText(img, [30 30], 'Hello!');
%     imshow(img2);
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-04-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


fontImage = imread('fontHelvetica07.tif');
allDigits = [...
    'abcdefghijklmnopqrstuvwxyz'  ...
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'  ...
    '1234567890''м!"Ј$%&/()=?^и+'  ...
    'тащ,.-<\|;:_>з°§й*@#[]{}  '];

% settings specific for the font
charWidth = 7;
charHeight = 12;

% Default color is white
color = 255;
if ~isempty(varargin)
    color = varargin{1};
    if ischar(color)
        switch color
            case 'r', color = [255 0 0];
            case 'g', color = [0 255 0];
            case 'b', color = [0 0 255];
            case 'c', color = [0 255 255];
            case 'm', color = [255 0 255];
            case 'y', color = [255 255 0];
            case 'k', color = 0;
            case 'w', color = 255;
        end
    end
end
isColor = length(color) == 3;

res = img;
if length(color) == 3 && size(img, 3) == 1
    res = cat(3, img, img, img);
end


textWidth = length(text) * charWidth;
textHeight = charHeight;

% recenter the text
i0 = max(pos(2) - round(textHeight / 2), 1);
j0 = max(pos(1) - round(textWidth / 2), 1);


% iterate on text characters
for c = 1:length(text)
    % find position of current character in font image
    ind = find(allDigits == text(c));
    col = mod(ind - 1, 26) + 1;
    row = floor((ind - 1) / 26) + 1;
    
    % extract thumbnail for current character
    im = fontImage((1:charHeight)+(row-1)*charHeight, (1:charWidth)+(col-1)*charWidth);
    
    % process all pixel in character font item
    if isColor
        for i = 1:charHeight
            for j = 1:charWidth
                if im(i, j)
                    res(i0+i, j0+j, 1) = color(1);
                    res(i0+i, j0+j, 2) = color(2);
                    res(i0+i, j0+j, 3) = color(3);
                end
            end
        end
    else
        for i = 1:charHeight
            for j = 1:charWidth
                if im(i, j)
                    res(i0+i, j0+j, :) = color;
                end
            end
        end
    end
    % update position for next character
    j0 = j0 + charWidth;
end
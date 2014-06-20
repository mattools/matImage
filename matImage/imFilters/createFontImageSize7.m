%CREATEFONTIMAGESIZE7  One-line description here, please.
%
%   output = createFontImageSize7(input)
%
%   Example
%   createFontImageSize7
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-04-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


close all;

allDigits = [...
    'abcdefghijklmnopqrstuvwxyz' ; ...
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ; ...
    '1234567890''м!"Ј$%&/()=?^и+' ; ...
    'тащ,.-<\|;:_>з°§й*@#[]{}  '];

img = ones(100, 400);
imshow(img); hold on;

for row = 1:4
    y = (row - 1) * 12 + 7;
    
    for col = 1:26
        x = (col - 1) * 7 + 5;
        text(x, y, allDigits(row, col), ...
            'interpreter', 'none', 'fontsize', 7, ...
            'BackgroundColor', [1 1 1], ...
            'HorizontalAlignment', 'Center', ...
            'Margin', .001);
    end
end
    
tim =getframe(gca);
tim = tim.cdata;
figure; imshow(tim)

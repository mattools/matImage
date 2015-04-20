function histo = imBinaryConfigHisto(img)
%IMBINARYCONFIGHISTO Histogram of binary configuration from 2D/3D image
%
%   HISTO = imBinaryConfigHisto(IMG)
%   Computes the histogram of 2-by-2 or 2-by-2 binary configuration in the
%   binary image IMG.
%   If the input image is 2D, the result is a 16-by-1 array.
%   If the input image is 3D, the result is a 256-by-1 array.
%
%   Example
%   imBinaryConfigHisto
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-17,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

dims = size(img);

if length(dims) == 2
    histo = zeros(16, 1);
    for y = 1:dims(1)-1
        for x = 1:dims(2)-1
            b0 = img(y, x) > 0;
            b1 = img(y, x+1) > 0;
            b2 = img(y+1, x) > 0;
            b3 = img(y+1, x+1) > 0;
            index = b0 + b1 * 2 + b2 * 4 + b3 * 8 + 1;
            histo(index) = histo(index) + 1;
        end
    end
    
elseif length(dims) == 3
    histo = zeros(256, 1);
    
    for z = 1:dims(3)-1
        for y = 1:dims(1)-1
            for x = 1:dims(2)-1
                index = 1;
                if img(  y,   x,   z) > 0, index = index +   1; end
                if img(  y, x+1,   z) > 0, index = index +   2; end
                if img(y+1,   x,   z) > 0, index = index +   4; end
                if img(y+1, x+1,   z) > 0, index = index +   8; end
                if img(  y,   x, z+1) > 0, index = index +  16; end
                if img(  y, x+1, z+1) > 0, index = index +  32; end
                if img(y+1,   x, z+1) > 0, index = index +  64; end
                if img(y+1, x+1, z+1) > 0, index = index + 128; end
                
                histo(index) = histo(index) + 1;
            end
        end
    end
end
    
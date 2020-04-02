function histo = imBinaryConfigHisto(img)
% Histogram of binary configurations from 2D/3D image.
%
%   HISTO = imBinaryConfigHisto(IMG)
%   Computes the histogram of 2-by-2 or 2-by-2 binary configuration in the
%   binary image IMG.
%   If the input image is 2D, the result is a 16-by-1 array.
%   If the input image is 3D, the result is a 256-by-1 array.
%   
%   HISTO(1) corresponds to the number of totally void configurations.
%   HISTO(end) corresponds to the number of configuration totally contained
%   in the structure of interest. Informative configurations (for surface
%   area, perimeter, euler number...) are within HISTO(2) and HISTO(end-1).
%
%   Example
%     % Create a binary image of a ball
%     [x, y, z] = meshgrid(1:100, 1:100, 1:100);
%     img = sqrt( (x-50.12).^2 + (y-50.23).^2 + (z-50.34).^2) < 40;
%     % compute surface area of the ball
%     HISTO = imBinaryConfigHisto(img);
%     
%     LUT = imSurfaceAreaLut(13);
%     S = sum(HISTO .* LUT)
%     S =
%         2.0103e+04
%     % compare with theoretical value
%     Sth = 4*pi*40^2;
%     100 * (S - Sth) / Sth
%     ans = 
%         -0.0167
%
%   See also
%     imSurfaceAreaLut, imPerimeterLut
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2015-04-17,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRAE - Cepia Software Platform.

dims = size(img);

if length(dims) == 2
    % first create map of configurations
    map = zeros(dims - 1, 'uint8');
    map = map + uint8(img(1:end-1, 1:end-1));
    map = map + uint8(img(1:end-1,   2:end)) * 2;
    map = map + uint8(img(  2:end, 1:end-1)) * 4;
    map = map + uint8(img(  2:end,   2:end)) * 8;
    
    % compute histogram of configurations
    histo = zeros(16, 1);
    for i = 1:16
        histo(i) = sum(map(:) == (i-1));
    end
    
    % the following is a slower algorithm, but that requires less memory
    % (no need to allocate memory for configurations map).
    % It can be used if very large images has to be analysed.
%     histo = zeros(16, 1);
%     for y = 1:dims(1)-1
%         for x = 1:dims(2)-1
%             b0 = img(y, x) > 0;
%             b1 = img(y, x+1) > 0;
%             b2 = img(y+1, x) > 0;
%             b3 = img(y+1, x+1) > 0;
%             index = b0 + b1 * 2 + b2 * 4 + b3 * 8 + 1;
%             histo(index) = histo(index) + 1;
%         end
%     end
    
elseif length(dims) == 3
    try 
        % first create map of configurations (may require some memory)
        map = zeros(dims - 1, 'uint8');
        map = map + uint8(img(1:end-1, 1:end-1, 1:end-1));
        map = map + uint8(img(1:end-1,   2:end, 1:end-1)) * 2;
        map = map + uint8(img(  2:end, 1:end-1, 1:end-1)) * 4;
        map = map + uint8(img(  2:end,   2:end, 1:end-1)) * 8;
        map = map + uint8(img(1:end-1, 1:end-1,   2:end)) * 16;
        map = map + uint8(img(1:end-1,   2:end,   2:end)) * 32;
        map = map + uint8(img(  2:end, 1:end-1,   2:end)) * 64;
        map = map + uint8(img(  2:end,   2:end,   2:end)) * 128;

        % compute histogram of configurations
        histo = zeros(256, 1);
        for i = 1:256
            histo(i) = sum(map(:) == (i-1));
        end
        
    catch ME %#ok<NASGU>
        % in case of out-of-memory exception, switch to slower algorithm
        
        warning('matImage:imMinkowski:LowMemory', ...
            'warning: for memory reason, switched to slower algorithm');
        
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
else
    error('Requires a 2D or 3D binary image as input');
end

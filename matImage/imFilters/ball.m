function res = ball(size, varargin)
%BALL Generate a ball in a matrix in 2 or 3 dimensions
%
% parameters
%  size: radius of the ball, center exclude
%  dim:  dimensions of the ball (2 or 3)
%
% author : Gaetan Lehmann
%

%	HISTORY
%	13/03/2007: update doc (DL)

if ~isempty(varargin)
    dim = varargin{1};
else
    dim = 2;
end

if dim == 2
    if length(size) == 1
        xSize = size;
        ySize = size;
    else
        xSize = size(1);
        ySize = size(2);
    end
    
    realXSize = xSize*2+1;
    realYSize = ySize*2+1;
    
    res = zeros([realXSize, realYSize]);
    center = [xSize ySize] + 1;
    radius2 = ([xSize ySize] + 0.5) .^ 2;
    
    for x = 1:realXSize
        for y = 1:realYSize
            d = [x y] - center;
            d2 = d .^ 2;
            if sum(d2./radius2) <= 1
                res(x, y) = 1;
            end
        end
    end
else
    if length(size) == 1
        xSize = size;
        ySize = size;
        zSize = size;
    else
        xSize = size(1);
        ySize = size(2);
        zSize = size(3);
    end
    
    realXSize = xSize*2+1;
    realYSize = ySize*2+1;
    realZSize = zSize*2+1;
    
    res = zeros([realXSize, realYSize, realZSize]);
    center = [xSize ySize zSize] + 1;
    radius2 = ([xSize ySize zSize] + 0.5) .^ 2;
    
    for x = 1:realXSize
        for y = 1:realYSize
            for z = 1:realZSize
                d = [x y z] - center;
                d2 = d .^ 2;
                if sum(d2./radius2) <= 1
                    res(x, y, z) = 1;
                end
            end
        end
    end
end

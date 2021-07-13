function res = imCheckerBoard(img1, img2, varargin)
% Create a checkerboard image from 2 images.
%
%   RES = imCheckerBoard(IMG1, IMG2);
%   IMG1 and IMG2 are two images the same size. The result is a composite
%   image created by selecting tile in each image alternatively.
%
%   RES = imCheckerBoard(IMG1, IMG2, N);
%   Also specifies the number of tile in each direction. Default is 8.
%
%   Example
%       [x y] = meshgrid(0:255, 0:255);
%       res = imCheckerBoard(x, y);
%       imshow(res, []);
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-05-04,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.


%% Initialisations

% default number of tiles in each direction
N = 8;
if ~isempty(varargin)
    N = varargin{1};
end

% size of all images
if sum(size(img1)~=size(img2))>0
    error('Both images must have same size');
end
dim = size(img1);

% information about image
isColor1    = length(dim)>2 && dim(3)==3;
isThreeD1   = length(dim)>2 && ~isColor1;

% initialize result with first image
res = img1;


if ~isThreeD1
    %% Planar case
    
    % compute indices of tile limits
    l1 = round(linspace(1, dim(1)+1, N+1));
    l2 = round(linspace(1, dim(2)+1, N+1));
    
    for i=1:2:N-1
        % indices of pixels in the two consecutive rows
        i1 = l1(i):l1(i+1)-1;
        i2 = l1(i+1):l1(i+2)-1;
        
        % iterate on column couples
        for j=1:2:N
            % first line
            j1 = l2(j):l2(j+1)-1;
            res(i1, j1) = img2(i1, j1);
            
            % second line
            j2 = l2(j+1):l2(j+2)-1;
            res(i2, j2) = img2(i2, j2);
        end
    end
else
    %% Three Dimension images
    
    % compute indices of tile limits
    l1 = round(linspace(1, dim(1)+1, N+1));
    l2 = round(linspace(1, dim(2)+1, N+1));
    l3 = round(linspace(1, dim(3)+1, N+1));

    for k=1:2:N-1
        % indices of voxels in the two consecutive planes
        k1 = l3(k):l3(k+1)-1;
        k2 = l3(k+1):l3(k+2)-1;
        
        for i=1:2:N-1
            % indices of pixels in the two consecutive rows
            i1 = l1(i):l1(i+1)-1;
            i2 = l1(i+1):l1(i+2)-1;
            
            % iterate on column couples
            for j=1:2:N
                j1 = l2(j):l2(j+1)-1;
                j2 = l2(j+1):l2(j+2)-1;
                
                % first line, first slice
                res(i1, j1, k1) = img2(i1, j1, k1);
                
                % second line, first slice
                res(i2, j2, k1) = img2(i2, j2, k1);

                % first line, second slice
                res(i1, j2, k2) = img2(i1, j2, k2);
                
                % second line, second slice
                res(i2, j1, k2) = img2(i2, j1, k2);
            end
        end
    end
end



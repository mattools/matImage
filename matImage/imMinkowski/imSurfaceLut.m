function lut = imSurfaceLut(varargin)
%IMSURFACELUT Look-Up Table for computing surface area of a 3D binary image
%
%   LUT = surfaceLut
%   return an array of size 256, which can be used with function imLUT to
%   create map of contribution to the surface. We consider here tiles
%   located in the interior of image (none of the pixels is located on the
%   edge).
%
%   LUT = surfaceLut(SCALE)
%   Also specify size of the elementary tile, in user units (Default is
%   [1 1 1]).
%
%   LUT = surfaceLut(SCALE, NDIR)
%   Also specify the number of directions for computing intersections,
%   which can be either 3 (the default), or 13.
%
%   
%   Example
%     % Create a binary image of a ball
%     [x, y, z] = meshgrid(1:100, 1:100, 1:100);
%     IMG = sqrt( (x-50.12).^2 + (y-50.23).^2 + (z-50.34).^2) < 40;
%     % compute surface area of the ball
%     HISTO = imBinaryConfigHisto(IMG);
%     LUT = imSurfaceLut(13);
%     S = sum(HISTO .* LUT)
%     S =
%         2.0103e+04
%     % compare with theoretical value
%     Sth = 4*pi*40^2;
%     100 * (S - Sth) / Sth
%     ans = 
%         -0.0167
%
%     % Verifies the additivity property: the sum of measures on sub-images 
%     % (with one voxel overlap) should equal the measure on the whole
%     % image. 
%     sub1 = 1:51; sub2 = 51:100;
%     imgList = {...
%         IMG(sub1, sub1, sub1), IMG(sub1, sub1, sub2), ...
%         IMG(sub1, sub2, sub1), IMG(sub1, sub2, sub2), ...
%         IMG(sub2, sub1, sub1), IMG(sub2, sub1, sub2), ...
%         IMG(sub2, sub2, sub1), IMG(sub2, sub2, sub2)};
%     bList = zeros(8, 1);
%     for i = 1:8
%         HISTO = imBinaryConfigHisto(imgList{i});
%         bList(i) = sum(HISTO .* LUT);
%     end
%     sum(bList)
%     ans =
%        79.9989
%
%
%   See also
%     imSurface, imSurfaceEstimate, imPerimeterLut, imMeanBreadthLut
%

%   ------
%   Author: David Legland
%   e-mail: david.legland@nantes.inra.fr
%   Created: 2006-02-23
%   Copyright 2005 INRA - CEPIA Nantes - MIAJ Jouy-en-Josas.

%% Extract input data

% size of image tile
delta = [1 1 1];

% number of discrete directions
nDirs = 3;

% Process user input arguments
while ~isempty(varargin)
    var = varargin{1};
    if isnumeric(var)
        % option is either connectivity or resolution
        if isscalar(var)
            nDirs = var;
        else
            delta = var;
        end
        varargin(1) = [];

    else
        error('option should be numeric');
    end
    
end



%% Initializations

% distance between a pixel and its neighbours.
% di refer to orthogonal neighbours
% dij refer to neighbours on the same plane
% dijk refer to the opposite pixel in a tile
d1  = delta(1);
d2  = delta(2);
d3  = delta(3);
d12 = sqrt(delta(1)^2 + delta(2)^2);
d13 = sqrt(delta(1)^2 + delta(3)^2);
d23 = sqrt(delta(2)^2 + delta(3)^2);
d123= sqrt(delta(1)^2 + delta(2)^2 + delta(3)^2);
vol = d1*d2*d3;

% correspondance map between pixel label and pixel coord in config
coord = [...
    1 1 1; ...
    1 2 1; ...
    2 1 1; ...
    2 2 1; ...
    1 1 2; ...
    1 2 2; ...
    2 1 2; ...
    2 2 2; ...
    ];

% 'magical numbers', corresponding to area of voronoi partition on the
% unit sphere, when germs are the 26 directions on the unit cube
% Sum of (c1+c2+c3 + c4*2+c5*2+c6*2 + c7*4) equals 1.
% See function sphericalCapsAreaC26.m
c1 = 0.04577789120476 * 2;  % Ox
c2 = 0.04577789120476 * 2;  % Oy
c3 = 0.04577789120476 * 2;  % Oz
c4 = 0.03698062787608 * 2;  % Oxy
c5 = 0.03698062787608 * 2;  % Oxz
c6 = 0.03698062787608 * 2;  % Oyz
c7 = 0.03519563978232 * 2;  % Oxyz

% If resolution is not the same in each direction, recomputes the weights
% assigned to each direction
if sum(abs(diff(delta)))~=0
    areas = sphericalCapsAreaC26(delta);
    c1 = areas(1) * 2;
    c2 = areas(2) * 2;
    c3 = areas(3) * 2;
    c4 = areas(4) * 2;
    c5 = areas(6) * 2;
    c6 = areas(8) * 2;
    c7 = areas(10) * 2;
end

%% Create Look-up Table

% initialize empty arrays
N = 256; % = 2^(2^3);
lut = zeros(N, 1);


% loop for each tile configuration
for i = 1:N
    % create the tile
    im = createTile(i);
    
    % compute contribution of configuration
    for j=1:8
        % position of pixel in the tile
        p1 = coord(j, 1);
        p2 = coord(j, 2);
        p3 = coord(j, 3);
        
        % if pixel is not in structure, its contribution is 0
        if im(p1, p2, p3)==0
            continue;
        end
        
        % contributions for isothetic directions
        ke1=0; ke2=0; ke3=0;
        if ~im(3-p1, p2, p3), ke1 = ke1 + vol/d1/2; end
        if ~im(p1, 3-p2, p3), ke2 = ke2 + vol/d2/2; end
        if ~im(p1, p2, 3-p3), ke3 = ke3 + vol/d3/2; end
        
        if nDirs == 3
            % For 3 directions, the multiplicity is 4, and is canceled by the
            % coefficient 4 in the Crofton formula. We just need to average on
            % directions.
            lut(i) = lut(i) + (ke1 + ke2 + ke3)/3;
            
        elseif nDirs == 13
            % diagonals of rectangular faces
            ke4 = 0; ke5 = 0; ke6 = 0;
            if ~im(3-p1, 3-p2, p3), ke4 = ke4 + vol/d12/2; end
            if ~im(3-p1, p2, 3-p3), ke5 = ke5 + vol/d13/2; end
            if ~im(p1, 3-p2, 3-p3), ke6 = ke6 + vol/d23/2; end
            
            % diagonals of cube
            ke7 = 0;
            if ~im(3-p1, 3-p2, 3-p3), ke7 = ke7 + 1/2*vol/d123; end
            
            % Decomposition of Crofton formula on 13 directions
            lut(i) = lut(i) + 4*(ke1*c1/4 + ke2*c2/4 + ke3*c3/4 + ...
                ke4*c4/2 + ke5*c5/2 + ke6*c6/2 + ke7*c7);
        else
            error ('Sorry, non supported number of directions');
        end
    end
end


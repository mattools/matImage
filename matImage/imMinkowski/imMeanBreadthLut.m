function lut = imMeanBreadthLut(varargin)
%IMMEANBREADTHLUT Look-Up Table for computing mean breadth of a 3D image
%
%   LUT = imMeanBreadthLut
%   Returns an array of size 256, which can be used with function imLUT to
%   create map of contribution to the surface. 
%
%   LUT = imMeanBreadthLut(SCALE)
%   Also specifies size of the elementary tile, in user units (Default is 
%   [1 1 1]).
%
%   LUT = imMeanBreadthLut(SCALE, NDIRS)
%   Also specifies the number of directions used for computing, which can
%   be either 3 (default) or 13. 
%
%   Example
%     % Create a binary image of a ball
%     [x, y, z] = meshgrid(1:100, 1:100, 1:100);
%     IMG = sqrt( (x-50.12).^2 + (y-50.23).^2 + (z-50.34).^2) < 40;
%     % compute surface area of the ball
%     HISTO = imBinaryConfigHisto(IMG);
%     LUT = imMeanBreadthLut(13);
%     B = sum(HISTO .* LUT)
%     B =
%         79.9989
%     % compare with theoretical value
%     Bth = 2*40;
%     100 * (B - Bth) / Bth
%     ans = 
%         -0.0014
%
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
%     imMeanBreadth, imSurfaceLut, imPerimeterLut, imBinaryConfigHisto

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2006-02-23
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%% Extract input parameters

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


%% Constants

% 'magical numbers', corresponding to area of voronoi partition on the
% unit sphere, when germs are the 26 directions in the cube
% Sum of 3*c1+6*c4+4*c7 equals 1.
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

% distance between a voxel and its neighbours.
% di refer to orthogonal neighbours
% dij refer to neighbours on the same plane
% dijk refer to the opposite voxel in a tile
d1  = delta(1);
d2  = delta(2);
d3  = delta(3);
d12 = sqrt(delta(1)^2 + delta(2)^2);
d13 = sqrt(delta(1)^2 + delta(3)^2);
d23 = sqrt(delta(2)^2 + delta(3)^2);
vol = d1*d2*d3;

% area of elementary profiles
a1 = d2*d3;
a2 = d1*d3;
a3 = d1*d2;
a4 = d3*d12;
a5 = d2*d13;
a6 = d1*d23;
s  = (d12+d13+d23)/2;
a7 = 2*sqrt( s*(s-d12)*(s-d13)*(s-d23) );

% correspondance map between voxel label and voxel coord in config
coord = [1 1 1; 1 2 1; 2 1 1; 2 2 1; 1 1 2; 1 2 2; 2 1 2; 2 2 2];


%% Create Look-up Table

% initialize empty arrays
N = 2^(2*2*2); %=256
lut = zeros(N, 1);


% loop for each tile configuration (do not compute first and last ones,
% as they are equal to zero by definition)
for iConfig = 2:N-1
    % create the tile
    im = createTile(iConfig);
    
    % loop for each voxel in the tile
    for iVoxel = 1:8
        % coordinate of voxel of interest
        p1 = coord(iVoxel, 1);
        p2 = coord(iVoxel, 2);
        p3 = coord(iVoxel, 3);
        
        % if voxel is not in structure, contrib is 0
        if im(p1, p2, p3) == 0
            continue;
        end
        
        % create 2D faces in each isothetic direction
        face1 = [im(p1,p2,p3) im(p1,3-p2,p3);im(p1,p2,3-p3) im(p1,3-p2,3-p3)];
        face2 = [im(p1,p2,p3) im(3-p1,p2,p3);im(p1,p2,3-p3) im(3-p1,p2,3-p3)];
        face3 = [im(p1,p2,p3) im(3-p1,p2,p3);im(p1,3-p2,p3) im(3-p1,3-p2,p3)];
        
        % compute contribution of voxel on each 2D face
        f1 = epcPixelConfig2d(face1, 8, delta([3 2]));
        f2 = epcPixelConfig2d(face2, 8, delta([3 1]));
        f3 = epcPixelConfig2d(face3, 8, delta([2 1]));
        
        if nDirs == 3
            % Uses only 3 isothetic directions.
            % divide by 6. Divide by 3 because of averaging on directions,
            % and divide by 2 because each face is visible on 2 config.
            lut(iConfig) = lut(iConfig) + vol*(f1/a1 + f2/a2 + f3/a3)/6;
            
        elseif nDirs == 13
            % create 2D faces for direction normal to square diagonals
            % use only the half
            face4 = [im(p1,p2,p3) im(3-p1,3-p2,p3);im(p1,p2,3-p3) im(3-p1,3-p2,3-p3)];
            face6 = [im(p1,p2,p3) im(3-p1,p2,3-p3);im(p1,3-p2,p3) im(3-p1,3-p2,3-p3)];
            face8 = [im(p1,p2,p3) im(p1,3-p2,3-p3);im(3-p1,p2,p3) im(3-p1,3-p2,3-p3)];
            
            % compute contribution of voxel on each 2D face
            f4 = epcPixelConfig2d(face4, 8, [d12 d3]);
            f6 = epcPixelConfig2d(face6, 8, [d13 d2]);
            f8 = epcPixelConfig2d(face8, 8, [d23 d1]);
            
            % create triangular faces. Reference voxel is the first one,
            facea = [im(p1,p2,p3) im(3-p1,3-p2,p3) im(3-p1,p2,3-p3)];
            faceb = [im(p1,p2,p3) im(3-p1,p2,3-p3) im(p1,3-p2,3-p3)];
            facec = [im(p1,p2,p3) im(3-p1,3-p2,p3) im(p1,3-p2,3-p3)];
            
            % compute contribution of voxel on each triangular face
            fa = epcPixelConfigTriangle(facea, [d12 d13 d23]);
            fb = epcPixelConfigTriangle(faceb, [d13 d23 d12]);
            fc = epcPixelConfigTriangle(facec, [d12 d23 d13]);
            
            % Discretization of Crofton formula, using projected diameters
            % previously computed, weighted by multiplicity.
            lut(iConfig) = lut(iConfig) + ...
                vol*(c1*f1/a1 + c2*f2/a2 + c3*f3/a3)/2 + ...
                vol*(c4*f4/a4 + c5*f6/a5 + c6*f8/a6) + ...
                c7*vol*(fa + fb + fc)/a7;
        else
            error ('Number of directions should be either 3 or 13');
        end
    end
end


%% inner function : epcPixelConfig2d
function contrib = epcPixelConfig2d(im, conn, delta)
%EPCPIXELCONFIG2D compute local 2D contribution to EPC of a voxel
%
%   K = epcPixelConfig2d(IM)
%
%   K = epcPixelConfig2d(IM, CONN)
%   Also specify the connectivity to use. CONN can be either 6 or 26.
%
%   K = epcPixelConfig2d(IM, CONN, SCALE)
%   Compute the local contribution of voxel (1,1) of the tile IM to the
%   total Euler-Poincare charateristic.
%   CONN is the connectivity to use,
%   SCALE is the size of the configuration.
%
%
%   ------
%   Author: David Legland
%   e-mail: david.legland@jouy.inra.fr
%   Created: 2005-11-15
%   Copyright 2005 INRA - CEPIA Nantes - MIAJ Jouy-en-Josas.


% if voxel is not in structure, contrib is 0
if im(1, 1)==0
    contrib = 0;
    return;
end

% note : all curvatures are divided by 2*pi to use only epc contributions
if conn==4    
    % if square face, contribute for 1/4, otherwise does not contribute
    kf = (sum(im(:))==4)/4;    
     
    ke1 = 0;
    if im(2, 1), ke1 = ke1+1/2; end
    if im(1, 2), ke1 = ke1+1/2; end        
    
    % contribution of vertex - contribution of edges + contrib of face
    contrib = 1/4 - ke1/2 + kf;   
   
elseif conn==8    
    n = sum(im(:));
    
    if n==4
        contrib=0;
    elseif n==3        
        if im(2, 2)
            % case of a triangle viewed from acute angle
            % contribution depends on this angle            
            d1 = delta(1); d2 = delta(2);
            if im(2, 1)
                alpha = atan2(d2, d1);
            else
                alpha = atan2(d1, d2);
            end             
            
            % contribution is decomposed as follows :
            % +1 vertex, shared by 4 tiles
            % -1 edge shared bhy 2 tiles
            % -1 edge shared by 1 tile (sum of edges is -3/4)
            % +face contribution, shared by 1 tile.
            contrib = 1/4 - 3/4 + (pi-alpha)/(2*pi);
            
        else
            % case of a triangle viewed from rectangular angle -> 0
            contrib=0;
        end
        
    elseif n==2
        % find diagonal edges around current voxel
        % If there is one diagonal edge, contribution is  1/4-1/2   = -1/4
        % If there is one isothetic edge, contribution is 1/4-1/2/2 = 0
        % (edge is shared with another configuration)        
        contrib = 0;
        if im(2, 2), contrib = -1/4; end
        
    elseif n==1
        contrib = 1/4;
    end
    
    return;
else
    error('non supported connectivity');
end


%% inner function : epcPixelConfigTriangle
function contrib = epcPixelConfigTriangle(pixels, delta)
%EPCPIXELCONFIGTRIANGLE compute local 2D contribution to EPC of a voxel
%
%   K = epcPixelConfigTriangle(PIXELS, SCALE)
%   Compute the local contribution of first voxel to the total
%   Euler-Poincare charateristic.
%   PIXELS is a set of 3 pixels, and SCALE, by default equal to [1 1 1], is
%   the size of the triangle.
%   SCALE(1) = distance between voxel 1 and 2
%   SCALE(2) = distance between voxel 1 and 3
%   SCALE(3) = distance between voxel 2 and 3
%
%   ------
%   Author: David Legland
%   e-mail: david.legland@jouy.inra.fr
%   Created: 2005-11-15
%   Copyright 2005 INRA - CEPIA Nantes - MIAJ Jouy-en-Josas.

% if voxel is not in structure, contrib is 0
if pixels(1) == 0 
    contrib = 0;
    return;
end

% note: all curvatures are divided by 2*pi to use only epc contributions
n = sum(pixels(:));
if n == 3
    % compute angle of facet from cosine low
    d1 = delta(1); d2 = delta(2); d3 = delta(3);
    alpha = acos((d1*d1 + d2*d2 - d3*d3)/(2*d1*d2));    
    contrib = 1/6 - 1/2 + (pi-alpha)/(2*pi);

elseif n == 2
    % contribution can be divided as :
    % +1/6  for the vertex
    % -1/2/2 for the edge (multiplicity = 2)
    % result is -1/12.
    contrib = -1/12;

elseif n == 1
    % only the contribution of the voxel, shared by 6 tiles
    contrib = 1/6;
end
    

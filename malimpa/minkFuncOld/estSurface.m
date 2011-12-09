function surf = estSurface(img, varargin)
%ESTSURFACE estimate surface measure of a discretized 3D set
%
%   usage :
%   S = estSurface(IMG);
%   return an estimate of the surface area of the image, computed by
%   counting intersections with 3D lines, and using discretized version of
%   the Crofton formula.
%
%   S = estSurface(IMG, CONN);
%   Specify connecitvity to use. Either 6 or 26.
%
%   S = estSurface(IMG, CONN, SCALE);
%   Also specify scale of image tile. SCALE si a 3x1 array.
%
%   No edge correction is performed. If a structure touches image border,
%   some of the intersections with lines will not be counted.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/07/2005.
%

%   HISTORY
%   24/02/2006 add support for scale
%   09/01/2007 update doc for no edge correction

img = squeeze(img>0);

% check inpu is valid
if ndims(img)~=3
    error('first argument should be a 3D array');
end

% default connectivity
conn=6;
if ~isempty(varargin)
    conn = varargin{1};
end

% default pixel size
delta = [1 1 1];
if length(varargin)>1
    delta = varargin{2};
end


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

% size of image
dim = size(img);
D1 = dim(1);
D2 = dim(2);
D3 = dim(3);

% first compute number of intersections in the 3 main directions
n1 = sum(sum(sum(img(1:D1-1,:,:) ~= img(2:D1,:,:)))) ;
n2 = sum(sum(sum(img(:,1:D2-1,:) ~= img(:,2:D2,:)))) ;
n3 = sum(sum(sum(img(:,:,1:D3-1) ~= img(:,:,2:D3)))) ;

% compute surface area for 6 closest neighbours
if conn==6
    surf = mean([n1*d2*d3 n2*d1*d3 n3*d1*d2])*2;
    return;
end

% check the 6 directions orthogonal to only one axis
n4 = sum(sum(sum(img(1:D1-1, 1:D2-1, :) ~= img(2:D1, 2:D2, :)   ))) ;
n5 = sum(sum(sum(img(1:D1-1, 2:D2,   :) ~= img(2:D1, 1:D2-1, :) ))) ;
n6 = sum(sum(sum(img(1:D1-1, :, 1:D3-1) ~= img(2:D1, :, 2:D3)   ))) ;
n7 = sum(sum(sum(img(1:D1-1, :, 2:D3)   ~= img(2:D1, :, 1:D3-1) ))) ;
n8 = sum(sum(sum(img(:, 1:D2-1, 1:D3-1) ~= img(:, 2:D2, 2:D3)   ))) ;
n9 = sum(sum(sum(img(:, 1:D2-1, 2:D3)   ~= img(:, 2:D2, 1:D3-1) ))) ;


% then check the 4 diagonal directions  (count from a to d, as in
% hexadecimal form)
na = sum(sum(sum(img(1:D1-1, 1:D2-1, 1:D3-1) ~= img(2:D1, 2:D2,   2:D3)   ))) ;
nb = sum(sum(sum(img(1:D1-1, 1:D2-1, 2:D3)   ~= img(2:D1, 2:D2,   1:D3-1) ))) ;
nc = sum(sum(sum(img(1:D1-1, 2:D2,   1:D3-1) ~= img(2:D1, 1:D2-1, 2:D3)   ))) ;
nd = sum(sum(sum(img(1:D1-1, 2:D2,   2:D3)   ~= img(2:D1, 1:D2-1, 1:D3-1) ))) ;


% 'magical numbers', corresponding to area of voronoi partition on the
% unit sphere, when germs are the 26 directions in the cube
% Sum of 6*c1+12*c2+8*c3 equals .5.
c1 = 0.0457778912;
c2 = 0.0369806279;
c3 = 0.0351956398;

% compute surface area by weighted average over the 13 directions
surf = 4*( ...
    (n1*d2*d3 + n2*d1*d3 + n3*d1*d2)*c1 + ...
    (n4/d12 + n5/d12 + n6/d13 + n7/d13 + n8/d23 + n9/d23)*vol*c2 + ...
    (na + nb + nc + nd)*c3*vol/d123 );



function norm = estMeanBreadth(img, varargin)
%ESTMEANBREADTH estimate mean breadth of a discretized set
%
%
%   usage :
%   MB = estMeanBreadth(IMG);
%   return an estimate of the mean breadth, computed using a discretization
%   of Crofton formula.
%
%   MB = estMeanBreadth(IMG, CONN);
%   Specify connecivity used. Currently 6 and 26 connectivities are
%   supported.
%
%   MB = estMeanBreadth(IMG, CONN, SCALE);
%   Also specify scale of image tile. SCALE si a 3x1 array.
%
%   No edge effect is processed. For structures which touch edges of image,
%   adding zeros around the image will return the same measure of mean
%   breadth.
%
%   The mean breadth is proportional to the integral of mean curvature,
%   also called 'Norm' M (See Serra, 'Image Analysis and Morphology,
%   p.104), and to the 3d Minkowski functional w3, with relations:
%   M  = 2*pi*MB
%   W3 = 2*pi/3*MB
%   
%
%   See Also :
%   minkowski, estSurface, estEuler, epc, tpl
%   
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/07/2005.
%

%   HISTORY
%   27/02/2006 add support for scale
%   11/01/2007 add doc to explain that edge effects are not processed


img = squeeze(img>0);

if ndims(img)~=3
    error('first argument should be a 3D array');
end

conn=6;
if ~isempty(varargin)
    conn = varargin{1};
end

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
vol = d1*d2*d3;

% size of image
dim = size(img);
D1 = dim(1);
D2 = dim(2);
D3 = dim(3);


% area of elementary profiles
a1 = d2*d3;
a2 = d1*d3;
a3 = d1*d2;
a4 = d3*d12;
a5 = d2*d13;
a6 = d1*d23;
s  = (d12+d13+d23)/2;
a7 = 2*sqrt( s*(s-d12)*(s-d13)*(s-d23) );



%% Compute number of intersections in the 3 main directions

% total number of vertices in image
n = sum(img(:));



% count number of intersections in all directions
e1 = sum(sum(sum(img(1:D1-1,:,:) & img(2:D1,:,:))));
e2 = sum(sum(sum(img(:,1:D2-1,:) & img(:,2:D2,:))));
e3 = sum(sum(sum(img(:,:,1:D3-1) & img(:,:,2:D3))));

% count number of square faces in all directions
f1 = sum(sum(sum( ...
    img(:,1:D2-1,1:D3-1) & img(:,1:D2-1,2:D3) & ...
    img(:,2:D2,1:D3-1)   & img(:,2:D2,2:D3)   )));
f2 = sum(sum(sum( ...
    img(1:D1-1,:,1:D3-1) & img(1:D1-1,:,2:D3) & ...
    img(2:D1,:,1:D3-1)   & img(2:D1,:,2:D3)   )));
f3 = sum(sum(sum( ...
    img(1:D1-1,1:D2-1,:) & img(1:D1-1,2:D2,:) & ...
    img(2:D1,1:D2-1,:)   & img(2:D1,2:D2,:)   )));


%% Compute for 6 closest neighbours
if conn==6
    % measure diameter on each isothetic direction
    chi1 = (n - e2 - e3 + f1)/a1;
    chi2 = (n - e1 - e3 + f2)/a2;
    chi3 = (n - e1 - e2 + f3)/a3;
    
    % use discrete version of crofton formula :
    norm = (chi1 + chi2 + chi3)*vol/3;
    
    % In the orthonormal case (d1==d2=d3), it is possible
    % to rearrange terms and to reduce number of operations :
    % norm = n + (-2*e1 - 2*e2 - 2*e3 + f1 + f2 + f3)/3;
    return;
end

%% Continue for 26 neighbours : count edges and faces in other directions

% check the 6 directions orthogonal to only one axis
e4 = sum(sum(sum(img(1:D1-1, 1:D2-1, :) & img(2:D1, 2:D2, :)   ))) ;
e5 = sum(sum(sum(img(1:D1-1, 2:D2,   :) & img(2:D1, 1:D2-1, :) ))) ;
e6 = sum(sum(sum(img(1:D1-1, :, 1:D3-1) & img(2:D1, :, 2:D3)   ))) ;
e7 = sum(sum(sum(img(1:D1-1, :, 2:D3)   & img(2:D1, :, 1:D3-1) ))) ;
e8 = sum(sum(sum(img(:, 1:D2-1, 1:D3-1) & img(:, 2:D2, 2:D3)   ))) ;
e9 = sum(sum(sum(img(:, 1:D2-1, 2:D3)   & img(:, 2:D2, 1:D3-1) ))) ;


% count number of square faces in 6 directions orthogonal to one axis
f4 = sum(sum(sum( ...
    img(1:D1-1,2:D2,1:D3-1) & img(2:D1,1:D2-1,1:D3-1) & ...
    img(2:D1,1:D2-1,2:D3)   & img(1:D1-1,2:D2,2:D3)   )));
f5 = sum(sum(sum( ...
    img(1:D1-1,1:D2-1,1:D3-1) & img(2:D1,2:D2,1:D3-1) & ...
    img(1:D1-1,1:D2-1,2:D3)   & img(2:D1,2:D2,2:D3)   )));

f6 = sum(sum(sum( ...
    img(2:D1,1:D2-1,1:D3-1) & img(1:D1-1,1:D2-1,2:D3) & ...
    img(2:D1,2:D2,1:D3-1)   & img(1:D1-1,2:D2,2:D3)   )));
f7 = sum(sum(sum( ...
    img(1:D1-1,1:D2-1,1:D3-1) & img(2:D1,1:D2-1,2:D3) & ...
    img(1:D1-1,2:D2,1:D3-1)   & img(2:D1,2:D2,2:D3)   )));

f8 = sum(sum(sum( ...
    img(1:D1-1,1:D2-1,2:D3) & img(1:D1-1,2:D2,1:D3-1) & ...
    img(2:D1,1:D2-1,2:D3)   & img(2:D1,2:D2,1:D3-1)   )));
f9 = sum(sum(sum( ...
    img(1:D1-1,1:D2-1,1:D3-1) & img(1:D1-1,2:D2,2:D3) & ...
    img(2:D1,1:D2-1,1:D3-1)   & img(2:D1,2:D2,2:D3)   )));

% number of triangular faces orthogonal to each of the 4 cube diagonal
fa = sum(sum(sum( ...
    img(2:D1, 1:D2-1, 2:D3) & img(1:D1-1, 2:D2, 2:D3) & ...
    img(2:D1, 2:D2, 1:D3-1)    ))) + sum(sum(sum( ...
    img(2:D1, 1:D2-1, 1:D3-1) & img(1:D1-1, 1:D2-1, 2:D3) & ...
    img(1:D1-1, 2:D2, 1:D3-1)    ))) ;

fb = sum(sum(sum( ...
    img(1:D1-1, 1:D2-1, 2:D3) & img(2:D1, 2:D2, 2:D3) & ...
    img(1:D1-1, 2:D2, 1:D3-1)    ))) + sum(sum(sum( ...
    img(2:D1, 1:D2-1, 2:D3) & img(2:D1, 2:D2, 1:D3-1) & ...
    img(1:D1-1, 1:D2-1, 1:D3-1)    ))) ;

fc = sum(sum(sum( ...
    img(1:D1-1, 1:D2-1, 1:D3-1) & img(2:D1, 2:D2, 1:D3-1) & ...
    img(1:D1-1, 2:D2, 2:D3)    ))) + sum(sum(sum( ...
    img(1:D1-1, 1:D2-1, 2:D3) & img(2:D1, 1:D2-1, 1:D3-1) & ...
    img(2:D1, 2:D2, 2:D3)    ))) ;

fd = sum(sum(sum( ...
    img(1:D1-1, 1:D2-1, 1:D3-1) & img(2:D1, 1:D2-1, 2:D3) & ...
    img(1:D1-1, 2:D2, 2:D3)    ))) + sum(sum(sum( ...
    img(2:D1, 1:D2-1, 1:D3-1) & img(2:D1, 2:D2, 2:D3) & ...
    img(1:D1-1, 2:D2, 1:D3-1)    ))) ;

%% Compute mean breadth by discretizing Crofton formula

% compute the equivalent diameter in each discrete direction, 
% using the 4 connectivity
chi1 = (n - e2 - e3 + f1);
chi2 = (n - e1 - e3 + f2);
chi3 = (n - e1 - e2 + f3);

chi4 = (n - e5 - e3 + f4);
chi5 = (n - e4 - e3 + f5);
chi6 = (n - e7 - e2 + f6);
chi7 = (n - e6 - e2 + f7);
chi8 = (n - e9 - e1 + f8);
chi9 = (n - e8 - e1 + f9);

chia = (n - e5 - e7 - e9 + fa);
chib = (n - e4 - e6 - e9 + fb);
chic = (n - e4 - e7 - e8 + fc);
chid = (n - e5 - e6 - e8 + fd);

% 'magical numbers', corresponding to area of voronoi partition on the
% unit sphere, when germs are the 26 directions in the cube
% Sum of 6*c1+12*c2+8*c3 equals 1.
c1 = 0.0457778912*2;
c2 = 0.0369806279*2;
c3 = 0.0351956398*2;

% Discretization of Crofton formula, using diameters previously computed
norm =  c1*vol*(chi1/a1 + chi2/a2 + chi3/a3) + ...
        c2*vol*(chi4/a4 + chi5/a4 + chi6/a5 + chi7/a5 + chi8/a6 + chi9/a6) + ...
        c3*vol*(chia + chib + chic + chid)/a7;

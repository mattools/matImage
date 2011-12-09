function varargout = sphericalCapsAreaC26(varargin)
%SPHERICALCAPSAREAC26 compute area of spherical caps on the unit sphere
%
%   AREA = sphericalCapsAreaC26
%   Compute the area of the spherical caps associated to the voronoi
%   diagram on the unit sphere, when the germs correspond to the 26
%   discrete directions in the unit cube.
%   Result is a 1x3 array, containing fraction of area of each type of
%   spherical cap.
%   area(1) concerns directions of 6 neighbourhood
%   area(2) concerns diagonals of square face (18 neigbourhood)
%   area(3) concerns diagonals of cube (26 neighbourhood)
%
%   Result is formatted such that 6*area(1)+12*area(2)+8*area(3)=1.
%
%   AREA = sphericalCapsAreaC26(DELTA)
%   where DELTA = [DELTA1 DELTA2 DELTA3] with the DELTAI being the
%   resolutions in the 3 main directions, computes a vector of 13 elements
%   correspondig to 13 main directions.
%   AREA(1) to AREA(3) correspond to orthogonal directions
%   AREA(4) to AREA(9) correspond to directions of planes diagonals
%   AREA(10) to AREA(13) correspond to directions of cubic diagonals
%   Note that there is equality between AREA(4) and AREA(5), AREA(6) and
%   AREA(7), AREA(8) and AREA(9), and AREA(10) to AREA(13).
%   The sum of elements in AREA equals 0.5
%
%
%   Algorithm :
%   - separate 3 basic case, corresponding on the type of directions
%   - for each cases, specify manually germ and neighbours
%   - compute great circle between each couple of germ
%   - compute intersection points of these circles
%   - sort intersection points around the central germ, giving a spherical
%      polygon
%   - compute triangulation of the resulting polygon
%   - compute spherical area of each triangle
%   - and area of each polygon
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY
%   27/04/2007 extends to non uniform grid spacing


%% Initializations

% grid resolution
delta = [1 1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% poins in the 26 discrete directions
%pt000 = normalize([-1 -1 -1].*delta);
%pt100 = normalize([ 0 -1 -1].*delta);
pt200 = normalize([+1 -1 -1].*delta);
%pt010 = normalize([-1  0 -1].*delta);
%pt110 = normalize([ 0  0 -1].*delta);
pt210 = normalize([+1  0 -1].*delta);
pt020 = normalize([-1 +1 -1].*delta);
pt120 = normalize([ 0 +1 -1].*delta);
pt220 = normalize([+1 +1 -1].*delta);

%pt001 = normalize([-1 -1  0].*delta);
%pt101 = normalize([ 0 -1  0].*delta);
pt201 = normalize([+1 -1  0].*delta);
%pt011 = normalize([-1  0  0].*delta);
%pt111 = [ 0  0  0];             % origin point
pt211 = normalize([+1  0  0].*delta);
pt021 = normalize([-1 +1  0].*delta);
pt121 = normalize([ 0 +1  0].*delta);
pt221 = normalize([+1 +1  0].*delta);

pt002 = normalize([-1 -1 +1].*delta);
pt102 = normalize([ 0 -1 +1].*delta);
pt202 = normalize([+1 -1 +1].*delta);
pt012 = normalize([-1  0 +1].*delta);
pt112 = normalize([ 0  0 +1].*delta);
pt212 = normalize([+1  0 +1].*delta);
pt022 = normalize([-1 +1 +1].*delta);
pt122 = normalize([ 0 +1 +1].*delta);
pt222 = normalize([+1 +1 +1].*delta);

% basic unit sphere
sphere = [0 0 0  1];


%% Spherical cap type 1 direction [1 0 0]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Ox axis, i.e. a point
% in the 6-neighboorhoud of the center.
centre1 = pt211;
% neighbours of chosen point, sorted by angle
voisins1 = [pt200;pt201;pt202;pt212;pt222;pt221;pt220;pt210];
n1 = size(voisins1, 1);

% compute separating circles
planes1 = zeros(n1, 9);
for i=1:n1
    planes1(i,1:9) = normalizePlane(medianPlane(centre1, voisins1(i,:)));
%    circles1(i,1:7) = intersectPlaneSphere(planes1(i,:), sphere);
end

% compute circle intersections
lines1 = zeros(n1, 6);
for i=1:n1
    lines1(i,1:6) = intersectPlanes(planes1(i,:), ...
        planes1(mod(i,n1)+1,:));
    points1(2*i-1:2*i,1:3) = intersectLineSphere(lines1(i,:), sphere);
end

% keep only points with x>0
ind = dot(points1, repmat(centre1, [2*n1 1]), 2)>0;
points1 = points1(ind,:);
n1 = size(points1, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles1 = zeros(n1, 1);
for i=1:n1
    pt1 = points1(i, :);
    pt2 = points1(mod(i  , n1)+1, :);
    pt3 = points1(mod(i+1, n1)+1, :);
    
    angles1(i) = sphericalAngle(pt1, pt2, pt3); 
end

% compute area of spherical polygon
area1 = sum(angles1)-pi*(n1-2);


%% Spherical cap type 1 direction [0 1 0]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oy axis, i.e. a point
% in the 6-neighboorhoud of the center.
centre1 = pt121;
% neighbours of chosen point, sorted by angle
%voisins1 = [pt200;pt201;pt202;pt212;pt222;pt221;pt220;pt210];
voisins1 = [pt221;pt222;pt122;pt022;pt021;pt020;pt120;pt220];
n1 = size(voisins1, 1);

% compute separating circles
planes1 = zeros(n1, 9);
for i=1:n1
    planes1(i,1:9) = normalizePlane(medianPlane(centre1, voisins1(i,:)));
%    circles1(i,1:7) = intersectPlaneSphere(planes1(i,:), sphere);
end

% compute circle intersections
lines1 = zeros(n1, 6);
for i=1:n1
    lines1(i,1:6) = intersectPlanes(planes1(i,:), ...
        planes1(mod(i,n1)+1,:));
    points1(2*i-1:2*i,1:3) = intersectLineSphere(lines1(i,:), sphere);
end

% keep only points with x>0
ind = dot(points1, repmat(centre1, [2*n1 1]), 2)>0;
points1 = points1(ind,:);
n1 = size(points1, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles1 = zeros(n1, 1);
for i=1:n1
    pt1 = points1(i, :);
    pt2 = points1(mod(i  , n1)+1, :);
    pt3 = points1(mod(i+1, n1)+1, :);
    
    angles1(i) = sphericalAngle(pt1, pt2, pt3); 
end

% compute area of spherical polygon
area2 = sum(angles1)-pi*(n1-2);


%% Spherical cap type 1 direction [0 0 1]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oz axis, i.e. a point
% in the 6-neighboorhoud of the center.
centre1 = pt112;
% neighbours of chosen point, sorted by angle
%voisins1 = [pt200;pt201;pt202;pt212;pt222;pt221;pt220;pt210];
voisins1 = [pt212;pt222;pt122;pt022;pt012;pt002;pt102;pt202];
n1 = size(voisins1, 1);

% compute separating circles
planes1 = zeros(n1, 9);
for i=1:n1
    planes1(i,1:9) = normalizePlane(medianPlane(centre1, voisins1(i,:)));
%    circles1(i,1:7) = intersectPlaneSphere(planes1(i,:), sphere);
end

% compute circle intersections
lines1 = zeros(n1, 6);
for i=1:n1
    lines1(i,1:6) = intersectPlanes(planes1(i,:), ...
        planes1(mod(i,n1)+1,:));
    points1(2*i-1:2*i,1:3) = intersectLineSphere(lines1(i,:), sphere);
end

% keep only points with z>0
ind = dot(points1, repmat(centre1, [2*n1 1]), 2)>0;
points1 = points1(ind,:);
n1 = size(points1, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles1 = zeros(n1, 1);
for i=1:n1
    pt1 = points1(i, :);
    pt2 = points1(mod(i  , n1)+1, :);
    pt3 = points1(mod(i+1, n1)+1, :);
    
    angles1(i) = sphericalAngle(pt1, pt2, pt3);
    angles1(i) = min(angles1(i), 2*pi-angles1(i));
end

% compute area of spherical polygon
area3 = sum(angles1)-pi*(n1-2);



%% Spherical cap type 2, direction [1 1 0]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oxy plane, i.e. a point
% in the 18-neighborhood
centre2 = pt221;
% neighbours of chosen point, sorted by angle
voisins2 = [pt211;pt222;pt121;pt220];
n2 = size(voisins2, 1);

% compute separating circles
planes2 = zeros(n2, 9);
for i=1:n2
    planes2(i,1:9) = normalizePlane(medianPlane(centre2, voisins2(i,:)));
    %circles2(i,1:7) = intersectPlaneSphere(planes2(i,:), sphere);
end

% compute circle intersections
lines2 = zeros(n2, 6);
for i=1:n2
    lines2(i,1:6) = intersectPlanes(planes2(i,:), ...
        planes2(mod(i,n2)+1,:));
    points2(2*i-1:2*i,1:3) = intersectLineSphere(lines2(i,:), sphere);
end

% keep only points with x>0
ind = dot(points2, repmat(centre2, [2*n2 1]), 2)>0;
points2 = points2(ind,:);
n2 = size(points2, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles2 = zeros(n2, 1);
for i=1:n2
    pt1 = points2(i, :);
    pt2 = points2(mod(i  , n2)+1, :);
    pt3 = points2(mod(i+1, n2)+1, :);
    
    angles2(i) = sphericalAngle(pt1, pt2, pt3);
    angles2(i) = min(angles2(i), 2*pi-angles2(i));
end

% compute area of spherical polygon
area4 = sum(angles2)-pi*(n2-2);


%% Spherical cap type 2, direction [1 0 1]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oxz plane, i.e. a point
% in the 18-neighborhood
centre2 = pt212;
% neighbours of chosen point, sorted by angle
%voisins2 = [pt211;pt222;pt121;pt220];
voisins2 = [pt211;pt222;pt112;pt202];
n2 = size(voisins2, 1);

% compute separating circles
planes2 = zeros(n2, 9);
for i=1:n2
    planes2(i,1:9) = normalizePlane(medianPlane(centre2, voisins2(i,:)));
    %circles2(i,1:7) = intersectPlaneSphere(planes2(i,:), sphere);
end

% compute circle intersections
lines2 = zeros(n2, 6);
for i=1:n2
    lines2(i,1:6) = intersectPlanes(planes2(i,:), ...
        planes2(mod(i,n2)+1,:));
    points2(2*i-1:2*i,1:3) = intersectLineSphere(lines2(i,:), sphere);
end

% keep only points with x>0
ind = dot(points2, repmat(centre2, [2*n2 1]), 2)>0;
points2 = points2(ind,:);
n2 = size(points2, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles2 = zeros(n2, 1);
for i=1:n2
    pt1 = points2(i, :);
    pt2 = points2(mod(i  , n2)+1, :);
    pt3 = points2(mod(i+1, n2)+1, :);
    
    angles2(i) = sphericalAngle(pt1, pt2, pt3);
    angles2(i) = min(angles2(i), 2*pi-angles2(i));
end

% compute area of spherical polygon
area5 = sum(angles2)-pi*(n2-2);


%% Spherical cap type 2, direction [0 1 1]
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oxy plane, i.e. a point
% in the 18-neighborhood
centre2 = pt122;
% neighbours of chosen point, sorted by angle
voisins2 = [pt121;pt022;pt112;pt222];
n2 = size(voisins2, 1);

% compute separating circles
planes2 = zeros(n2, 9);
for i=1:n2
    planes2(i,1:9) = normalizePlane(medianPlane(centre2, voisins2(i,:)));
    %circles2(i,1:7) = intersectPlaneSphere(planes2(i,:), sphere);
end

% compute circle intersections
lines2 = zeros(n2, 6);
for i=1:n2
    lines2(i,1:6) = intersectPlanes(planes2(i,:), ...
        planes2(mod(i,n2)+1,:));
    points2(2*i-1:2*i,1:3) = intersectLineSphere(lines2(i,:), sphere);
end

% keep only points with x>0
ind = dot(points2, repmat(centre2, [2*n2 1]), 2)>0;
points2 = points2(ind,:);
n2 = size(points2, 1);

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles2 = zeros(n2, 1);
for i=1:n2
    pt1 = points2(i, :);
    pt2 = points2(mod(i  , n2)+1, :);
    pt3 = points2(mod(i+1, n2)+1, :);
    
    angles2(i) = sphericalAngle(pt1, pt2, pt3);
    angles2(i) = min(angles2(i), 2*pi-angles2(i));
end

% compute area of spherical polygon
area6 = sum(angles2)-pi*(n2-2);



%% Spherical cap type 3 (all cubic diagonals)
% ----------------------------------------------------------------------

% Compute area of voronoi cell for a point on the Oxyz diagonal, i.e. a
% point in the 26 neighbourhood only
centre3 = pt222;
% neighbours of chosen point, sorted by angle
voisins3 = [pt212;pt112;pt122;pt121;pt221;pt211];
n3 = size(voisins3, 1);

% compute separating circles
planes3 = zeros(n3, 9);
for i=1:n3
    planes3(i,1:9) = normalizePlane(medianPlane(centre3, voisins3(i,:)));
    %circles3(i,1:7) = intersectPlaneSphere(planes3(i,:), sphere);
end

% compute circle intersections
lines3 = zeros(n3, 6);
for i=1:n3
    lines3(i,1:6) = intersectPlanes(planes3(i,:), ...
        planes3(mod(i,n3)+1,:));
    points3(2*i-1:2*i,1:3) = intersectLineSphere(lines3(i,:), sphere);
end

% keep only points with x>0
ind = dot(points3, repmat(centre3, [2*n3 1]), 2)>0;
points3 = points3(ind,:);
n3 = size(points3, 1);

% % Create 3D circle arc, for display
% for i=1:n3
%     angle1 = circle3dPosition(points3(mod(i+n3-2,n3)+1,:), circles3(i,:));
%     angle2 = circle3dPosition(points3(i,:), circles3(i,:));
%     
%     arcs3(i,1:9) = [circles3(i,:) angle1 angle2];
% end
% 

% compute spherical area of each triangle [center  pt[i+1]%4   pt[i] ]
angles3 = zeros(n3, 1);
for i=1:n3
    pt1 = points3(i, :);
    pt2 = points3(mod(i  , n3)+1, :);
    pt3 = points3(mod(i+1, n3)+1, :);
    
    angles3(i) = sphericalAngle(pt1, pt2, pt3); 
end

% compute area of spherical polygon
area7 = sum(angles3)-pi*(n3-2);



%% Results
% -------------------------------------------------------------------

% return computed areas, formatted as fraction of sphere surface
if nargout==0
    % display some results
    disp('results : ')
    pattern = 'area of cell in %02d-neighbourhood : %12.10f sr, = %12.10f %%';
    disp(sprintf(pattern,  6, area1, area1*100/4/pi));
    disp(sprintf(pattern, 18, area4, area4*100/4/pi));
    disp(sprintf(pattern, 26, area7, area7*100/4/pi));

    varargout{1} = [area1 area4 area7]/4/pi;
elseif nargout == 1
    varargout{1} = [...
        area1 area2 area3 ...
        area4 area4 area5 area5 area6 area6...
        area7 area7 area7 area7...
        ]/4/pi;
elseif nargout == 7
    varargout{1} = area1/4/pi;
    varargout{2} = area2/4/pi;
    varargout{3} = area3/4/pi;
    varargout{4} = area4/4/pi;
    varargout{5} = area5/4/pi;
    varargout{6} = area6/4/pi;
    varargout{7} = area7/4/pi;
end


%% Internal functions
% -------------------------------------------------------------------
% This functions are part of a more general geometric library, but are
% included here for avoiding dependencies

function theta = angle3Points(varargin)
%ANGLE3POINTS return oriented angle made by 3 points
%
%   ALPHA = ANGLE3POINTS(P1, P2, P3).
%   Pi are either [1*2] arrays, or [N*2] arrays, in this case ALPHA is a 
%   [N*1] array. The angle computed is the directed angle between line 
%   (P2P1) and line (P2P3).
%   Result is always given in radians, between 0 and 2*pi.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 23/02/2004.
%

%   HISTORY :
%   25/09/2005 : enable single parameter

if length(varargin)==3
    p1 = varargin{1};
    p2 = varargin{2};
    p3 = varargin{3};
elseif length(varargin)==1
    var = varargin{1};
    p1 = var(1,:);
    p2 = var(2,:);
    p3 = var(3,:);
end    

% angle line (P2 P1)
theta = lineAngle(createLine(p2, p1), createLine(p2, p3));



function line = createLine(varargin)
%CREATELINE create a line with various inputs.
%
%   Line is represented in a parametric form : [x0 y0 dx dy]
%   x = x0 + t*dx
%   y = y0 + t*dy;
%
%
%   l = CREATELINE(p1, p2) return the line going through the two given
%   points.
%   
%   l = CREATELINE(x0, y0, dx, dy) the line going through point (x0, y0)
%   and with direction vector(dx, dy).
%
%   l = CREATELINE(param) where param is an array of 4 values, create the
%   line oing through the point (param(1) param(2)), and with direction
%   vector (param(3) param(4)).
%   
%   l = CREATELINE(theta) create a line originated at (0,0) and
%   with angle theta.
%
%   l = CREATELINE(rho, theta) create a line with normal theta, and with
%   min distance to origin equal to rho. rho can be negative, in this case,
%   the line is the same as with CREATELINE(-rho, theta+pi), but the
%   orientation is different.
%
%
%   Note : in all cases, parameters can be vertical arrays of the same
%   dimension. The result is then an array of lines, of dimensions [N*4].
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

if length(varargin)==1
    % Only one input parameter. It can be :
    % - line angle
    % - array of four parameters
    var = varargin{1};
    
    if size(var, 2)==4
        % 4 parameters of the line in a single array.
        line = var;
    elseif size(var, 2)==1
        % 1 parameter : angle of the line, going through origin.
        line = [zeros(size(var)) zeros(size(var)) cos(var) sin(var)];
    else
        error('wrong number of dimension for arg1 : can be 1 or 4');
    end
    
elseif length(varargin)==2    
    % 2 input parameters. They can be :
    % - line angle and signed distance to origin.
    % - 2 points, then 2 arrays of 1*2 double.
    v1 = varargin{1};
    v2 = varargin{2};
    if size(v1, 2)==1
        % first param is angle of line, and second param is signed distance
        % to origin.
        line = [v1.*cos(v2) v1.*sin(v2) -sin(v2) cos(v2)];
    else
        % first input parameter is first point, and second input is the
        % second point.
        line = [v1(:,1), v1(:,2), v2(:,1)-v1(:,1), v2(:,2)-v1(:,2)];    
    end
    
elseif length(varargin)==3
    % 3 input parameters :
    % first one is a point belonging to the line,
    % second and third ones are direction vector of the line (dx and dy).
    p = varargin{1};
    line = [p(:,1) p(:,2) varargin{2} varargin{3}];
   
elseif length(varargin)==4
    % 4 input parameters :
    % they are x0, y0 (point belongng to line) and dx, dy (direction vector
    % of the line).
    % All parameters should have the same size.
    line = [varargin{1} varargin{2} varargin{3} varargin{4}];
else
    error('Wrong number of arguments in ''createLine'' ');
end

function plane = createPlane(varargin)
%CREATEPLANE create a plane in parametrized form
%
%   Create a plane in the following format : 
%   PLANE = [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%   
%
%
%   PLANE = createPlane(P1, P2, P3) 
%   create a plane containing the 3 points
%
%   PLANE = createPlane(PTS) 
%   The 3 points are packed into a single 3x3 array.
%
%   PLANE = createPlane(P0, N);
%   create a plane from a point and from a normal to the plane.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY :
%   24/11/2005 : add possibility to pack points for plane creation

if length(varargin)==1
    var = varargin{1};
    
    if iscell(var)
        plane = zeros(length(var), 9);
        for i=1:length(var)
            plane(i,:) = createPlane(var{i});
        end
    elseif size(var, 1)==3
        % 3 points in a single array
        p1 = var(1,:);
        p2 = var(2,:);
        p3 = var(3,:);
        
        % create direction vectors
        v1 = p2-p1;
        v2 = p3-p1;

        % create plane
        plane = [p1 v1 v2];
        return;
    end
    
elseif length(varargin)==2
    
    p0 = varargin{1};
    
    var = varargin{2};
    if size(var, 2)==2
        n = sph2cart2([var repmat(1, [size(var, 1) 1])]);
    elseif size(var, 2)==3
        n  = normalize3d(var);
    else
        error ('wrong number of parameters in createPlane');
    end
    
    % find a vector not colinear to the normal
    v0 = repmat([1 0 0], [size(p0, 1) 1]);    
    if abs(cross(n, v0, 2))<1e-14
        v0 = repmat([0 1 0], [size(p0, 1) 1]);
    end
    
    % create direction vectors
    v1 = normalize3d(cross(n, v0, 2));
    v2 = -normalize3d(cross(v1, n, 2));
    
    plane = [p0 v1 v2];
    return;
    
elseif length(varargin)==3
    p1 = varargin{1};    
    p2 = varargin{2};
    p3 = varargin{3};
    
    % create direction vectors
    v1 = p2-p1;
    v2 = p3-p1;
   
    plane = [p1 v1 v2];
    return;
  
else
    error('wrong number of arguments in "createPlane".');
end


function point = intersectLineSphere(line, sphere)
%INTERSECTLINESPHERE return intersection between a line and a sphere
%
%   GC = intersectLineSphere(LINE, SPHERE) return the two points which are 
%   the intersection of the given line and sphere.
%   LINE   : [x0 y0 z0  dx dy dz]
%   SPHERE : [xc yc zc  R]
%   GC     : [x1 y1 z1 ; x2 y2 z2]
%   
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY

% difference between centers
dc = line(1:3)-sphere(1:3);

a = sum(line(:, 4:6).*line(:, 4:6), 2);
b = 2*sum(dc.*line(4:6), 2);
c = sum(dc.*dc, 2) - sphere(:,4).*sphere(:,4);

delta = b.*b -4*a.*c;

if delta>1e-14
    % find two roots of second order equation
    u1 = (-b -sqrt(delta))/2/a;
    u2 = (-b +sqrt(delta))/2/a;
    
    % convert into 3D coordinate
    point = [line(1:3)+u1*line(4:6) ; line(1:3)+u2*line(4:6)];

elseif abs(delta) > 1e-14
    % find unique root, and convert to 3D coord.
    u = -b/2./a;    
    point = line(1:3) + u*line(4:6);
    
else
    point = zeros(0, 3);
    return;
end

function point = intersectPlaneLine(plane, line)
%INTERSECTPLANELINE return intersection between a plane and a line
%
%   PT = intersectPlaneSphere(PLANE, LINE) return the intersection point of
%   the given line and the given plane.
%   PLANE : [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   LINE :  [x0 y0 z0 dx dy dz]
%   PT :    [XI YI ZI]
%   
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/02/2005.
%

%   HISTORY
%   24/11/2005 add support for multiple input

% unify sizes of data
if size(plane, 1)~=size(line, 1)
    if size(plane, 1)==1
        plane = repmat(plane, [size(line, 1) 1]);
    elseif size(line,1)==1
        line = repmat(line, [size(plane, 1) 1]);
    else
        error('line and plane do not have the same dimension');
    end
end


% plane normal
n = cross(plane(:,4:6), plane(:, 7:9), 2);

% test if line and plane are parallel
if abs(dot(n, line(:,4:6), 2))<1e-14
    point = [NaN NaN NaN];
    return;
end

% difference between origins of plane and line
dp = plane(:,1:3) - line(:,1:3);

% relative position of intersection on line
t = dot(n, dp, 2)/dot(n, line(:,4:6), 2);

% compute coord of intersection point
point = line(:,1:3) + t*line(:,4:6);


function line = intersectPlanes(plane1, plane2)
%INTERSECTPLANES return intersection between 2 planes in space
%
%   PT = intersectPlanes(PLANE1, PLANE2) return the straight line belonging
%   to both planes
%   PLANE : [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   LINE :  [x0 y0 z0 dx dy dz]
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/02/2005.
%

%   HISTORY


% plane normal
n1 = normalize3d(cross(plane1(:,4:6), plane1(:, 7:9), 2));
n2 = normalize3d(cross(plane2(:,4:6), plane2(:, 7:9), 2));

% test if planes are parallel
if abs(cross(n1, n2, 2))<1e-14
    line = [NaN NaN NaN NaN NaN NaN];
    return;
end

% Uses hessian form, ie : N.p = d
% I this case, d can be found as : -N.p0, when N is normalized
d1 = dot(n1, plane1(:,1:3), 2);
d2 = dot(n2, plane2(:,1:3), 2);

% compute dot products
dot1 = dot(n1, n1, 2);
dot2 = dot(n2, n2, 2);
dot12 = dot(n1, n2, 2);


det = dot1*dot2 - dot12*dot12;
c1 = (d1*dot2 - d2*dot12)./det;
c2 = (d2*dot1 - d1*dot12)./det;

p0 = c1*n1 + c2*n2;
dp = cross(n1, n2, 2);

line = [p0 dp];


function theta = lineAngle(varargin)
%LINEANGLE return angle between lines
%
%   a = LINEANGLE(line) return the angle between horizontal, right-axis 
%   and the given line. Angle is fiven in radians, between 0 and 2*pi,
%   in counter-clockwise direction.
%
%   a = LINEANGLE(line1, line2) return the directed angle between the
%   two lines. Angle is given in radians between 0 and 2*pi.
%
%   see createLine for more details on line representation.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY :
%   19/02/2004 : added support for multiple lines.

nargs = length(varargin);
if nargs == 1
    % one line
    line = varargin{1};
    theta = mod(atan2(line(:,4), line(:,3)) + 2*pi, 2*pi);
elseif nargs==2
    % two lines
    theta1 = lineAngle(varargin{1});
    theta2 = lineAngle(varargin{2});
    theta = mod(theta2-theta1+2*pi, 2*pi);
end

function plane = medianPlane(p1, p2)
%MEDIANPLANE create a plane in the middle of 2 points
%
%   plane = medianPlane(P1, P2)
%   plane is perpendicular to line (P1 P2) and contains the midpoint of p1
%   and p2.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%


p0 = (p1 + p2)/2;
n = p2-p1;

plane = createPlane(p0, n);


function vn = normalize(v)
%NORMALIZE normalize a vector
%
%   V2 = normalize(V);
%   return the normalization of vector V, such that ||V|| = 1. V can be
%   either a row or a column vector.
%
%   When V is a MxN array, normalization is performed for each row of the
%   array.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

dim = size(v);
if dim(1)==1 || dim(2)==1
    vn = v/sqrt(sum(v.*v));
else
    vn = v./repmat(sqrt(sum(v.*v, 2)), [1 dim(2)]);
end

function vn = normalize3d(v)
%NORMALIZE3D normalize a 3D vector
%
%   V2 = normalize3d(V);
%   return the normalization of vector V, such that ||V|| = 1. Vector V is
%   given in vertical form.
%
%   When V is a Nx3 array, normalization is performed for each row of the
%   array.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

%   HISTORY
%   30/11/2005  : correct a bug

n = sqrt(v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3));
vn = v./[n n n];

function plane2 = normalizePlane(plane1)
%NORMALIZEPLANE normalize parametric form of a plane
%
%   plane2 = normalizePlane(plane1);
%   transform the plane PANE1 in the following format :
%   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%   into another plane, with the same format, but with :
%   - (x0 y0 z0) is the closest point of plane to origin
%   - (DX1 DY1 DZ1) has norm equal to 1
%   - (DX2 DY2 DZ2) has norm equal to 1 and is orthogonal to (DX1 DY1 DZ1)
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY :


% compute origin point of the plane
p0 = projPointOnPlane([0 0 0], plane1);

% compute first direction vector
d1 = normalize3d(plane1(:,4:6));

% compute second direction vector
n = normalize3d(planeNormal(plane1));
d2 = -normalize3d(cross(d1, n));

% create the resulting plane
plane2 = [p0 d1 d2];

function n = planeNormal(plane)
%PLANENORMAL compute the normal to a plane
%
%   N = planeNormal(PLANE) 
%   compute the normal of the given plane
%   PLANE : [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   N : [dx dy dz]
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/02/2005.
%

%   HISTORY


% plane normal
n = cross(plane(:,4:6), plane(:, 7:9), 2);

function pos = planePosition(point, plane)
%PLANEPOSITION compute position of a point on a plane
%
%   PT2 = PLANEPOSITION(POINT, PLANE)
%   POINT has format [X Y Z], and plane has format
%   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%
%   Result PT2 has the form [XP YP], with [XP YP] coordinate of the point
%   in the coordinate system of the plane.
%
%   
%   CAUTION :
%   WORKS ONLY FOR PLANES WITH ORTHOGONAL DIRECTION VECTORS
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY :
%   24/11/2005 add support for multiple input

% unify size of data
if size(point, 1)~=size(plane, 1)
    if size(point, 1)==1
        point = repmat(point, [size(plane, 1) 1]);
    elseif size(plane, 1)==1
        plane = repmat(plane, [size(point, 1) 1]);
    else
        error('point and plane do not have the same dimension');
    end
end


p0 = plane(:,1:3);
d1 = plane(:,4:6);
d2 = plane(:,7:9);

s = dot(point-p0, d1, 2)./vecnorm3d(d1);
t = dot(point-p0, d2, 2)./vecnorm3d(d2);

pos = [s t];

function point = projPointOnPlane(point, plane)
%PROJPOINTONPLANE return the projection of a point on a plane
%
%   PT2 = PROJECTEDPOINT(PT1, PLANE).
%   Compute the (orthogonal) projection of point PT1 onto the line PLANE.
%   
%   Function works also for multiple points and planes. In this case, it
%   returns multiple points.
%   Point PT1 is a [N*3] array, and PLANE is a [N*9] array (see createPlane
%   for details). Result PT2 is a [N*3] array, containing coordinates of
%   orthogonal projections of PT1 onto planes PLANE.
%
%   See also planePosition
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

n = planeNormal(plane);
line = [point repmat(n, [size(point, 1) 1])];
point = intersectPlaneLine(plane, line);



function varargout = sph2cart2(varargin)
%SPH2CART2 convert spherical coordinate to cartesian coordinate
%
%   usage :
%   C = SPH2CART2(S)
%   C = SPH2CART2(PHI, THETA)       (assume rho = 1)
%   C = SPH2CART2(PHI, THETA, RHO)   
%   [X, Y, Z] = SPH2CART2(PHI, THETA, RHO);
%
%   S = [phi theta rho] (sphercial coordiante).
%   C = [X Y Z]  (cartesian coordinate)
%
%   Math convention is used : theta is angle with vertical, 0 for north
%   pole, +pi for south pole, pi/2 for points with z=0.
%   phi is the same as matlab cart2sph : angle from Ox axis, counted
%   counter-clockwise.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   22/03/2005 : make test for 2 args, and add radius if not specified for
%       1 arg.

if length(varargin)==1
    var = varargin{1};
    if size(var, 2)==2
        var = [var ones(size(var, 1), 1)];
    end
elseif length(varargin)==2
    var = [varargin{1} varargin{2} ones(size(varargin{1}))];
elseif length(varargin)==3
    var = [varargin{1} varargin{2} varargin{3}];
end

[x y z] = sph2cart(var(:,1), pi/2-var(:,2), var(:,3));

if nargout == 1 || nargout == 0
    varargout{1} = [x, y, z];
else
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end
    

function alpha = sphericalAngle(p1, p2, p3)
%SPHERICALANGLE compute angle on the sphere
%
%   ALPHA = sphericalAngle(P1, P2, P3)
%   compute angle (P1, P2, P2), in radians, between 0 and 2*PI.
%
%   Points are given either as [x y z] (there will be normalized to lie on
%   the unit sphere), or as [phi theta], with phi being the longitude in [0
%   2*PI] and theta being the elevation on horizontal [-pi/2 pi/2].
%
%
%   NOTE : 
%   this is an 'oriented' version of the angle computation, that is, the
%   result of sphericalAngle(P1, P2, P3) equals
%   2*pi-sphericalAngle(P3,P2,P1). To have the more classical relation
%   (with results given betwen 0 and PI), it suffices to take the minimum
%   of angle and 2*pi-angle.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY

% test if points are given as matlab spherical coordinate
if size(p1, 2) ==2
    [x y z] = sph2cart(p1(:,1), p1(:,2));
    p1 = [x y z];
    [x y z] = sph2cart(p2(:,1), p2(:,2));
    p2 = [x y z];
    [x y z] = sph2cart(p3(:,1), p3(:,2));
    p3 = [x y z];
end

% normalize points
p1 = normalize3d(p1);
p2 = normalize3d(p2);
p3 = normalize3d(p3);

% create the plane tangent to the unit sphere and containing central point
plane = createPlane(p2, p2);

% project the two other points on the plane
pi1 = planePosition(intersectPlaneLine(plane, [0 0 0 p1]), plane);
pi3 = planePosition(intersectPlaneLine(plane, [0 0 0 p3]), plane);

% compute angle on the tangent plane
alpha = angle3Points(pi1, [0 0], pi3);


function n = vecnorm3d(v)
%VECNORM3D compute euclidean norm of vector or of set of 3D vectors
%
%   n = vecnorm(V);
%   return euclidean norm of vector V.
%
%   When V is a Nx3 array, compute norm for each vector of the array.
%   Vector are given as rows. Result is then a [N*1] array.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY

n = sqrt(sum(v.*v, 2));

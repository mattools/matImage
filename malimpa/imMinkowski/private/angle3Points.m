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
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY :
%   18/02/2004 : add more possibilities to create lines (4 parameters,
%      all param in a single tab, and point + dx + dy.
%      Also add support for creation of arrays of lines.


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
        line = [zeros(size(var), 1) zeros(size(var, 1)) cos(var) sin(var)];
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
        % first param is signed distance to origin, and second param is
        % angle of line.
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

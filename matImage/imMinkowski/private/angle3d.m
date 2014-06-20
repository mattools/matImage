function alpha = angle3d(varargin)
%ANGLE3D compute angle between 2 3D points
%
%   ALPHA = anglePoints3d(P1, P2)
%   compute angle (P1, O, P2), in radians, between 0 and PI.
%
%   ALPHA = anglePoints3d(P1, P2, P3)
%   compute angle (P1, P2, P3), in radians, between 0 and PI.
%
%   ALPHA = anglePoints3d(PTS)
%   PTS is a 3x3 or 2x3 array containing coordinate of points.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY
%   20/09/2005 : add case of single argument for all points

p2 = [0 0 0];
if length(varargin)==1
    pts = varargin{1};
    if size(pts, 1)==2
        p1 = pts(1,:);
        p0 = [0 0 0];
        p2 = pts(2,:);
    else
        p1 = pts(1,:);
        p0 = pts(2,:);
        p2 = pts(3,:);
    end
elseif length(varargin)==2
    p1 = varargin{1};
    p0 = [0 0 0];
    p2 = varargin{2};
elseif length(varargin)==3
    p1 = varargin{1};
    p0 = varargin{2};
    p2 = varargin{3};
end

% normalized points
p1 = normalize3d(p1-p0);
p2 = normalize3d(p2-p0);
alpha = acos(dot(p1, p2, 2));

function vn = normalize3d(v)
%NORMALIZE3D normalize a 3D vector, such that its norm equals 1.

n = sqrt(v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3));
vn = v./[n n n];

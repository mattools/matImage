function index = findPoint(points, coord)
%FINDPOINT find index of a point in an array from its coordinates
% 
% ind = FINDPOINT(ARRAY, COORD) return the index of point whose coordinates 
% match the [2*1] array COORD in the [N*2] array points.
% If the point is not found, return 0.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/07/2003.
%

%   HISTORY
%   10/02/2004 : documentation
%   09/08/2004 : rewrite faster, and add support for multiple points

index = zeros(size(coord, 1), 1);
for i=1:size(coord, 1)
	ind = find(points(:,1)==coord(i,1) & points(:,2)==coord(i,2));
	if isempty(ind)
        index(i)=0;
	else
        index(i)=ind(1);
	end
end

return;

function se = cross3d
%CROSS3D Return a 3D structuring element with cross shape
%
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 30/09/2004.
%

%   HISTORY

se = zeros([3 3 3]);
se(1,2,2) = 1;
se(3,2,2) = 1;
se(2,:,:) = [0 1 0;1 1 1;0 1 0];


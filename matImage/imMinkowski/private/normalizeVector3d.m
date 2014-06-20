function vn = normalizeVector3d(v)
%NORMALIZEVECTOR3D normalize a 3D vector
%
%   V2 = normalizeVector3d(V);
%   Returns the normalization of vector V, such that ||V|| = 1. Vector V is
%   given as a row vector.
%
%   When V is a Nx3 array, normalization is performed for each row of the
%   array.
%
%   See also:
%   vectors3d, vectorNorm3d
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

%   HISTORY
%   30/11/2005 correct a bug
%   19/06/2009 rename as normalizeVector3d

n   = sqrt(v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3));
vn  = v./[n n n];

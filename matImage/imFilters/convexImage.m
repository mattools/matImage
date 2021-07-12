function res = convexImage(img, varargin)
%CONVEXIMAGE Compute smallest convex image containing the original pixels
%
%   IMG2 = convexImage(IMG);    
%   Returns an image with same dimension as IMG, but the structure is 
%   convex.
%
%   Deprecated: replaced by 'imConvexify'
%
%   Requires the 'geom2d' library.
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%

%   HISTORY
%   02/07/2004 process 3D images which contains pixels only on a single
%       slice (was not possible before).
%   21/08/2006 replace convexHull by minConvexHull for 3D case, add psb
%       to specify precision, and call method 'faceNormal' instead of
%       computing normals manually.
%   12/10/2007 clean up code

warning('imael:deprecated', ...
    'function ''convexImage'' is deprecated, use ''imConvexImage'' instead');

% initialize with image
res = imConvexImage(img);

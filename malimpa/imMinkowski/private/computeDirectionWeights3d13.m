function res = computeDirectionWeights3d13(varargin)
%COMPUTEDIRECTIONWEIGHTS3D13 Direction weights for 13 directions in 3D
%
%   C = computeDirectionWeights3d13
%   Returns an array of 13-by-1 values, corresponding to directions:
%   C(1)  = [+1  0  0]
%   C(2)  = [ 0 +1  0]
%   C(3)  = [ 0  0 +1]
%   C(4)  = [+1 +1  0]
%   C(5)  = [-1 +1  0]
%   C(6)  = [+1  0 +1]
%   C(7)  = [-1  0 +1]
%   C(8)  = [ 0 +1 +1]
%   C(9)  = [ 0 -1 +1]
%   C(10) = [+1 +1 +1]
%   C(11) = [-1 +1 +1]
%   C(12) = [+1 -1 +1]
%   C(13) = [-1 -1 +1]
%   The sum of the weights in C equals 1.
%   Some values are equal whatever the resolution:
%   C(4)==C(5);
%   C(6)==C(7);
%   C(8)==C(9);
%   C(10)==C(11)==C(12)==C(13);
%
%   C = computeDirectionWeights3d13(DELTA)
%   With DELTA = [DX DY DZ], specifies the resolution of the grid.
%
%   Example
%   c = computeDirectionWeights3d13;
%   sum(c)
%   ans =
%       1.0000
%
%   c = computeDirectionWeights3d13([2.5 2.5 7.5]);
%   sum(c)
%   ans =
%       1.0000
%
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Initializations

% grid resolution
delta = [1 1 1];
if ~isempty(varargin)
    delta = varargin{1};
end

% If resolution is [1 1 1], return the pre-computed set of weights
if all(delta == [1 1 1])
    area1 = 0.04577789120476 * 2;
    area2 = 0.03698062787608 * 2;
    area3 = 0.03519563978232 * 2;
    res = [...
        area1; area1; area1; ...
        area2; area2; area2; area2; area2; area2;...
        area3; area3; area3; area3 ];
    return;
end

% Define points of interest in the 26 discrete directions
% format is pt[Xpos][Ypos][Zpos], with [X], [Y] or [Z] being one of 
% 'N' (for negative), 'P' (for Positive) or 'Z' (for Zero)

% points below the OXY plane
ptPNN = normalizeVector3d([+1 -1 -1].*delta);
ptPZN = normalizeVector3d([+1  0 -1].*delta);
ptNPN = normalizeVector3d([-1 +1 -1].*delta);
ptZPN = normalizeVector3d([ 0 +1 -1].*delta);
ptPPN = normalizeVector3d([+1 +1 -1].*delta);

% points belonging to the OXY plane
ptPNZ = normalizeVector3d([+1 -1  0].*delta);
ptPZZ = normalizeVector3d([+1  0  0].*delta);
ptNPZ = normalizeVector3d([-1 +1  0].*delta);
ptZPZ = normalizeVector3d([ 0 +1  0].*delta);
ptPPZ = normalizeVector3d([+1 +1  0].*delta);

% points above the OXY plane
ptNNP = normalizeVector3d([-1 -1 +1].*delta);
ptZNP = normalizeVector3d([ 0 -1 +1].*delta);
ptPNP = normalizeVector3d([+1 -1 +1].*delta);
ptNZP = normalizeVector3d([-1  0 +1].*delta);
ptZZP = normalizeVector3d([ 0  0 +1].*delta);
ptPZP = normalizeVector3d([+1  0 +1].*delta);
ptNPP = normalizeVector3d([-1 +1 +1].*delta);
ptZPP = normalizeVector3d([ 0 +1 +1].*delta);
ptPPP = normalizeVector3d([+1 +1 +1].*delta);


%% Spherical cap type 1, direction [1 0 0]

% Compute area of voronoi cell for a point on the Ox axis, i.e. a point
% in the 6-neighborhood of the center.
refPoint = ptPZZ;

% neighbours of chosen point, sorted by CCW angle
neighbors = [ptPNN; ptPNZ; ptPNP; ptPZP; ptPPP; ptPPZ; ptPPN; ptPZN];

% compute area of spherical polygon
area1 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 1, direction [0 1 0]

% Compute area of voronoi cell for a point on the Oy axis, i.e. a point
% in the 6-neighborhood of the center.
refPoint    = ptZPZ;

% neighbours of chosen point, sorted by angle
neighbors   = [ptPPZ; ptPPP; ptZPP; ptNPP; ptNPZ; ptNPN; ptZPN; ptPPN];

% compute area of spherical polygon
area2 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 1, direction [0 0 1]

% Compute area of voronoi cell for a point on the Oz axis, i.e. a point
% in the 6-neighborhood of the center.
refPoint = ptZZP;

% neighbours of chosen point, sorted by angle
neighbors = [ptPZP; ptPPP; ptZPP; ptNPP; ptNZP; ptNNP; ptZNP; ptPNP];

% compute area of spherical polygon
area3 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 2, direction [1 1 0]

% Compute area of voronoi cell for a point on the Oxy plane, i.e. a point
% in the 18-neighborhood
refPoint = ptPPZ;

% neighbours of chosen point, sorted by angle
neighbors = [ptPZZ; ptPPP; ptZPZ; ptPPN];

% compute area of spherical polygon
area4 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 2, direction [1 0 1]

% Compute area of voronoi cell for a point on the Oxz plane, i.e. a point
% in the 18-neighborhood
refPoint = ptPZP;
% neighbours of chosen point, sorted by angle
neighbors = [ptPZZ; ptPPP; ptZZP; ptPNP];

% compute area of spherical polygon
area5 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 2, direction [0 1 1]

% Compute area of voronoi cell for a point on the Oxy plane, i.e. a point
% in the 18-neighborhood
refPoint = ptZPP;
% neighbours of chosen point, sorted by angle
neighbors = [ptZPZ; ptNPP; ptZZP; ptPPP];

% compute area of spherical polygon
area6 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Spherical cap type 3 (all cubic diagonals)

% Compute area of voronoi cell for a point on the Oxyz diagonal, i.e. a
% point in the 26 neighborhood only
refPoint = ptPPP;
% neighbours of chosen point, sorted by angle
neighbors = [ptPZP; ptZZP; ptZPP; ptZPZ; ptPPZ; ptPZZ];

% compute area of spherical polygon
area7 = sphericalVoronoiDomainArea(refPoint, neighbors);


%% Concatenate results

% return computed areas, formatted as fraction of sphere surface
res = [...
    area1 area2 area3 ...
    area4 area4 area5 area5 area6 area6...
    area7 area7 area7 area7...
    ]/(2*pi);

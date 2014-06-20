function [permDims flipDims] = getStackRotate90Params(axis, varargin)
%GETROTATE90PARAMETERS Return permutation and flip indices of 90° rotation
%
%   [PERMDIMS FLIPDIMS] = getStackRotate90Params(AXIS, NUMBER)
%   AXIS is the axis of rotation, between 1 and 3, corresponding to x, y
%   and z directions respectively.
%   NUMBER is the number of rotations around this axis, between 1 and 3.
%   NUMBER can also be 0 or 4, in this case this is equivalent to no
%   rotation at all.
%
%   Parameters are returned such that all rotations by 90° are direct in
%   the Oxyz basis, that is:
%   - rotation by 90° around X axis transforms Y axis to Z axis
%   - rotation by 90° around Y axis transforms Z axis to X axis
%   - rotation by 90° around Z axis transforms X axis to Y axis
%
%   Example
%   getStackRotate90Params
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% parse axis, and check bounds
axis = parseAxisIndex(axis);

% positive or negative rotation
n = 1;
if ~isempty(varargin)
    n = varargin{1};
end

% ensure n is between 0 (no rotation) and 3 (rotation in inverse direction)
n = mod(mod(n, 4) + 4, 4);

% case of no rotations (in case of...)
if n==0
    permDims = [1 2 3];
    flipDims = [];
    return;
end

% all permutations: row for axis (xyz ordering), column for number of
% rotations, from 1 to 3
permDimParams = {...
    [1 3 2], [1 2 3], [1 3 2]; ...
    [3 2 1], [1 2 3], [3 2 1]; ...
    [2 1 3], [1 2 3], [2 1 3] };

% all axis flipping: row for axis (xyz ordering), column for number of
% rotations, from 1 to 3
flipDimParams = {...
    2, [2 3], 3; ...
    3, [1 3], 1; ...
    1, [1 2], 2 } ;

% compute rotation params in xyz ordering
permDims = permDimParams{axis, n};
flipDims = flipDimParams{axis, n};

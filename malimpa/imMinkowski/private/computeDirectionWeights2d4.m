function c = computeDirectionWeights2d4(delta)
%COMPUTEDIRECTIONWEIGHTS2D4 Direction weights for 4 directions in 2D
%
%   C = computeDirectionWeights2d4
%   Returns an array of 4-by-1 values, corresponding to directions:
%   [+1  0]
%   [ 0 +1]
%   [+1 +1]
%   [-1 +1]
%
%   C = computeDirectionWeights2d4(DELTA)
%   With DELTA = [DX DY].
%
%   Example
%   computeDirectionWeights2d4
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check case of empty argument
if nargin == 0
    delta = [1 1];
end

% angle of the diagonal
theta   = atan2(delta(2), delta(1));

% angular sector for direction 1 ([1 0])
alpha1  = theta;

% angular sector for direction 2 ([0 1])
alpha2  = (pi/2 - theta);

% angular sector for directions 3 and 4 ([1 1] and [-1 1])
alpha34 = pi/4;

% concatenate the different weights
c = [alpha1 alpha2 alpha34 alpha34]' / pi;


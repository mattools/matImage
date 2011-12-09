function ijk = xyz2ijk(xyz, varargin)
%XYZ2IJK Convert from physical indexing to matlab indexing
%
%   output = xyz2ijk(input)
%   Apply following changes:
%   - convert instances of 1 to instances of 2
%   - convert instances of 2 to instances of 1
%   In the case of a color image, also applies the following:
%   - add 1 to any index greater than 3
%   - change index 4 into 3
%
%   Example
%   xyz2ijk([1 2 3])
%   ans =
%       2 1 3
%
%   xyz2ijk([1 2 3], true)
%   ans =
%       2 1 4
%
%   xyz2ijk([1 2 3 4])
%   ans =
%       2 1 4 3
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check if image is color
isColor = false;
if ~isempty(varargin)
    isColor = varargin{1};
end

% swap indices 1 and 2
ijk = xyz;
ijk(xyz==1) = 2;
ijk(xyz==2) = 1;

% in case of a color image, swap indices 3 and 4
if isColor
    ijk(xyz>=3) = ijk(xyz>=3) + 1;
    ijk(xyz==4) = 3;
end

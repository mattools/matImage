function se = orientedLineStrel(L, theta)
% Create an oriented line structuring element.
%
%   SE = orientedLineStrel(L, THETA)
%   Generates a binary images corresponding the linear structuring element
%   with length L and orientation THETA (in degrees).
%   The length corresponds to the approwimated Euclidean length of the
%   final structuring element.
%
%   Example
%     % Creates a structuring element with length 10 pixels and 30 degrees
%     % orientation
%     se = orientedLineStrel(10, 30)
%     se =
%       5x9 logical array
% 
%        1   1   0   0   0   0   0   0   0
%        0   0   1   1   0   0   0   0   0
%        0   0   0   0   1   0   0   0   0
%        0   0   0   0   0   1   1   0   0
%        0   0   0   0   0   0   0   1   1
%
%   See also
%     imGranulometry, imDirectionalGranulo, imGranulo
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2018-12-18,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2018 INRA - Cepia Software Platform.

% pre-compute trigonometric quantities
cost = cos(deg2rad(theta));
sint = sin(deg2rad(theta));

% compute strel size
if abs(cost) >= abs(sint)
    % horizontal strel directions
    xRadius = round((abs(L * cost) - 1) / 2);
    yRadius = round(xRadius * abs(sint / cost));
else
    % vertical strel directions
    yRadius = round((abs(L * sint) - 1) / 2);
    xRadius = round(yRadius * abs(cost / sint));
end

% allocate memory
dim = [2*yRadius+1 2*xRadius+1];
se = false(dim);

if abs(cost) >= abs(sint)
    % Process horizontal strel directions
    lx = -xRadius:xRadius;
    ly = round(lx * sint / cost);
    inds = sub2ind(dim, ly + yRadius + 1, lx + xRadius + 1);
    se(inds) = true;
    
else
    % Process vertical strel directions
    ly = -yRadius:yRadius;
    lx = round(ly * cost / sint);
    inds = sub2ind(dim, ly + yRadius + 1, lx + xRadius + 1);
    se(inds) = true;
end

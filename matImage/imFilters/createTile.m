function tile = createTile(v)
%CREATETILE Create a binary tile (2x2) from its index
%
%   IM = createTile(INDEX);
%   INDEX is a number between 0 and 15, 
%   and IM is the corresponding tile.
%
%   Example
%   createTile(2)
%       [0 1;0 0]
%   createTile(3)
%       [1 1;0 0]
%
%   See also
%   tileIndex3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-05-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

% create empty array
tile = false([2 2]);

% update value of each voxel
tile(1,1) = bitand(v,1)~=0;
tile(1,2) = bitand(v,2)~=0;
tile(2,1) = bitand(v,4)~=0;
tile(2,2) = bitand(v,8)~=0;

function tile = createTile3d(v)
% Create a 3D 2-by-2-by-2 binary configuration tile from its index.
%
%   IM = createTile3d(INDEX);
%   INDEX is a number between 0 and 255, 
%   and IM is the corresponding tile.
%
%   Example
%   createTile(0)
%       [ [0 0;0 0] ; [0 0;0 0] ]
%   createTile(3)
%       [ [1 1;0 0] ; [0 0;0 0] ]
%
%   See also
%     tileIndex3d, createTile
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-05-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% create empty array
tile = false([2 2 2]);

% update value of each voxel
tile(1,1,1) = bitand(v,1)~=0;
tile(1,2,1) = bitand(v,2)~=0;
tile(2,1,1) = bitand(v,4)~=0;
tile(2,2,1) = bitand(v,8)~=0;
tile(1,1,2) = bitand(v,16)~=0;
tile(1,2,2) = bitand(v,32)~=0;
tile(2,1,2) = bitand(v,64)~=0;
tile(2,2,2) = bitand(v,128)~=0;

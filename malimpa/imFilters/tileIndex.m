function index = tileIndex(tile)
%TILEINDEX  Return the index of a 2x2 binary tile
%   INDEX = tileIndex(TILE)
%   Compute the index of a tile, given as a 2x2 binary image, by adding
%   powers of two mutliplied by values of the tile.
%   [0 0;0 0] has index 0
%   [1 0;0 0] has index 1
%   [0 1;0 0] has index 2
%   [1 1;0 0] has index 3
%   [0 0;1 0] has index 4
%   ... 
%   [1 1;1 1] has index 15
%
%   Example
%   tileIndex
%
%   See also
%   createTile, tileIndex3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-05-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

tile = tile>0;
index = tile(1,1) + 2*tile(1,2) + 4*tile(2,1) + 8*tile(2,2);
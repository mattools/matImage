function index = tileIndex3d(tile)
%TILEINDEX3D Return the index of a 2x2x2 binary tile
%
%   INDEX = tileIndex3d(TILE)
%   Compute the index of a tile, given as a 2x2x2 binary image, by adding
%   powers of two mutliplied by values of the tile. The result is comprised
%   between 0 and 255.
%   Iterate on x, y, then z directions, corresponding to directions 2, 1,
%   and 3.
%
%   Example
%   tile = zeros([2 2 2]);
%   tile(1,1:2,1) = 1;
%   tileIndex3d(tile)
%       3
%
%   See also
%   createTile3d, tileIndex
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-05-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

tile = tile>0;
index = ...
    tile(1,1,1) + 2*tile(1,2,1) + 4*tile(2,1,1) + 8*tile(2,2,1) + ...
    16*tile(1,1,2) + 32*tile(1,2,2) + 64*tile(2,1,2) + 128*tile(2,2,2);

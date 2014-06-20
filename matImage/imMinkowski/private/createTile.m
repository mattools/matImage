function tile = createTile(label)
%CREATETILE create a tile from its label
%
%   IM = createTile(LABEL);
%   LABEL is a number between 1 and 256, 
%   and IM is the corresponding tile.
%


v = label-1;

tile = zeros([2 2 2]);
tile(1,1,1) = bitand(v,1)~=0;
tile(1,2,1) = bitand(v,2)~=0;
tile(2,1,1) = bitand(v,4)~=0;
tile(2,2,1) = bitand(v,8)~=0;
tile(1,1,2) = bitand(v,16)~=0;
tile(1,2,2) = bitand(v,32)~=0;
tile(2,1,2) = bitand(v,64)~=0;
tile(2,2,2) = bitand(v,128)~=0;

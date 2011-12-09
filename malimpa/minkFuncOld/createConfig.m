function im = createConfig(ind)
%CREATECONFIG create a 2x2x2 configuration from label
%
%   IM = createConfig(LBL)
%
%   Configuration is created from powers of two of binary representation of
%   label LBL.
%   Pixels are places first for increasing x (direction 2), then increasing
%   y (direction 1), and finally by increasing z (direction 3), that is :
%   indices = 
%   [ 1 2 ; 3 4 ]
%   [ 5 6 ; 7 8 ]
%
%   createConfig(1) correspond to zeros([2 2 2]), and createConfig(256)
%   correspond to ones([2 2 2]).
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/09/2005.
%


v = ind-1;
im = zeros(2,2,2);

im(1,1,1) = bitand(v, 1)~=0;
im(1,2,1) = bitand(v, 2)~=0;
im(2,1,1) = bitand(v, 4)~=0;
im(2,2,1) = bitand(v, 8)~=0;
im(1,1,2) = bitand(v, 16)~=0;
im(1,2,2) = bitand(v, 32)~=0;
im(2,1,2) = bitand(v, 64)~=0;
im(2,2,2) = bitand(v, 128)~=0;

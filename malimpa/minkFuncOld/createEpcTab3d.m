function tab = createEpcTab3d(varargin)
%CREATEEPCTAB3D create a table of valued for computing 3D EPC values.
%
%   LUT = createEpcTab3d
%   return an array of size 256, which can be used with function imLUT to
%   create map of contribution to the Euler-Poincare Characterisic.
%
%   LUT = createEpcTab3d(CONN)
%   Where CONN can be either 6 or 26, specifies the connectivity to use.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2005-12-20
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   24/03/2006 : returns correct result for connectivity 26
%   09/08/2006 : use precomputed array.

conn = 6;
if ~isempty(varargin)
    conn = varargin{1};
end


% pre-computed LUT for 26 connectivity.
tab = [...
  0   1   1   0   1   0  -2  -1   1  -2   0  -1   0  -1  -1   0 ...
  1   0  -2  -1  -2  -1  -1  -2  -6  -3  -3  -2  -3  -2   0  -1 ...
  1  -2   0  -1  -6  -3  -3  -2  -2  -1  -1  -2  -3   0  -2  -1 ...
  0  -1  -1   0  -3  -2   0  -1  -3   0  -2  -1   0   1   1   0 ...
  1  -2  -6  -3   0  -1  -3  -2  -2  -1  -3   0  -1  -2  -2  -1 ...
  0  -1  -3  -2  -1   0   0  -1  -3   0   0   1  -2  -1   1   0 ...
 -2  -1  -3   0  -3   0   0   1  -1   4   0   3   0   3   1   2 ...
 -1  -2  -2  -1  -2  -1   1   0   0   3   1   2   1   2   2   1 ...
  1  -6  -2  -3  -2  -3  -1   0   0  -3  -1  -2  -1  -2  -2  -1 ...
 -2  -3  -1   0  -1   0   4   3  -3   0   0   1   0   1   3   2 ...
  0  -3  -1  -2  -3   0   0   1  -1   0   0  -1  -2   1  -1   0 ...
 -1  -2  -2  -1   0   1   3   2  -2   1  -1   0   1   2   2   1 ...
  0  -3  -3   0  -1  -2   0   1  -1   0  -2   1   0  -1  -1   0 ...
 -1  -2   0   1  -2  -1   3   2  -2   1   1   2  -1   0   2   1 ...
 -1   0  -2   1  -2   1   1   2  -2   3  -1   2  -1   2   0   1 ...
  0  -1  -1   0  -1   0   2   1  -1   2   0   1   0   1   1   0 ...
]/8;

if conn==6
     tab = tab(end:-1:1);
end

% % Alternative function.
% % the EPC is computed for each configuration, by correcting edge effect
% % and averaging over all image borders.
% % result is the same, and correspond to the technical report of Ohser and
% % Nagel and Schladitz (2000).
%
% N = 2^(2*2*2); %=256
% tab = zeros(N, 1);
% im = zeros(2,2,2);
% for i=1:N
%     v = i-1;
%     im(1,1,1) = bitand(v,1)~=0;
%     im(1,1,2) = bitand(v,2)~=0;
%     im(1,2,1) = bitand(v,4)~=0;
%     im(1,2,2) = bitand(v,8)~=0;
%     im(2,1,1) = bitand(v,16)~=0;
%     im(2,1,2) = bitand(v,32)~=0;
%     im(2,2,1) = bitand(v,64)~=0;
%     im(2,2,2) = bitand(v,128)~=0;
%     
%     % compute LUT using 6 connectivity
%     tab(i) = epcMean(im, 6);    
% end
% 
% % adapt connectivity if needed
% if conn==26
%     tab = tab(end:-1:1);
% end

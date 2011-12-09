function map = epcmap(img)
%EPCMAP create a map for computing the EPC value
%
%   MAP = epcmap(IMG) creates a map of values, corresponding to the
%   contribution of each configuration of 2*2 pixels. IMG should be a
%   binary 2D or 3D image. MAP is a SIZE(IMG)-1 double array. 
%
%   Values for configurations are computed as follow :
%   - compute EPC in the image
%   - use shell-correction to estimate EPC, that is estimate EPC by
%   substracting EPC of structure with lower-left edges of the window
%   - average for all possible corners (4 in 2D) of image
%   - set the computed value to the corresponding configuration.
%
%   For example, 4-connectivity for 2D image will transform following
%   pixels configurations in the given values in the map :
%   [0 1] -> 1/4   [1 1] -> -1/4
%   [0 0]          [1 0]
%
%   It is possible to estimate EPC density of the structure by using :
%   CEP = sum(MAP(:));
%
%   See also : EPC, MINKOWSKI, MINKMAP, EPCMEAN, EPCSHELL
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/12/2003.
%

%   HISTORY
%   01/10/2004 : add support for 3d


img = img~=0;
dim = size(img);
nd = length(dim);

NY = dim(1)-1;
NX = dim(2)-1;
if length(dim)>2
    NZ = dim(3)-1;
end

if nd==2
    % 2 dimensions        
    tab = [ ...
         0   1/4   1/4    0  ...
        1/4   0    1/2  -1/4 ...
        1/4  1/2    0   -1/4 ...
         0  -1/4  -1/4    0  ]';
	% uncomment next line if you want to recreate dynamically the array
	%tab = createTab2d;
 
    hist= img(1:NY,     1:NX) + ...
        2*img(2:NY+1,   1:NX) + ...
        4*img(1:NY,     2:NX+1) + ...
        8*img(2:NY+1,   2:NX+1) + ...
        ones(NY, NX);
    
    map = reshape(mean(ind2rgb(hist(:), repmat(tab, [1 3])), 3), [NY NX]);
else
    % 3 dimensions
    tab = createTab3d;
    
    hist=   img(1:NY,    1:NX,   1:NZ) + ...
          2*img(2:NY+1,  1:NX,   1:NZ) + ...
          4*img(1:NY,    2:NX+1, 1:NZ) + ...
          8*img(2:NY+1,  2:NX+1, 1:NZ) + ...
         16*img(1:NY,    1:NX,   2:NZ+1) + ...
         32*img(2:NY+1,  1:NX,   2:NZ+1) + ...
         64*img(1:NY,    2:NX+1, 2:NZ+1) + ...
        128*img(2:NY+1,  2:NX+1, 2:NZ+1) + ...
        ones(NY, NX, NZ);
    map = reshape(mean(ind2rgb(hist(:), repmat(tab, [1 3])), 3), [NY NX NZ]);
end



% % ------------------------------------------------
% function tab = createTab2d
% %CREATETAB : create a table of value for computing mink values.
% %    TAB = CREATE TAB return 16*3 array, first index is the pixel
% %    configuration, seconf one is the mean minkowski functional of the
% %    configuration.
% 
% N = 2^(2*2); %=16
% tab = zeros(N, 1);
% 
% for i=1:N
%     v = i-1;
%     im = [bitand(v, 1)~=0 bitand(v, 2)~=0 ; bitand(v, 4)~=0 bitand(v, 8)~=0];
%     tab(i) = epcMean(im);
% end


% ------------------------------------------------
function tab = createTab3d
%CREATETAB : create a table of value for computing mink values.
%    TAB = CREATE TAB return 16*3 array, first index is the pixel
%    configuration, seconf one is the mean minkowski functional of the
%    configuration.

N = 2^(2*2*2); %=256
tab = zeros(N, 1);
im = zeros(2,2,2);
for i=1:N
    v = i-1;
    im(1,1,1) = bitand(v,1)~=0;
    im(1,1,2) = bitand(v,2)~=0;
    im(1,2,1) = bitand(v,4)~=0;
    im(1,2,2) = bitand(v,8)~=0;
    im(2,1,1) = bitand(v,16)~=0;
    im(2,1,2) = bitand(v,32)~=0;
    im(2,2,1) = bitand(v,64)~=0;
    im(2,2,2) = bitand(v,128)~=0;
    tab(i) = epcMean(im);
end
  
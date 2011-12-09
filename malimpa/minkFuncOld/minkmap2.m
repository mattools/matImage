function map = minkmap2(img, varargin)
%MINKMAP2 create a map for computing the Minkowski measures
%
%   MAP = minkmap(IMG) creates a map of values, corresponding to the
%   contribution of each configuration of 2*2 pixels to the computation 
%   of minkwoski measures. 
%   IMG should be a binary image (2D or 3D), and MAP is a [size(IMG)-1,
%   ndims(IMG] array. For example, if input is 2D image with size 50*50,
%   result qill have size 49*49*3.
%
%   Values for configurations are computed as follow :
%   - create sub-image of 2*2 pixels (or (2*2*2 in 3D).
%   - use plus-sampling for estimation of minkowski density in the window
%   - set the computed value to the corresponding configuration.
%
%   MAP = minkmap(IMG, I) compute only the Ith minkowski density map. in
%   this case, size of result is size(img)-1. This can be used to save
%   memory for big images.
%  
%   Result is
%   See also : EPC, MINKOWSKI
%
%
%   TRY TO COUNT INTERSECTIONS ON 4 DIRECTIONS INSTEAD OF 2.
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 08/10/2003.
%

%   HISTORY 

img = img~=0;
dim = size(img);
nd = length(dim);

NY = dim(1)-1;
NX = dim(2)-1;
if length(dim)>2
    NZ = dim(3)-1;
end

if length(varargin)>0
    I = varargin{1};
    
    map = zeros(NY, NX);
        
    if length(dim)==2
        % 2 dimensions        
        tab = createTab2d;
        
        hist= img(1:NY,     1:NX) + ...
            2*img(2:NY+1,   1:NX) + ...
            4*img(1:NY,     2:NX+1) + ...
            8*img(2:NY+1,   2:NX+1) + ...
            ones(NY, NX);
        
        map = zeros([size(img)-1]);
        map(:) = tab(hist(:),I);
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
        
        map = zeros([size(img)-1]);
        map(:) = tab(hist(:),I);
   	end

else

	if length(dim)==2
        % 2 dimensions
        map = zeros(NY, NX, 3);
        
        tab = createTab2d;
	
        hist = img(1:NY, 1:NX) + 2*img(2:NY+1, 1:NX) + ...
            4*img(1:NY, 2:NX+1) + 8*img(2:NY+1, 2:NX+1) + ...
            ones(NY, NX);
        
        map = zeros([size(img)-1 3]);
        map(:,:,1) = reshape(tab(hist(:),1), [NY NX]);
        map(:,:,2) = reshape(tab(hist(:),2), [NY NX]);
        map(:,:,3) = reshape(tab(hist(:),3), [NY NX]);
     
	else
        % 3 dimensions
	
        tab = createTab3d;
	
        hist = img(1:NY, 1:NX, 1:NZ) + 2*img(2:NY+1, 1:NX, 1:NZ) + ...
            4*img(1:NY, 2:NX+1, 1:NZ) + 8*img(2:NY+1, 2:NX+1, 1:NZ) + ...
            16*img(1:NY, 1:NX, 2:NZ+1) + 32*img(2:NY+1, 1:NX, 2:NZ+1) + ...
            64*img(1:NY, 2:NX+1, 2:NZ+1) + 128*img(2:NY+1, 2:NX+1, 2:NZ+1) + ...
            ones(NY, NX, NZ);
        clear img;
        map = zeros(NY, NX, NZ, 4);    
        map(:,:,:,1) = reshape(tab(hist(:),1), [NY NX NZ]);
        map(:,:,:,2) = reshape(tab(hist(:),2), [NY NX NZ]);
        map(:,:,:,3) = reshape(tab(hist(:),3), [NY NX NZ]);
        map(:,:,:,4) = reshape(tab(hist(:),4), [NY NX NZ]);
  	end
end

% ------------------------------------------------
function tab = createTab2d
%CREATETAB : create a table of value for computing mink values.
%    TAB = CREATE TAB return 16*3 array, first index is the pixel
%    configuration, seconf one is the mean minkowski functional of the
%    configuration.

c1 = 1/2+sqrt(2)/4;
c2 = 1;
c3 = 1/2+sqrt(2)/2;

N = 2^(2*2); %=16
tab = zeros(N, 3);
tab( 1, :) = [0  0  0];
tab( 2, :) = [1 c1  1];
tab( 3, :) = [1 c1  1];
tab( 4, :) = [2 c3  0];

tab( 5, :) = [1 c1  1];
tab( 6, :) = [2 c3  0];
tab( 7, :) = [2 c2  2];
tab( 8, :) = [3 c1 -1];

tab( 9, :) = [1 c1  1];
tab(10, :) = [2 c2  2];
tab(11, :) = [2 c3  0];
tab(12, :) = [3 c1 -1];

tab(13, :) = [2 c3  0];
tab(14, :) = [3 c1 -1];
tab(15, :) = [3 c1 -1];
tab(16, :) = [4  0  0];


tab(:,1) = tab(:,1)/4;
tab(:,2) = tab(:,2)*pi/8;
tab(:,3) = tab(:,3)*pi/4;

% ------------------------------------------------
function tab = createTab3d
%CREATETAB : create a table of value for computing mink values.
%    TAB = CREATE TAB return 16*3 array, first index is the pixel
%    configuration, seconf one is the mean minkowski functional of the
%    configuration.

N = 2^(2*2*2); %=256
tab = zeros(N, 4);
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
    tab(i, :) = minkPlus(im)';
end
  
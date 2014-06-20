function gray = grayFilter(img, varargin)
%GRAYFILTER linear gray-filtering of an image
%
%   GRAY = grayFilter(IMG);
%   Apply a linear gray filtering to the binary image IMG. The function
%   computes the configuration number associated with each tile of the
%   image. The result image has dimension size(IMG)-1, and has values
%   between 0 and 15 (for 2D images) or between 0 and 256 (for 3D images).
%
%   The correspondance between GRAY value and associated tiles is as
%   follow:
%   GRAY     TILE
%     0      [0 0;0 0];
%     1      [1 0;0 0];
%     2      [0 1;0 0];
%     3      [1 1;0 0];
%     4      [1 1;0 0];
%    ...        ....
%    14      [0 1;1 1];
%    15      [1 1;1 1];
%
%
%   GRAY = grayFilter(IMG, NU);
%   Where NU equals 1 or 2 specifies the size of tile to consider. NU=1
%   corrsponds to 2x2 tiles, NU=2 corresponds to 3x3 tiles. In this case,
%   GRAY has values between 0 and 511. Works only for 2D images.
%
%
%   See also imLUT
%
%   Example
%   img = zeros(6, 6);
%   img(3:5, 3:4)=1;
%   grayFilter(img)
% ans =
%      0     0     0     0     0
%      0     8    12     4     0
%      0    10    15     5     0
%      0    10    15     5     0
%      0     2     3     1     0
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/10/2004.
%

%   HISTORY 
%   03/11/2004 add 3x3 2D case.
%   28/08/2007 add doc

img = img~=0;
dim = size(img);
nd = length(dim);

nu=1;

if ~isempty(varargin)
    var = varargin{1};
    if length(var)==1
        nu = var;
    else
        coef = var;
        % find size of filter from length of coefficients.
        nu = power(log(length(coef))/log(2), 1/nd);
    end   
end
      
if length(dim)==2
    % 2 dimensions
    NY = dim(1)-nu;
    NX = dim(2)-nu;

    if nu==1
        gray=1*img(1:NY,    1:NX) + ...
             2*img(1:NY,    2:NX+1) + ...
             4*img(2:NY+1,  1:NX) + ...
             8*img(2:NY+1,  2:NX+1) ;
    elseif nu==2
        gray =  1*img(1:NY,     1:NX) + ...
                2*img(1:NY,     2:NX+1) + ...
                4*img(1:NY,     3:NX+2) + ...
                8*img(2:NY+1,   1:NX) + ...
               16*img(2:NY+1,   2:NX+1) + ...
               32*img(2:NY+1,   3:NX+2) + ...
               64*img(3:NY+2,   1:NX) + ...
              128*img(3:NY+2,   2:NX+1) + ...
              256*img(3:NY+2,   3:NX+2) ;               
    end
        
else
    % 3 dimensions   
    NY = dim(1)-nu;
    NX = dim(2)-nu;
    NZ = dim(3)-nu;
    
    gray=   img(1:NY,    1:NX,   1:NZ) + ...
          2*img(1:NY,    2:NX+1, 1:NZ) + ...
          4*img(2:NY+1,  1:NX,   1:NZ) + ...
          8*img(2:NY+1,  2:NX+1, 1:NZ) + ...
         16*img(1:NY,    1:NX,   2:NZ+1) + ...
         32*img(1:NY,    2:NX+1, 2:NZ+1) + ...
         64*img(2:NY+1,  1:NX,   2:NZ+1) + ...
        128*img(2:NY+1,  2:NX+1, 2:NZ+1);
end

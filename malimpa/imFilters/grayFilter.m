function gray = grayFilter(img, varargin)
%GRAYFILTER Compute configuration map of a binary image
%
%   GRAY = grayFilter(IMG);
%   Returns a gray-scale image, with size dim(IMG)-1, containing values of
%   the 2x2 configuration of the original binary image.
%
%   Example:
%   img = [0 0 0 0 0;0 1 1 0 0;0 1 1 1 0;0 0 0 0 0];
%   grayFilter(img)
%   ans =
%      8    12     4     0
%     10    15    13     4
%      2     3     3     1
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/10/2004.
%

%   HISTORY 
%   03/11/2004 : add 3x3 2D case.


% pre-processing
img = img~=0;
dim = size(img);
nd = length(dim);

% size of neighborhood to consider
nu=1;

% extract input parameters
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

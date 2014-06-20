function res = expand(img, varargin)
%EXPAND expand size of a matrix, repeating each coefficient
%
%   usage:
%   RES = expand(MAT, SCALE]
%   MAT is a N*M*... array, and SCALE is a int value for each dimension of
%   MAT. Result RES will have a size [N*S1 M*S2 ...]
%
%   usage:
%   RES = expand(MAT, SCALE1, SCALE2, ...)
%   is also possible
%
%   Example:
%   img2 = expand([1 2 3 ; 4 5 6], [3 2])
%   will produce the following :
%   [1 1 2 2 3 3 ; 
%    1 1 2 2 3 3 ;
%    1 1 2 2 3 3 ;
%    4 4 5 5 6 6 ;
%    4 4 5 5 6 6;
%    4 4 5 5 6 6 ];
%   
%   NOTE:
%   at the moment, implemented only for 1D, 2D or 3D arrays.
%
%   See Also
%   kron
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/10/2004.
%

%   HISTORY
%   17/11/2005 correct bug when expanding 2D images into 3D.
%   17/08/2009 clean up code, convert to same type as input image

% size and number of dimensions of input image
dim = size(img);
nd = ndims(img);
if nd==2 && (dim(1)==1 || dim(2)==1)
    nd = 1;
end

% extract scale factor from input
scale = ones(1, nd);
if isempty(varargin)
    error('EXPAND : should specify scale factor');
elseif length(varargin)==1
    scale = varargin{1};    
    % if scale is a scalar, transform it into a row vector
    if length(scale)==1 && nd>1
        scale = scale*ones(1, length(dim));
    else
        nd = length(scale);
    end
else
    if length(varargin)<length(dim)
        error('EXPAND : not enough parameters for scale');
    end
     
    % get one scale factor for each dimension
    for i=1:nd
        scale(i) = varargin{i};
    end
end

% convert 1D to 2D (only one case ...)
if nd==1
    if length(scale)==1
        if dim(1)==1
            scale = [1 scale];
        else
            scale = [scale 1];
        end
    end
    nd=2;
end

% allocate memory for result, with same type as input
if islogical(img)
    res = false(dim.*scale);
else
    res = zeros(dim.*scale, class(img));
end
    

if nd==2
    s1 = scale(1); s2 = scale(2);
    n1 = size(img, 1); n2 = size(img, 2);
    
    for i=1:s1
        for j=1:s2            
            res((0:n1-1)*s1+i, (0:n2-1)*s2+j)=img;
        end
    end
elseif nd==3
    s1 = scale(1); s2 = scale(2); s3=scale(3);
    n1 = size(img, 1); n2 = size(img, 2); n3=size(img, 3);
    
    for i=1:s1
        for j=1:s2            
            for k=1:s3            
                res((0:n1-1)*s1+i, (0:n2-1)*s2+j, (0:n3-1)*s3+k)=img;
            end
        end
    end
end



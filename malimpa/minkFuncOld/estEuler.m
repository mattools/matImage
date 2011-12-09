function chi = estEuler(img, varargin)
%ESTEULER esimate Euler-Poincare Characteristic (EPC) of a structure.
%   
%   CHI = estEuler(IMG)
%   Returns the Euler-Poincare Characteristic of the binary structure
%   represented by IMG.
%   The EPC is measured inside image, and corrected by the EPC measured on
%   the intersection of the structure with boundary of image.  result is
%   the same as 'epcMean', but uses LUT to make clode cleaner, and name of
%   function is clearer. 
%   
%   CHI = epc(IMG, CONN)
%   Also specify desired connectivity. It can be 4 or 8 for planar images,
%   and 6 or 26 for 3D images. Keywords 'minimal' and 'maximal' also
%   works.
%
%
%   See also :
%   tpl, minkowski, bweuler
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 09/08/2006 from epc.
%

%   HISTORY :


% ensure a logical array
img = squeeze(img~=0);

% input image dimension
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims=1;
end

% process input variables
conn = 4;   % default connectivity is minimal
if ~isempty(varargin)
    var = varargin{1};
    if ischar(var)
        if strcmpi(var(1:max(3, length(var))), 'min')
            if nbDims==2
                conn = 4;
            else
                conn = 6;
            end
        elseif strcmpi(var(1:max(3, length(var))), 'max')
            if nbDims==2
                conn = 6;
            else
                conn = 26;
            end
        else
            error('not supported connecivity option');
        end
    elseif isnumeric(var)
        conn = var;
    else
        error('cannot understand input variable');
    end
end
    
    
    
if ndims(img)==2 && dim(1)==1 && dim(2)==1          % dimension 0
    chi = img==1;

elseif ndims(img)==2 && (dim(2)==1 || dim(1)==1)    % dimension 1
    img = img(:);
    chi = sum(img(1:end-1) ~= img(2:end));

elseif ndims(img)==2                                % dimension 2
    lut = createEpcTab2d(conn);
    chi = sum(sum(imLUT(grayFilter(img), lut)));
    
elseif ndims(img)==3                               % dimension 3
    lut = createEpcTab3d(conn);
    chi = sum(sum(sum(imLUT(grayFilter(img), lut))));
end

return 


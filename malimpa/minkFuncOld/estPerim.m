function perim = estPerim(img, varargin)
%ESTPERIM estimate perimeter of a 2D structure
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 12/01/2005
%

conn = 8;
if ~isempty(varargin)
    conn = varargin{1};
end

if conn==8
    r=sqrt(2)/2;
    tab = [0 r r 1   r 1 2*r r   r 2*r 1 r   1 r r 0];
else
    tab = [0 1 1 1   1 1 2 1     1 2 1 1     1 1 1 0];
end

% utilise une image binaire
conf = imLUT(grayFilter(img>0), tab);

perim = sum(conf(:));
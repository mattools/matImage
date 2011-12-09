function mink = minkowski(img, varargin)
%MINKOWSKI computes Minkowski measure of a structure
% 
%   Minkowski functionals are smallest set of additive and independant
%   measures on sets. In 2D, they are related to area, perimeter and
%   Euler-Poincare Charcteristic (EPC) of the structure.
%   In 3D, They are related to volume, surface area, mean breadth (or mean
%   elongation), and EPC.
%
%   They are cuputed using Crofton formulaes, which gives expressions of
%   functionals from EPC computed in several subspaces of origin image,
%   that is on all possibles digital planes and digital lines in image.
%
%   MINK = minkowski(IMG) returns the minkowski measures of structure in
%   IMG. Size of MINK depend on the number of dimensions of IMG. Actually,
%   we have relation : length(MINK)=ndims(IMG)+1
%
%   MINK = minkowski(IMG, C) specifies connectivity (4 or 8 in 2D, 6 or 26
%   in 3D).
%
%   See also : EPC, TPL
%
%
%   TODO : Connectivity 8 does not work properly (edge effect)
%   TODO : Only Connectivity 6 is currently supported in 3D.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%

%   HISTORY :
%   30/03/2005 : add connectivity 8 in 2D, and change doc


    
% utilise une image binaire
img = img>0;
dim = size(img);
mink = 0;

% default connectivty for images
conn = 4;
if length(dim)==3
    conn = 6;
end

% find specified connectivity if specified
if ~isempty(varargin)
    conn = varargin{1};
end



% dimension 0 (one single value)
if ndims(img)==2 && dim(2)==1 && dim(1)==1
    mink = double(img);
    return;
end


% dimension 1
if ndims(img)==2 && (dim(2)==1 || dim(1)==1) 
    mink = zeros(2, 1);
    mink(1) = sum(img(:));
    mink(2) = 2*epc(img);
    return;
end

% dimension 2
if ndims(img)==2
    mink = zeros(3, 1);   
    
    if conn==4
        % area measure
        mink(1) = sum(img(:));

        % boundary length measure
        % equals mean of total diameter * pi/2.
        mink(2) = pi*(tpl(img, [1 0]) + tpl(img, [0 1]))/4;

        % connectivity measure
        mink(3) = epc(img)*pi;
        return;
        
    elseif conn==8
        % area measure
        mink(1) = sum(img(:));

        % boundary length measure
        % equals mean of total diameter * pi/2.
        D1 = dim(1);
        D2 = dim(2);

        s1 = sum(sum(img(1:D1-1,:)~=img(2:D1,:)))*.5;
        s2 = sum(sum(img(:,1:D2-1)~=img(:,2:D2)))*.5;
        s3 = sum(sum(img(1:D1-1,1:D2-1)~=img(2:D1,2:D2)))*sqrt(2)*.25;
        s4 = sum(sum(img(2:D1,1:D2-1)~=img(1:D1-1,2:D2)))*sqrt(2)*.25;

        % average on directions (/4) and divide by 2 for minkowski
        % weighting  (w1=B/2)
        mink(2) = pi*(s1+s2+s3+s4)/8;

        % connectivity measure
        mink(3) = epc(img)*pi;
        return;

    else
        error('minkowski : connectivty option unknown');
    end
end

% dimension 3
if ndims(img)==3
    mink = zeros(4, 1);
    
    % volume measure
    mink(1) = sum(img(:));
    
    % surface measure
    mink(2) = mean([tpl(img,[0 1 1]) tpl(img,[1 0 1]) tpl(img,[1 1 0])])*4/3;
    
    % mean curvature measure (-> mean breadth)
    mink(3) = mean([tpl(img,[1 0 0]) tpl(img,[0 1 0]) tpl(img,[0 0 1])])*2*pi/3;
    
    % connectivity measure
    mink(4) = epc(img)*4*pi/3;
        
    return
end

return 
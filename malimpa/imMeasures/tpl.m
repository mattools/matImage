function l = tpl(tab, varargin)
%TPL compute total projection length
%   TPL(IMG) compute the total projection length of structure in image IMG.
%   Projection is computed along the last dimension of image. It
%   correspond to total diameter defined by Serra.
%
%   TPL(IMG, PDIM) specifies dimensions to manage. PDIM= [0 .. 0 1]
%   correspond to the default case. If PDIM contains only one 1, it is a
%   total diameter computation. If PDIM contains 2 ones, it is a total
%   projected surface computation. If PDIM contains only zeros, TPL
%   performs an Euler-Poincare Characteristic computation. If PDIM contains
%   only ones, it performs an area (2D case), volume (3D  case), or
%   Lebesgue measure.
%
%   TPL(IMG, PDIM, CONN) also specifies the neighbourhood configuration to
%   use, which can be 'minimal', or 'maximal'. Default is 'minimal'.
%
%   See also :
%   TPL, MINKOWSKI
%
%
%   ---------
%
%   author : David Legland
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%

%   HISTORY
%   20/04/2004 : 2D : do not call epc, accelerating processing


% remove useless dimensions and convert to binary image
tab = squeeze(tab)~=0;

% input image size
dim = size(tab);

% set default direction for projection : along the last dimension
if length(dim)==2 && (dim(1)==1 || dim(2)==1)
    pdim = 1;                           % dimension 1
else
    pdim = zeros(1, length(dim));       % dimension > 1
    pdim(length(pdim))=1;
end


if ~isempty(varargin)
    pdim = varargin{1};
end

% init
%nc=0;
l = 0;

% dimension 1 -------------------------------------------

if length(dim)==2 && (dim(1)==1 || dim(2)==1)
    if pdim(1)==1
        l = sum(tab);       % total length computation
    else
        l = epc(tab);       % EPC in dimension 1
    end
end



% dimension 2 -------------------------------------------

if length(dim)==2 && dim(1)~=1 && dim(2)~=1
    N1 = dim(1); N2 = dim(2);
    if sum(pdim==[1 0])==2
        % projection along y (first dimension of img)
        l = sum(sum(~tab(:,1:N2-1) & tab(:,2:N2))) + sum(tab(:,1));
    elseif sum(pdim == [0 1])==2
        % projection along x (second dimension of img)
        l = sum(sum(~tab(1:N1-1,:) & tab(2:N1,:))) + sum(tab(1,:));
    elseif sum(pdim == [0 0])==2
        % EPC in dimension 2
        l = epc(tab);
    elseif sum(pdim == [1 1])==2
        % area computation
        l = sum(tab(:));
    end
end


% dimension 3 -------------------------------------------

if length(dim)==3
    N1 = dim(1); N2 = dim(2); N3 = dim(3);
    
    
    % three total diameters computations
    if sum(pdim == [1 0 0])==3
        % total diameter in x axis
        n = sum(tab(:));
        n1 = sum(sum(sum(tab(:,1:N2-1,:)&tab(:,2:N2,:))));
        n2 = sum(sum(sum(tab(:,:,1:N3-1)&tab(:,:,2:N3))));
        n12 = sum(sum(sum(tab(:,1:N2-1,1:N3-1) & tab(:,1:N2-1,2:N3) & ...
            tab(:,2:N2,1:N3-1) & tab(:,2:N2,2:N3) )));
        l = n - n1 - n2 + n12;
        
    elseif sum(pdim == [0 1 0])==3
        % total diameter in y axis
        n = sum(tab(:));
        n1 = sum(sum(sum(tab(1:N1-1,:,:)&tab(2:N1,:,:))));
        n2 = sum(sum(sum(tab(:,:,1:N3-1)&tab(:,:,2:N3))));
        n12 = sum(sum(sum(tab(1:N1-1,:,1:N3-1) & tab(1:N1-1,:,2:N3) & ...
            tab(2:N1,:,1:N3-1) & tab(2:N1,:,2:N3) )));
        l = n - n1 - n2 + n12;
        
    elseif sum(pdim == [0 0 1])==3
        % total diameter in z axis
        n = sum(tab(:));
        n1 = sum(sum(sum(tab(1:N1-1,:, :)&tab(2:N1,:, :))));
        n2 = sum(sum(sum(tab(:,1:N2-1, :)&tab(:,2:N2, :))));
        n12 = sum(sum(sum(tab(1:N1-1,1:N2-1, :) & tab(1:N1-1,2:N2,:) & ...
            tab(2:N1,1:N2-1,:) & tab(2:N1,2:N2,:) )));
        l = n - n1 - n2 + n12;
        
        % three total projected area computations
    elseif sum(pdim == [1 1 0])==3
        % projected area on xy plane
        l = sum(sum(sum(~tab(:,:,1:N3-1) & tab(:,:,2:N3)))) + ...
            sum(sum(tab(:, :, 1)));
    elseif sum(pdim == [1 0 1])==3
        % projected area on xz plane
        l = sum(sum(sum(~tab(:,1:N2-1,:) & tab(:,2:N2,:)))) + ...
            sum(sum(tab(:, 1, :)));
    elseif sum(pdim == [0 1 1])==3
        % projected area on yz plane
        l = sum(sum(sum(~tab(1:N1-1,:,:) & tab(2:N1,:,:)))) + ...
            sum(sum(tab(1, :, :)));
        
    elseif sum(pdim == [0 0 0])==3
        % EPC in dimension 3
        l = epc(tab);
        
    elseif sum(pdim == [1 1 1])==3
        % volume computation
        l = sum(tab(:));
        
    end
    
end

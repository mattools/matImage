function epcm = epcm(img, varargin)
%EPCM compute density of Euler-Poincare Characteristic (EPC) of a structure
% 
%
%   
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

%   HISTORY :
%   12/12/2003 add help


% ensure a logical array
img = img~=0;

% input image dimension
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims=1;
end


% dimension 1
if nbDims == 1
    if dim(1)==1
        img = img';
        dim(1)=dim(2);
    end
    N1 = dim(1);
    epcm = (sum(img(1:N1-1)&~img(2:N1)) + sum(~img(1:N1-1)&img(2:N1)))/2/(N1-1);
    return;
end

% dimension 2
if nbDims==2
    N1 = dim(1); N2=dim(2);
    
    na1 = sum(sum(img(2:N1,2:N2) & ~img(2:N1,1:N2-1) & ~img(1:N1-1,2:N2)));
    nb1 = sum(sum(~img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,2:N2)));
    na2 = sum(sum(img(2:N1,1:N2-1) & ~img(1:N1-1,1:N2-1) & ~img(2:N1,2:N2)));
    nb2 = sum(sum(~img(1:N1-1,2:N2) & img(2:N1,1:N2-1) & img(1:N1-1,1:N2-1) & img(2:N1,2:N2)));
    na3 = sum(sum(img(1:N1-1,2:N2) & ~img(1:N1-1,1:N2-1) & ~img(2:N1,2:N2)));
    nb3 = sum(sum(~img(2:N1,1:N2-1) & img(1:N1-1,2:N2) & img(1:N1-1,1:N2-1) & img(2:N1,2:N2)));
    na4 = sum(sum(img(1:N1-1,1:N2-1) & ~img(2:N1,1:N2-1) & ~img(1:N1-1,2:N2)));
    nb4 = sum(sum(img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(1:N1-1,2:N2) & ~img(2:N1,2:N2)));
   
    epcm = (na1+na2+na3+na4 - nb1-nb2-nb3-nb4)/4/(N1-1)/(N2-1);    
    return;
end

if ndims(img)==3
    % number of nodes in the graph
    n = sum(img(:));

    % number of edges in each direction
    n1 = sum(sum(sum(img(1:dim(1)-1,:,:) & img(2:dim(1),:,:) )));
    n2 = sum(sum(sum(img(:,1:dim(2)-1,:) & img(:,2:dim(2),:) )));
    n3 = sum(sum(sum(img(:,:,1:dim(3)-1) & img(:,:,2:dim(3)) )));

    % number of square faces in each direction
    im= img(1:dim(1)-1,1:dim(2)-1,:) & img(1:dim(1)-1,2:dim(2),:) & ...
        img(2:dim(1),1:dim(2)-1,:) & img(2:dim(1),2:dim(2),:) ;
    n12 = sum(im(:));
    im= img(1:dim(1)-1,:,1:dim(3)-1) & img(1:dim(1)-1,:,2:dim(3)) & ...
        img(2:dim(1),:,1:dim(3)-1) & img(2:dim(1),:,2:dim(3)) ;
    n13 = sum(im(:));
    im= img(:,  1:dim(2)-1,1:dim(3)-1,:) & img(:,1:dim(2)-1,2:dim(3)) & ...
        img(:,  2:dim(2),1:dim(3)-1,:) & img(:,2:dim(2),2:dim(3),:) ;
    n23 = sum(im(:));

    % number of elementary cubes
    im= img(1:dim(1)-1, 1:dim(2)-1, 1:dim(3)-1) & ...
        img(1:dim(1)-1, 1:dim(2)-1, 2:dim(3))   & ...
        img(1:dim(1)-1, 2:dim(2),   1:dim(3)-1) & ...
        img(1:dim(1)-1, 2:dim(2),   2:dim(3))   & ...
        img(2:dim(1),   1:dim(2)-1, 1:dim(3)-1) & ...
        img(2:dim(1),   1:dim(2)-1, 2:dim(3))   & ...
        img(2:dim(1),   2:dim(2),   1:dim(3)-1) & ...
        img(2:dim(1),   2:dim(2),   2:dim(3));
    n123 = sum(im(:));

    % compute EPC by euler graph's relation
    epcm = n - (n1+n2+n3) + (n12+n23+n13) - n123;
end

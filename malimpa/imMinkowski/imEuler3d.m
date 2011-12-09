function [chi labels] = imEuler3d(img, varargin)
%IMEULER3D Euler number of a binary 3D image
%
%   CHI = imEuler3d(IMG)
%   Compute Euler-Poincare Characteristic (or Euler Number, or connectivity
%   number) in binary or labeled 3D image.
%
%   CHI = imEuler3d(IMG, CONN)
%   Specify the connectivity to use. Can be either 6 (the default) or 26.
%
%   [CHI LABELS] = imEuler3d(IMG, ...)
%   When IMG is a label image, the Euler-Poincaré characteristic of each
%   label is computed and returned in CHI. LABELS is the array of unique
%   labels in image.
%
%   Example
%   imEuler3d
%
%   See also
%   imEuler2d
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    chi = zeros(length(labels), 1);
    for i=1:length(labels)
        chi(i) = imEuler3d(img==labels(i), varargin{:});
    end
    return;
end

% in case of binary image, compute only one label
labels = 1;

% check connectivity
conn = 6;
if ~isempty(varargin)
    conn = varargin{1};
end

% size of image in each direction
dim = size(img);
N1 = dim(1); 
N2 = dim(2);
N3 = dim(3);

% compute number of nodes, number of edges in each direction, number of
% faces in each plane, and number of cells.
% principle is erosion with simple structural elements (line, square)
% but it is replaced here by simple boolean operation, which is faster

% count vertices
v = sum(img(:));

% count edges in each direction
e1 = sum(sum(sum(img(1:N1-1,:,:) & img(2:N1,:,:))));
e2 = sum(sum(sum(img(:,1:N2-1,:) & img(:,2:N2,:))));
e3 = sum(sum(sum(img(:,:,1:N3-1,:) & img(:,:,2:N3))));

% count square faces orthogonal to each main directions
f1 = sum(sum(sum(...
    img(:, 1:N2-1, 1:N3-1) & img(:, 1:N2-1, 2:N3) & ...
    img(:, 2:N2, 1:N3-1)   & img(:, 2:N2, 2:N3) )));
f2 = sum(sum(sum(...
    img(1:N1-1, :, 1:N3-1) & img(1:N1-1, :, 2:N3) & ...
    img(2:N1, :, 1:N3-1)   & img(2:N1, :, 2:N3) )));
f3 = sum(sum(sum(...
    img(1:N1-1, 1:N2-1, :) & img(1:N1-1, 2:N2, :) & ...
    img(2:N1, 1:N2-1, :)   & img(2:N1, 2:N2, :) )));

% compute number of cubes
s = sum(sum(sum(...
    img(1:N1-1, 1:N2-1, 1:N3-1) & img(1:N1-1, 2:N2, 1:N3-1) & ...
    img(2:N1, 1:N2-1, 1:N3-1)   & img(2:N1, 2:N2, 1:N3-1) & ...
    img(1:N1-1, 1:N2-1, 2:N3)   & img(1:N1-1, 2:N2, 2:N3) & ...
    img(2:N1, 1:N2-1, 2:N3)     & img(2:N1, 2:N2, 2:N3) )));

if conn==6
    % compute euler characteristics from graph counts
    chi = v - (e1+e2+e3) + (f1+f2+f3) - s;
    return;
    
elseif conn == 26
    
    % compute EPC inside image, with correction on edges
    epcc = sum(sum(sum(imLUT(grayFilter(img), getEulerLutC26))));
    
    % Compute edge correction, in order to compensate it and obtain the
    % Euler-Poincare characteristic computed for whole image.
    
    % compute epc on faces
    f10  = imEuler2d(squeeze(img(1,:,:)), 8);
    f11  = imEuler2d(squeeze(img(N1,:,:)), 8);
    f20  = imEuler2d(squeeze(img(:,1,:)), 8);
    f21  = imEuler2d(squeeze(img(:,N2,:)), 8);
    f30  = imEuler2d(img(:,:,1), 8);
    f31  = imEuler2d(img(:,:,N3), 8);
    epcf = f10 + f11 + f20 + f21 + f30 + f31;
    %epcf =  epc2d8(img(1,:,:)) + epc2d8(img(N1,:,:)) + ...
    %        epc2d8(img(:,1,:)) + epc2d8(img(:,N2,:)) + ...
    %        epc2d8(img(:,:,1)) + epc2d8(img(:,:,N3));
    
    % compute epc on edges
    e11 = imEuler1d(img(:,1,1));
    e12 = imEuler1d(img(:,1,N3));
    e13 = imEuler1d(img(:,N2,1));
    e14 = imEuler1d(img(:,N2,N3));
    
    e21 = imEuler1d(img(1,:,1));
    e22 = imEuler1d(img(1,:,N3));
    e23 = imEuler1d(img(N1,:,1));
    e24 = imEuler1d(img(N1,:,N3));
    
    e31 = imEuler1d(img(1,1,:));
    e32 = imEuler1d(img(1,N2,:));
    e33 = imEuler1d(img(N1,1,:));
    e34 = imEuler1d(img(N1,N2,:));
    
    epce = e11 + e12 + e13 + e14 + e21 + e22 + e23 + e24 + ...
        e31 + e32 + e33 + e34;
    
    % compute epc on vertices
    epcn = img(1,1,1) + img(1,1,N3) + img(1,N2,1) + img(1,N2,N3) + ...
        img(N1,1,1) + img(N1,1,N3) + img(N1,N2,1) + img(N1,N2,N3);
    
    % compute epc from measurements made on interior of window, and
    % facets of lower dimension
    chi = epcc - ( epcf/2 - epce/4 + epcn/8);
    
else
    error('imEuler3d: uknown connectivity option');
end


function tab = getEulerLutC26
% do not compute function, uses a precompiled array instead
tab = [...
  0   1   1   0   1   0  -2  -1   1  -2   0  -1   0  -1  -1   0 ...
  1   0  -2  -1  -2  -1  -1  -2  -6  -3  -3  -2  -3  -2   0  -1 ...
  1  -2   0  -1  -6  -3  -3  -2  -2  -1  -1  -2  -3   0  -2  -1 ...
  0  -1  -1   0  -3  -2   0  -1  -3   0  -2  -1   0   1   1   0 ...
  1  -2  -6  -3   0  -1  -3  -2  -2  -1  -3   0  -1  -2  -2  -1 ...
  0  -1  -3  -2  -1   0   0  -1  -3   0   0   1  -2  -1   1   0 ...
 -2  -1  -3   0  -3   0   0   1  -1   4   0   3   0   3   1   2 ...
 -1  -2  -2  -1  -2  -1   1   0   0   3   1   2   1   2   2   1 ...
  1  -6  -2  -3  -2  -3  -1   0   0  -3  -1  -2  -1  -2  -2  -1 ...
 -2  -3  -1   0  -1   0   4   3  -3   0   0   1   0   1   3   2 ...
  0  -3  -1  -2  -3   0   0   1  -1   0   0  -1  -2   1  -1   0 ...
 -1  -2  -2  -1   0   1   3   2  -2   1  -1   0   1   2   2   1 ...
  0  -3  -3   0  -1  -2   0   1  -1   0  -2   1   0  -1  -1   0 ...
 -1  -2   0   1  -2  -1   3   2  -2   1   1   2  -1   0   2   1 ...
 -1   0  -2   1  -2   1   1   2  -2   3  -1   2  -1   2   0   1 ...
  0  -1  -1   0  -1   0   2   1  -1   2   0   1   0   1   1   0 ...
]/8;

function tab = createEpcTab26 %#ok<DEFNU>
% can be used to pre-compute the array for EPC

% allocate memory
tab = zeros(256, 1);

% iterate on non-empty configurations (config 1 and 255 have EPC=0)
for i=2:255
    % create a group of 8 voxels
    v = i-1;
    im(1,1,1) = bitand(v,1)>0;
    im(2,1,1) = bitand(v,2)>0;
    im(1,2,1) = bitand(v,4)>0;
    im(2,2,1) = bitand(v,8)>0;
    im(1,1,2) = bitand(v,16)>0;
    im(2,1,2) = bitand(v,32)>0;
    im(1,2,2) = bitand(v,64)>0;
    im(2,2,2) = bitand(v,128)>0;

    % epc inside window. It is equal to 1, because we avoid case with all 0
    % and if several pixels are present, they are connected by definition.
    chi3 = 1;
    
    % epc on faces (just call version of epc for 2D images)
    chi2 = ( ...
        epc(im(:,:,1), 8) + epc(im(:,:,2), 8) + ...
        epc(im(:,1,:), 8) + epc(im(:,2,:), 8) + ...
        epc(im(1,:,:), 8) + epc(im(2,:,:), 8) ) /2;
    
    % epc on edges
    chi1 = (sum(sum(im(:,:,1) | im(:,:,2))) + ...
            sum(sum(im(:,1,:) | im(:,2,:))) + ...
            sum(sum(im(1,:,:) | im(2,:,:))) ) / 4;
    
    % epc on vertices (=number of vertices)
    chi0 = sum(im(:))/8;
    
    tab(i) = chi3 - chi2 + chi1 - chi0;
end


function chi = epc(img, varargin)
%EPC compute Euler-Poincare Characteristic (EPC) of a structure.
%   
%   chi = epc(IMG)
%   Returns the Euler-Poincare Characteristic of the binary structure
%   represented by IMG. 
%   Function is free of edge effects : if a structure touches edge of
%   images, it contributes as if it was in the center.
%
%   chi = epc(img, conn)
%   Also specify desired connectivity. It can be 4 or 8 for planar images,
%   and 6 or 26 for 3D images. Keywords 'minimal' and 'maximal' also
%   works.
%
%   This functions uses euler's graph relation to compute EPC from number
%   of vertices, edges and faces (or number of k-faces for multidimensional
%   images) :
%   CHI = Nv - Ne + Nf
%   
%   Number of vertices (Nv) is the number of pixels in the image.
%   Number of edges depend on the connectivity used. For 4 connectivity in
%   2D images, Ne can be computed by counting configurations of two
%   orthogonal adjacent pixels. Configurations of diagonal pixels are also
%   counted for 8-connectivity.
%   Number of faces is number of configurations of four pixels put in a
%   small square (4-connectivity), or number of triangles with one of
%   following configurations for 8-connectivity :
%   11  11  1x  x1
%   1x  x1  11  11
%   ('1' is a pixel of the structure, 'x' is indiferrent pixel).
%   For 8-connectivity we also need to count number of square
%   configurations, and use folowibng relation :
%   chi = Nv - Ne + Nf - Ns    (Ns= number of squares).
%
%
%   TODO : add other type of connectivity (2D : 4/8, 3D : 18, 14-1, 14-2,
%       6-18-26 ...)   
%
%   See also :
%   tpl, minkowski, bweuler
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
%   30/03/2005 : add connectivity 8 for 2D images
%   20/05/2005 : add connectivity 26 for 3D images
%   27/06/2005 : update connectivity 26 for 3D (uses less memory), and
%       update doc

% ensure a logical array
img = squeeze(img~=0);

% input image dimension
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims=1;
end

% process input variables
conn = 'minimal';   % default connectivity is minimal
if ~isempty(varargin)
    var = varargin{1};
    if ischar(var)
        if strcmpi(var(1:max(3, length(var))), 'min')
            conn = 'minimal';
        elseif strcmpi(var(1:max(3, length(var))), 'max')
            conn = 'maximal';
        else
            error('not supported connecivity option');
        end
    elseif isnumeric(var)
        if var==4 && nbDims==2
            conn = 'minimal';
        elseif var==8 && nbDims==2
            conn = 'maximal';
        elseif var==6 && nbDims==3
            conn = 'minimal';
        elseif var==26 && nbDims==3
            conn = 'maximal';
        else
            error('not supporterd connectivity number');
        end
    else
        error('cannot understand input variable');
    end
end
    
    
    
% dimension 0
if ndims(img)==2 && dim(1)==1 && dim(2)==1
    chi = img==1;
    return
end

% dimension 1
if ndims(img)==2 && (dim(2)==1 || dim(1)==1)
    if dim(2)==1
        img = img';
        dim(2)=dim(1);
    end
    chi = sum(img(:)) - sum( img(1:dim(2)-1) & img(2:dim(2)) );
    return;
end

% dimension 2
if ndims(img)==2
    N1 = dim(1); N2=dim(2);
    % compute number of nodes, number of edges (H and V) and number of
    % faces
    % principle is erosion with simple structural elements (line, square)
    % but it is replaced here by simple boolean operation, which is faster
    
    % count vertices
    n = sum(img(:));
    
    % count horizontal and vertical edges
    n1 = sum(sum(img(1:N1-1,:)&img(2:N1,:)));
    n2 = sum(sum(img(:,1:N2-1)&img(:,2:N2)));
    
    % count square faces
    n1234 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & ...
        img(2:N1,1:N2-1) & img(2:N1,2:N2) ));

    if strcmp(conn, 'maximal')
        
        % need also to count diagonal edges and triangular faces
        n3 = sum(sum(img(1:N1-1,1:N2-1)&img(2:N1,2:N2)));
        n4 = sum(sum(img(1:N1-1,2:N2)&img(2:N1,1:N2-1)));
        n123 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,1:N2-1) ));
        n124 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,2:N2) ));
        n134 = sum(sum(img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));
        n234 = sum(sum(img(1:N1-1,2:N2) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));
        
        chi = n -n1-n2-n3-n4 + n123+n124+n134+n234 - n1234;

   elseif strcmp(conn, 'minimal')
        % compute euler characteristics from graph counts
        chi = n - n1 -n2 + n1234;

        % Another method , which consist in coutning special point config,
        % and adding epc measured on the border. But does not seem to be
        % better...
        %na = sum(sum(img(2:N1,2:N2) & ~img(2:N1,1:N2-1) & ~img(1:N1-1,2:N2)));
        %nb = sum(sum(~img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,2:N2)));
        %n1 = sum(img(1,2:N2) & ~img(1,1:N2-1));
        %n2 = sum(img(2:N1,1) & ~img(1:N1-1,1));
        %n12 = img(1,1);
        % corners detected inside image + points on the border
        %numCells = na - nb + n1 + n2 + n12;
    else
        error('EPC : uknown connectivity option');
    end
    
    return;
end

if ndims(img)==3
    if strcmp(conn, 'minimal')
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
        chi = n - (n1+n2+n3) + (n12+n23+n13) - n123;
        return
        
    elseif strcmp(conn, 'maximal')
        
        % get image dimensions
        dim = size(img);
        D1 = dim(1);
        D2 = dim(2);
        D3 = dim(3);
        
        % compute EPC inside image
        epcc = sum(sum(sum(imLUT(grayFilter(img), getEpcTab26))));
        
        % compute epc on faces
        f10  = epc2d8(squeeze(img(1,:,:)));
        f11  = epc2d8(squeeze(img(D1,:,:)));
        f20  = epc2d8(squeeze(img(:,1,:)));
        f21  = epc2d8(squeeze(img(:,D2,:)));
        f30  = epc2d8(img(:,:,1));
        f31  = epc2d8(img(:,:,D3));
        epcf = f10 + f11 + f20 + f21 + f30 + f31;
        %epcf =  epc2d8(img(1,:,:)) + epc2d8(img(D1,:,:)) + ...
        %        epc2d8(img(:,1,:)) + epc2d8(img(:,D2,:)) + ...
        %        epc2d8(img(:,:,1)) + epc2d8(img(:,:,D3));
            
        % compute epc on edges
        e11 = epc1d(img(:,1,1));
        e12 = epc1d(img(:,1,D3));
        e13 = epc1d(img(:,D2,1));
        e14 = epc1d(img(:,D2,D3));
        
        e21 = epc1d(img(1,:,1));
        e22 = epc1d(img(1,:,D3));
        e23 = epc1d(img(D1,:,1));
        e24 = epc1d(img(D1,:,D3));
        
        e31 = epc1d(img(1,1,:));
        e32 = epc1d(img(1,D2,:));
        e33 = epc1d(img(D1,1,:));
        e34 = epc1d(img(D1,D2,:));
        
        epce = e11 + e12 + e13 + e14 + e21 + e22 + e23 + e24 + ...
            e31 + e32 + e33 + e34;
        
        % compute epc on vertices
        epcn = img(1,1,1) + img(1,1,D3) + img(1,D2,1) + img(1,D2,D3) + ...
            img(D1,1,1) + img(D1,1,D3) + img(D1,D2,1) + img(D1,D2,D3);
        
        % compute epc from measurements made on interior of window, and
        % facets of lower dimension
        chi = epcc + epcf/2 - epce/4 + epcn/8;
        
        
        % Older version, using more memory, and little bit slower
        %
        % Use gray filtering to compute configuration indices, and then to
        % assign a contribution to each configuration number.
        % To avoid edge effect we add a border of one pixel all around the
        % image, making the algorithm being time and memory consuming for
        % big images.
        %
        %img2 = zeros(dim+2);
        %img2(2:dim(1)+1, 2:dim(2)+1, 2:dim(3)+1) = img;
        %val = imLUT(grayFilter(img2), createEpcTab26);
        %chi = sum(val(:));
        
    end
end

return 



% function tab = createEpcTab26
% 
% tab = zeros(1, 256);
% for i=2:256
%     % create a group of 8 voxels
%     v = i-1;
%     im(1,1,1) = bitand(v,1)>0;
%     im(2,1,1) = bitand(v,2)>0;
%     im(1,2,1) = bitand(v,4)>0;
%     im(2,2,1) = bitand(v,8)>0;
%     im(1,1,2) = bitand(v,16)>0;
%     im(2,1,2) = bitand(v,32)>0;
%     im(1,2,2) = bitand(v,64)>0;
%     im(2,2,2) = bitand(v,128)>0;
% 
%     % epc inside window. It is equal to 1, because we avoid case with all 0
%     % and if several pixels are present, they are connected by definition.
%     chi3 = 1;
%     
%     % epc on faces (just call version of epc for 2D images)
%     chi2 = ( ...
%         epc(im(:,:,1), 8) + epc(im(:,:,2), 8) + ...
%         epc(im(:,1,:), 8) + epc(im(:,2,:), 8) + ...
%         epc(im(1,:,:), 8) + epc(im(2,:,:), 8) ) /2;
%     
%     % epc on edges
%     chi1 = (sum(sum(im(:,:,1) | im(:,:,2))) + ...
%             sum(sum(im(:,1,:) | im(:,2,:))) + ...
%             sum(sum(im(1,:,:) | im(2,:,:))) ) / 4;
%     
%     % epc on vertices (=number of vertices)
%     chi0 = sum(im(:))/8;
%     
%     tab(i) = chi3 - chi2 + chi1 - chi0;
% end
%    
% 
function tab = getEpcTab26
% do not compute function, uses a precompiled array instead
tab = [...
  0   1   1   0   1   0  -2  -1   1  -2   0  -1   0  -1  -1   0 ...
  1   0  -2  -1  -2  -1  -1  -2  -6  -3  -3  -2  -3  -2   0  -1 ...
  1  -2   0  -1  -6  -3  -3  -2  -2  -1  -1  -2  -3   0  -2  -1 ...
  0  -1  -1   0  -3  -2   0  -1  -3   0  -2  -1   0   1   1   0 ...
  1  -2  -6  -3   0  -1  -3  -2  -2  -1  -3   0  -1  -2  -2  -1 ...
  0  -1  -3  -2  -1   0   0  -1  -3   0   0   1  -2  -1   1   0 ...
 -2  -1  -3   0  -3   0   0   1  -1   4   0   3   0   3   1   2 ...
 -1  -2  -2  -1  -2  -1   1   0   0   3   1   2   1   2   2   1 ...
  1  -6  -2  -3  -2  -3  -1   0   0  -3  -1  -2  -1  -2  -2  -1 ...
 -2  -3  -1   0  -1   0   4   3  -3   0   0   1   0   1   3   2 ...
  0  -3  -1  -2  -3   0   0   1  -1   0   0  -1  -2   1  -1   0 ...
 -1  -2  -2  -1   0   1   3   2  -2   1  -1   0   1   2   2   1 ...
  0  -3  -3   0  -1  -2   0   1  -1   0  -2   1   0  -1  -1   0 ...
 -1  -2   0   1  -2  -1   3   2  -2   1   1   2  -1   0   2   1 ...
 -1   0  -2   1  -2   1   1   2  -2   3  -1   2  -1   2   0   1 ...
  0  -1  -1   0  -1   0   2   1  -1   2   0   1   0   1   1   0 ...
]/8;


function chi = epc1d(img)
% compute EPC on a line
D = length(img);
chi = sum(img(:)) - sum( img(1:D-1) & img(2:D) );



function chi = epc2d8(img)
% compute 2D EPC with 8-connexity

dim =size(img);
N1 = dim(1); N2=dim(2);

% count vertices
n = sum(img(:));

% count horizontal and vertical edges
n1 = sum(sum(img(1:N1-1,:)&img(2:N1,:)));
n2 = sum(sum(img(:,1:N2-1)&img(:,2:N2)));

% count square faces
n1234 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & ...
    img(2:N1,1:N2-1) & img(2:N1,2:N2) ));

% FOR 8-connectivity, need also to count diagonal edges ...
n3 = sum(sum(img(1:N1-1,1:N2-1)&img(2:N1,2:N2)));
n4 = sum(sum(img(1:N1-1,2:N2)&img(2:N1,1:N2-1)));

% ... and triangular faces
n123 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,1:N2-1) ));
n124 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,2:N2) ));
n134 = sum(sum(img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));
n234 = sum(sum(img(1:N1-1,2:N2) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));

% compute euler characteristics from graph counts
chi = n -n1-n2-n3-n4 + n123+n124+n134+n234 - n1234;


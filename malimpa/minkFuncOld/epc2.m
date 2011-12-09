function numCells = epc(img, varargin)
%EPC compute Euler-Poincare Characteristic (EPC) of a structure.
%   
%   chi = epc(img) returns the Euler-Poincare Characteristic of the binary
%   structure represented by IMG.
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
%   This function works in the following cases :
%   0D images (chi=1 if the unique of pixel img is set to 1, 0 anyway)
%   1D images (no need to specify connectivity)
%   2D images with 4-connectivity
%   3D images with 6-connectivity
%
%   TODO : 
%   - add 8-connectivity in 2D images
%   - add 26-connextivity in 3D images
%   - add other type of connectivity (2D : 6, 4/8, 3D : 18, 6/18 ...)
%
%   See also :
%   TPL, MINKOWSKI
%
%   This version tried to apply same algorithm as matlab for 2D image in 4
%   connecitivty. Result is same as epc, but speed is slower.
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
if nbDims==2 & dim(2)==1
    nbDims=1;
end

% process input variables
conn = 'minimal';   % default connectivity is minimal
if length(varargin)>0
    var = varargin{1};
    if ischar(var)
        if lower(var(1:max(3, length(var))))=='min'
            conn = 'minimal';
        elseif lower(var(1:max(3, length(var))))=='max'
            conn = 'maximal';
        else
            error('not supported connecivity option');
        end
    elseif isnumeric(var)
        if var==4 & nbDims==2
            conn = 'minimal';
        elseif var==8 & nbDims==2
            conn = 'maximal';
        elseif var==6 & nbDims==3
            conn = 'minimal';
        elseif var==26 & nbDims==3
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
    numCells = img==1;
    return
end

% dimension 1
if ndims(img)==2 && (dim(2)==1 || dim(1)==1)
    if dim(2)==1
        img = img';
        dim(2)=dim(1);
    end
    numCells = sum(img(:)) - sum( img(1:dim(2)-1) & img(2:dim(2)) );
    return;
end

% dimension 2
if ndims(img)==2
    N1 = dim(1); N2=dim(2);
    % compute number of nodes, number of edges (H and V) and number of
    % faces
    % principle is erosion with simple structural elements (line, square)
    % but it is replaced here by simple boolean operation, which is faster
    n = sum(img(:));
    n1 = sum(sum(img(1:N1-1,:)&img(2:N1,:)));
    n2 = sum(sum(img(:,1:N2-1)&img(:,2:N2)));
    n12 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));

    tab = 4*[0 0.25 0.25 0 0.25 0  .5 -0.25 0.25  0.5  0 -0.25 0 ...
             -0.25 -0.25 0] + 2;
    img2 = logical(zeros([3 3]));
    img2(size(img)+2)=0;
    img2(2:N1+1, 2:N2+1) = img;
    
    w = applylut(img2, tab);
    numCells = (sum(w(:), 'double') - 2*prod(size(img2))) / 4;
    
    % compute euler characteristics from graph counts
    %numCells = n - n1 -n2 + n12;

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
    numCells = n - (n1+n2+n3) + (n12+n23+n13) - n123;
    return
end

return 
function res = imConvexImage(img, varargin)
%IMCONVEXIMAGE Compute smallest convex image containing the original pixels
%
%   IMG2 = imConvexImage(IMG);    
%   Returns an image with same dimension as IMG, containing the smallest
%   convex structure that contains the original structure. Works on binary
%   images.
%
%   Requires the 'matGeom' library.
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%

%   HISTORY
%   2004-07-02 process 3D images which contains pixels only on a single
%       slice (was not possible before).
%   2006-08-21 replace convexHull by minConvexHull for 3D case, add psb
%       to specify precision, and call method 'faceNormal' instead of
%       computing normals manually.
%   2007-10-12 clean up code
%   2011-07-05 rename and fix bug for 3D

% initialize with image
res = logical(img);

% switch processing depending on dimension
if ndims(img) == 2 %#ok<ISMAT>

    % first extract the bounding box of the structure
	stats = regionprops(uint8(img), 'boundingBox');
	box = stats(1).BoundingBox;
	b1x = floor(box(2))+1;
	b1y = floor(box(1))+1;
    
    % extract a portion of the image, 
	bimg = uint8(img(b1x:b1x+box(4)-1, b1y:b1y+box(3)-1));
	
	% get pixels indices, and centroid coordinate
	stats = regionprops(bimg, 'pixelList', 'centroid');
	pixels = stats(1).PixelList;
	xc = stats(1).Centroid(1);
	yc = stats(1).Centroid(2);
	
	% compute pixels corners, concatenate into a single array
	N = size(pixels, 1);
	p1 = pixels + [ 0.5*ones(N,1)  0.5*ones(N,1)];
	p2 = pixels + [-0.5*ones(N,1)  0.5*ones(N,1)];
	p3 = pixels + [-0.5*ones(N,1) -0.5*ones(N,1)];
	p4 = pixels + [ 0.5*ones(N,1) -0.5*ones(N,1)];
	corners = unique([p1;p2;p3;p4], 'rows');
	
	% compute convex hull of the corners. Result is a set of indices.
	hull = convhulln(corners);
	
	% convert to a serie of edges, of the form [x0 y0 dx dy].
	lines = createLine(corners(hull(:,1),1:2), corners(hull(:,2),1:2));
	N = size(lines, 1);
	
	% get dimensions of image
	N1 = size(bimg, 1); N2 = size(bimg, 2); 
	inside = true(size(bimg));
	
	
	for i = 1:N
        % matrices of coordinates, translated by line origin
        dy = repmat(reshape( (1:N1)-lines(i, 2), [N1 1]), [1 N2]);  
        dx = repmat(reshape( (1:N2)-lines(i, 1), [1 N2]), [N1 1]);  
        
        % compute dot product for each point of image
        prod = (-dx*lines(i,4) + dy*lines(i,3));
        
        % compute dot product for centroid
        prodc = -(xc-lines(i,1))*lines(i,4) + (yc-lines(i,2))*lines(i,3);
        
        % the sign of each point should be the same than centroid
        inside = inside & prod/prodc>=0;
	end
	
	res(b1x:b1x+box(4)-1, b1y:b1y+box(3)-1) = inside;
    
elseif ndims(img) == 3
    
    % first extract the bounding box of the structure
	stats = regionprops(uint8(img), 'boundingBox');
	box = stats(1).BoundingBox;
	b1 = floor(box(1))+1;
	b2 = floor(box(2))+1;
    b3 = floor(box(3))+1;
	bimg = uint8(img(b2:b2+box(5)-1, b1:b1+box(4)-1, b3:b3+box(6)-1) );
    
	% get pixels indices, and centroid coordinate
	stats = regionprops(bimg, 'pixelList', 'centroid');
	centroid = stats(1).Centroid;
	xc = centroid(1);
	yc = centroid(2);
	zc = centroid(3);
    
    % extract pixels corners, but only on the boundary of structure
    corners = imageBorders(bimg);  
    
    % compute convex hull of the corners. Result is a cell array, each cell
    % containing an array of indices for the corresponding face.
	hull = minConvexHull(corners, 1e-12);
    
    % compute normal vector of each face
    normal = meshFaceNormals(corners, hull);
        
	% get dimensions of image
	N1 = size(bimg, 1);
    N2 = size(bimg, 2);
    N3 = size(bimg, 3);
    
    % initialize result to full image, exterior voxels will be removed by
    % iterating on faces.
	inside = true(size(bimg));
    
    % remove degenerate cases (all points on the same line)
	ind = find(sum(abs(normal),2) > 1e-8);
    normal = normalizeVector3d(normal(ind, :));
    hull = hull(ind);
    N = length(ind);
    
    % initialize size before loop
    vp = zeros([N1 N2 N3 3]);

    for i = 1:N
        % coordinate of the first point of the face
        face = hull{i}; p1 = face(1);
        x1 = corners(p1, 1);
        y1 = corners(p1, 2);
        z1 = corners(p1, 3);
        
        % matrices of coordinates, translated by the origin
        vp(:,:,:,1) = repmat(reshape( (1:N1)-x1, [N1 1 1]), [1 N2 N3]);  
        vp(:,:,:,2) = repmat(reshape( (1:N2)-y1, [1 N2 1]), [N1 1 N3]);  
        vp(:,:,:,3) = repmat(reshape( (1:N3)-z1, [1 1 N3]), [N1 N2 1]);
      
        % create matrix the same dimensions as bimg+3, containing normal
        % of triangle
        vn = repmat(reshape(normal(i,1:3), [1 1 1 3]), [N1 N2 N3 1]);
        
        % compute dot product for each point of image, and check that the
        % sign is the same than for the centroid. If false, pixels are
        % outside polyhedra.
        inside = inside & dot(vp, vn, 4) / dot(normal(i,1:3), [yc-x1 xc-y1 zc-z1]) > 0;
    end
	
    res(b2:b2+box(5)-1, b1:b1+box(4)-1, b3:b3+box(6)-1) = inside;
    
else
    error('sorry, this function process only 2 and 3 dimensions');
end


function corners = imageBorders(img)
%IMAGEBORDERS detect borders in an image
%
%   borders = imageBorders(IMG)
%  
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%

%   HISTORY
%   01/07/2004 : correct bug (pixel borders with z=D3+.5 were counted as
%       z=1.5), and remove some pixels on the borders of image : keep only
%       corners of image. -> finally, less pixels

% initialize array of coordinate
corners = zeros([0 3]); 

% get image dimensions
dim = size(img);
D1 = dim(1); 
D2 = dim(2);

if length(dim) == 3
    D3 = dim(3);
else
    dim = [dim 1];
    D3 = 1;
end

% first direction in image
inds = find(img(1:D1-1, 1:D2, 1:D3) ~= img(2:D1, 1:D2, 1:D3));
[x, y, z] = ind2sub(dim-[1 0 0], inds);
corners = [corners;x+.5 y-.5 z-.5;x+.5 y+.5 z-.5;x+.5 y+.5 z+.5;x+.5 y-.5 z+.5];

% second direction in image
inds = find(img(1:D1,1:D2-1,1:D3)~=img(1:D1,2:D2,1:D3));
[x, y, z] = ind2sub(dim-[0 1 0], inds);
corners = [corners;x-.5 y+.5 z-.5;x-.5 y+.5 z+.5;x+.5 y+.5 z+.5;x+.5 y+.5 z-.5];

% third direction in image
inds = find(img(1:D1, 1:D2, 1:D3-1) ~= img(1:D1, 1:D2, 2:D3));
[x, y, z] = ind2sub(dim-[0 0 1], inds);
corners = [corners;x-.5 y-.5 z+.5;x-.5 y+.5 z+.5;x+.5 y+.5 z+.5;x+.5 y-.5 z+.5];

corners = unique(corners, 'rows');

% add points in the corners of image, if a pixel is present
if img(1,1,1),       corners = [corners; .5 .5 .5];          end
if img(1,1,D3),      corners = [corners; .5 .5 D3+.5];       end
if img(1,D2,1),      corners = [corners; .5 D2+.5 .5];       end
if img(1,D2,D3),     corners = [corners; .5 D2+.5 D3+.5];    end
if img(D1,1,1),      corners = [corners; D1+.5 .5 .5];       end
if img(D1,1,D3),     corners = [corners; D1+.5 .5 D3+.5];    end
if img(D1,D2,1),     corners = [corners; D1+.5 D2+.5 .5];    end
if img(D1,D2,D3),    corners = [corners; D1+.5 D2+.5 D3+.5]; end


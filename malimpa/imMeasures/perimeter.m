function perim = perimeter(img, varargin)
%PERIMETER estimate perimeter of a structure
%
%   p = perimeter(img);
%   Compute estimation of perimeter of structure in image IMG, using a
%   discrete version of Crofton formula in 4 directions (horizontal,
%   verticval, and 2 diagonals) of image.
%   
%   p = perimeter(img, method);
%   Specifies the method to employ :
%   - 'local4' : create polygon around the structure, using 4 connectivity,   
%   and compute perimeter of piolygon. This usually gives a great
%   overestimation of the perimeter.
%   - 'local8' : create polygon using 8 connectivity, giving a smaller
%   overestimation.
%   - 'crofton' (default) : count intersections with discete lines in 4
%   directions (horizontal, vertical, and 2 diagonals), and uses Crofton
%   formula to estimate perimeter.
%   - 'crofton2' : uses only 2 orthogoanl directions to count
%   intersections. Works better for spheres, but not so good for others
%   figures.
%
%   TODO: there is a small biais for some configuration using 'crofton'
%   This concerne only config with type [1 0;0 1] or [0 1;1 0] : the
%   contribution of the diagonal line is not counted, leading to
%   underestimation of perimeter of thin structures.
%
%   
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 03/04/2005
%


method = 'crofton';
if ~isempty(varargin)
    method = varargin{1};
end

option = '';
if length(varargin)>1
    option = varargin{2};
end

% usefull constants
r = sqrt(2)/2;

if strcmpi(method, 'crofton')
    c1 = .5 + sqrt(2)/4;
    c2 = (1 + sqrt(2))/2;
    c3 = 1;
    tab = [0 c1 c1 c2   c1 c2 c3 c1   c1 c3 c2 c1    c2 c1 c1 0]*pi/4;
elseif strcmpi(method, 'crofton2')
    tab = [0 1 1 1   1 1 2 1     1 2 1 1     1 1 1 0]*pi/4;
elseif strcmpi(method, 'local8')
    tab = [0 r r 1   r 1 2*r r   r 2*r 1 r   1 r r 0];
elseif strcmpi(method, 'local4')
    tab = [0 1 1 1   1 1 2 1     1 2 1 1     1 1 1 0];
elseif strcmpi(method, 'freeman4')
    % count number of edges in each orthogonal direction
    e1 = sum(sum(img(1:end-1, :) & img(2:end, :)));
    e2 = sum(sum(img(:, 1:end-1) & img(:, 2:end)));
    
    % count number of square faces
    e1234 = sum(sum(...
        img(1:end-1, 1:end-1) & img(1:end-1, 2:end) & ...
        img(2:end, 1:end-1) & img(2:end, 2:end) ));
    
    % count perimeter as number of  boundary edges. It is  computed by
    % counting all edges twices (one for each side), and by removing square
    % configurations 4 times (one for each side).
    perim = 2*(e1+e2) - 4*e1234;
    
    if strcmpi(option, 'noedge')
        % remove perimeter computed on the edge of image
        e1 = sum(sum(img([1 end], 1:end-1) & img([1 end], 2:end)));
        e2 = sum(sum(img(1:end-1, [1 end]) & img(2:end, [1 end])));
        perim = perim - e1 - e2;
    end
    return;
elseif strcmpi(method, 'freeman8')
    % count number of edges in each orthogonal and diagonal direction
    e1 = sum(sum(img(1:end-1, :) & img(2:end, :)));
    e2 = sum(sum(img(:, 1:end-1) & img(:, 2:end)));
    e3 = sum(sum(img(1:end-1, 1:end-1) & img(2:end, 2:end)));
    e4 = sum(sum(img(2:end, 1:end-1) & img(1:end-1, 2:end)));
    
    % count number of triangle faces in each direction
    e123 = sum(sum(img(1:end-1, 1:end-1) & img(1:end-1, 2:end) & img(2:end, 1:end-1)));
    e124 = sum(sum(img(1:end-1, 1:end-1) & img(1:end-1, 2:end) & img(2:end, 2:end)));
    e134 = sum(sum(img(1:end-1, 1:end-1) & img(2:end, 1:end-1) & img(2:end, 2:end)));
    e234 = sum(sum(img(1:end-1, 2:end) & img(2:end, 1:end-1) & img(2:end, 2:end)));

    % count number of square faces
    e1234 = sum(sum(...
        img(1:end-1, 1:end-1) & img(1:end-1, 2:end) & ...
        img(2:end, 1:end-1) & img(2:end, 2:end) ));
    
    % count perimeter as number of  boundary edges. It is  computed by
    % counting all edges twices (one for each side), by removing triangle
    % configurations three times (one foreach side of triangle), and adding
    % square configuration 4 times (one for each side, also).
    perim = 2*(e1+e2+e3+e4) - 3*(e123+e124+e134+e234) + 4*e1234;
    
    if strcmpi(option, 'noedge')
        % remove perimeter computed on the edge of image
        e1 = sum(sum(img([1 end], 1:end-1) & img([1 end], 2:end)));
        e2 = sum(sum(img(1:end-1, [1 end]) & img(2:end, [1 end])));
        perim = perim - e1 - e2;
    end

    return;
else
    error('perimeter : unknown method option');
end
conf = imLUT(grayFilter(img>0), tab);

perim = sum(conf(:));




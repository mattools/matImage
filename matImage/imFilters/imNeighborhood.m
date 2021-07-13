function neighs = imNeighborhood(img, pos, se, varargin)
% Return the neighborhood of a given pixel as an array.
%
%   NEIGHBORS = imNeighborhood(IMG, POS, SE)
%   Returns the values of pixels located around a given pixel. 
%   If pixel is located close to the border, and neighborhood contains area
%   outside image, result is padded with 0.
%
%   NEIGHBORS = imNeighborhood(IMG, POS, SE, METHOD)
%   BOUNDARY is a string which can be:
%   X           fill up with the given value (default)
%   'symmetric' ('mirror')  same as imfilter
%   'replicate' ('nearest') same as imfilter
%   'circular'  ('periodic') same as imfilter
%   'crop'      returns a result smaller than the size of SE.
%   
%   Example
%   imNeighborhood
%
%   See also
%     padarray (image processing toolbox)
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2007-08-21,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% TODO: works only for 2D, could be rewritten for any dimension

% extract input method if present
method = 0;
if ~isempty(varargin)
    method = varargin{1};
end

% size of input image
dim = size(img);

% position of central pixel
p1 = pos(1);
p2 = pos(2);

% extract offsets given by structuring element
offsets = getneighbors(strel(se));

% convert to 3D if needed
if size(offsets, 2) < length(dim)
    offsets(0, length(dim)) = 0;
end

% number of offsets, and allocate memory
N = size(offsets, 1);
neighs  = zeros(N, 1);

% switch on method, and iterate along neighbors
if isnumeric(method)
    % if neighbor is outside image limits, replace with value 'method'
    for i = 1:N
        neighs(i) = method;
        d1 = p1 + offsets(i, 1);
        d2 = p2 + offsets(i, 2);
        if d1 > 0 && d1 <= dim(1) && d2 > 0 && d2 <= dim(2)
            neighs(i) = img(d1, d2);
        end
    end
elseif ismember(method, {'symmetric', 'mirror'})
    for i = 1:N
        d1 = mod(p1 + offsets(i, 1)-1, 2*dim(1))+1;
        d1 = min(d1, 2*dim(1)+1-d1);
        d2 = mod(p2 + offsets(i, 2)-1, 2*dim(2))+1;
        d2 = min(d2, 2*dim(2)+1-d2);
        neighs(i) = img(d1, d2);
    end
elseif ismember(method, {'replicate', 'nearest'})
    % if neighbor is outside image limits, use nearest image pixel
    for i = 1:N
        d1 = min(max(p1 + offsets(i, 1), 1), dim(1));
        d2 = min(max(p2 + offsets(i, 2), 1), dim(2));
        neighs(i) = img(d1, d2);
    end
elseif ismember(method, {'circular', 'periodic'})
    for i = 1:N
        d1 = mod(p1 + offsets(i, 1)-1, dim(1))+1;
        d2 = mod(p2 + offsets(i, 2)-1, dim(2))+1;        
        neighs(i) = img(d1, d2);
    end
elseif ismember(method, {'crop'})
    % if neighbor is outside image limits, compute an index of 'inside'
    % values, and keep only these ones
    inside = true(N, 1);
    for i = 1:N
        d1 = p1 + offsets(i, 1);
        d2 = p2 + offsets(i, 2);
        if d1 > 0 && d1 <= dim(1) && d2 > 0 && d2 <= dim(2)
            neighs(i) = img(d1, d2);
        else
            inside(i) = false;
        end        
    end
    neighs = neighs(inside);
end



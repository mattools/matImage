function [chi labels] = imEuler2d(img, varargin)
% Euler number of a binary 2D image
%
%   The function computes the Euler number, or Euler-Poincare
%   characteristic, of a binary 2D image. The result corresponds to the
%   number of connected components, minus the number of holes in the image.
%
%   CHI = imEuler2d(IMG);
%   return the Euler-Poincaré Characteristic.
%
%   CHI = imEuler2d(IMG, CONN);
%   Specify connecivity used. Currently 4 and 8 connectivities are
%   supported.
%
%   Example
%   img = imread('coins.png');
%   bin = imopen(img>80, ones(3,3));
%   imEuler2d(bin)
%   ans = 
%       10
%
%   See Also:
%   minkowski, imPerimeter, regionprops
%   
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   15/01/2010: rewrite using old function epc


% check image dimension
if ndims(img) ~= 2
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels==0) = [];
    
    % allocate result array
    nLabels = length(labels);
    chi = zeros(nLabels, 1);

    props = regionprops(img, 'BoundingBox');
    
    % compute Euler number of each label considered as binary image
    for i = 1:nLabels
        label = labels(i);
        bin = imcrop(img, props(label).BoundingBox) == label;
        chi(i) = imEuler2d(bin, varargin{:});
    end
    
    return;
end


% in case of binary image, compute only one label
labels = 1;

% check connectivity
conn = 4;
if ~isempty(varargin)
    conn = varargin{1};
end

% size of image in each direction
dim = size(img);
N1 = dim(1); 
N2 = dim(2);

% compute number of nodes, number of edges (H and V) and number of faces.
% principle is erosion with simple structural elements (line, square)
% but it is replaced here by simple boolean operation, which is faster

% count vertices
n = sum(img(:));

% count horizontal and vertical edges
n1 = sum(sum(img(1:N1-1,:) & img(2:N1,:)));
n2 = sum(sum(img(:,1:N2-1) & img(:,2:N2)));

% count square faces
n1234 = sum(sum(...
    img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & ...
    img(2:N1,1:N2-1)   & img(2:N1,2:N2) ));

if conn == 4
    % compute euler characteristics from graph counts
    chi = n - n1 - n2 + n1234;
    return;
    
elseif conn == 8    
    % For 8-connectivity, need also to count diagonal edges
    n3 = sum(sum(img(1:N1-1,1:N2-1) & img(2:N1,2:N2)));
    n4 = sum(sum(img(1:N1-1,2:N2)   & img(2:N1,1:N2-1)));
    
    % and triangular faces
    n123 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,1:N2-1) ));
    n124 = sum(sum(img(1:N1-1,1:N2-1) & img(1:N1-1,2:N2) & img(2:N1,2:N2) ));
    n134 = sum(sum(img(1:N1-1,1:N2-1) & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));
    n234 = sum(sum(img(1:N1-1,2:N2)   & img(2:N1,1:N2-1) & img(2:N1,2:N2) ));
    
    % compute euler characteristics from graph counts
    % chi = Nvertices - Nedges + Ntriangles + Nsquares
    chi = n - (n1+n2+n3+n4) + (n123+n124+n134+n234) - n1234;
    
else
    error('imEuler2d: uknown connectivity option');
end

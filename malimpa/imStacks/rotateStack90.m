function [img newInds] = rotateStack90(img, axis, varargin)
%ROTATESTACK90 Rotate a 3D image by 90 degrees around one image axis
%
%   RES = rotateStack90(IMG, AXIS);
%   IMG is a 3D image (either gray scale or color), and AXIS is the axis
%   number, in matrix convention: 1-> y axis, 2->x-axis, 3->z-axis.
%   AXIS can also be specified as letter: 'x', 'y' or 'z'.
%
%   RES = rotateStack90(IMG, AXIS, NUMBER);
%   Apply NUMBER rotation around the axis. NUMBER is the number of
%   rotations to apply, between 1 and 3. NUMER can also be negative, in
%   this case the rotation is performed in reverse direction.
%
%   [RES INDS] = rotateStack90(...);
%   Returns also informations about rotation.
%   
%
%   Example
%   img = discreteBall(1:90, 1:100, 1:110, [50 50 50 30 20 10]);
%   img2 = rotateStack90(img, 'x');
%   figure(1); clf;
%   subplot(121); imshow(rot90(img(:,:,50)));
%   title('rotated slice');
%   subplot(122); imshow(squeeze(img2(50,:,:))); 
%   title('slice of rotated image');
%
%   See also
%   stacks, stackRotate90
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-18,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


% parse axis, and check bounds
axis = parseAxisIndex_ijk(axis);

% positive or negative rotation
n = 1;
if ~isempty(varargin)
    n = varargin{1};
end

% ensure n is between 0 (no rotation) and 3 (rotation in inverse direction)
n = mod(mod(n, 4) + 4, 4);

% convert between 1 and 4
if n==0
    n = 4;
end

% all permutations: row for axis (ijk ordering), column for number of
% rotations, from 1 to 4
% permDimParams = {...
%     [2 3], [], [2 3]; ...
%     [1 3], [], [1 3]; ...
%     [1 2], [], [1 2] };
permDimParams = {...
    [1 3 2], [1 2 3], [1 3 2], [1 2 3]; ...
    [3 2 1], [1 2 3], [3 2 1], [1 2 3]; ...
    [2 1 3], [1 2 3], [2 1 3], [1 2 3] };

% all axis flipping: row for axis (ijk ordering), column for number of
% rotations, from 1 to 4
flipDimParams = {...
    3, [2 3], 2, []; ...
    1, [1 3], 3, []; ...
    2, [1 2], 1, [] } ;

newIndParams = {...
    [3 2 1], [1 2 3], [3 2 1], [1 2 3]; ...
    [1 3 2], [1 2 3], [1 3 2], [1 2 3]; ...
    [2 1 3], [1 2 3], [2 1 3], [1 2 3]};

% compute rotation params in ijk ordering
permInds = permDimParams{axis, n};
flipInds = flipDimParams{axis, n};
newInds  = newIndParams{axis, n};

% in case of a color image, need to adapt indices
if length(size(img))>3
    % convert index 3 to index 4
    permInds(permInds==3) = 4; 
    % insert color index into indices array
    permInds = [permInds(1:2) 3 permInds(3)];
    
    % convert indices of dimensions to permute
    flipInds(flipInds==3) = 4;
end

% apply matrix dimension permutation
img = permute(img, permInds);

% depending on rotation, some dimensions must be fliped
for i=1:length(flipInds)
    img = flipdim(img, flipInds(i));
end

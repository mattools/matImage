function [img permInds flipInds] = stackRotate90(img, axis, varargin)
%STACKROTATE90 Rotate a 3D image by 90 degrees around one image axis
%
%   RES = stackRotate90(IMG, AXIS);
%   IMG is a 3D image (either gray scale or color), and AXIS is the axis
%   number, in XYZ convention: 1-> X-axis, 2->Y-axis, 3->Z-axis.
%   AXIS can also be specified as letter: 'x', 'y' or 'z'.
%
%   RES = stackRotate90(IMG, AXIS, NUMBER);
%   Apply NUMBER rotation around the axis. NUMBER is the number of
%   rotations to apply, between 1 and 3. NUMER can also be negative, in
%   this case the rotation is performed in reverse direction.
%
%   [RES PERM] = stackRotate90(...);
%   [RES PERM FLIP] = stackRotate90(...);
%   Returns also informations about rotation:
%   PERM is the permutation of indices from the first image, such that
%   stackSize(RES) = stackSize(permute(IMG, PERM));
%   FLIP is the set of dimension indices that were flipped after dimension
%   permutation.
%
%   Example
%     img = discreteEllipsoid(1:90, 1:100, 1:110, [50 50 50 30 20 10]);
%     img2 = stackRotate90(img, 'x');
%     figure(1); clf;
%     subplot(121); imshow(rot90(img(:,:,50)));
%     title('rotated slice');
%     subplot(122); imshow(squeeze(img2(50,:,:))); 
%     title('slice of rotated image');
%
%   See also
%   imStacks, rotateStack90
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-05-18,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


% parse axis, and check bounds
axis = parseAxisIndex(axis);

% get rotation parameters in xyz ordering
[permInds flipInds] = getStackRotate90Params(axis, varargin{:});

% check if image is color
colorImage = length(size(img)) > 3;

% convert indices in xyz ordering to ijk ordering
permInds2 = xyz2ijk(permInds([2 1 3]), colorImage);
flipInds2 = xyz2ijk(flipInds, colorImage);

% in the case of color image, adds the channel coordinate after spatial
% coordinates
if colorImage
    permInds2 = [permInds2([1 2]) 3 permInds2(3)];
end

% apply matrix dimension permutation
img = permute(img, permInds2);

% depending on rotation, some dimensions must be fliped
for i=1:length(flipInds2)
    img = flipdim(img, flipInds2(i));
end


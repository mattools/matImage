function [res, permInds, flipInds] = imRotate90(img, number, axis)
%IMROTATE90  Rotate a 3D image by 90 degrees around one image axis
%
%   RES = imRotate90(IMG, NUMBER);
%   Rotates counter a planar image by 90 degrees n-times. The rotation is
%   oriented counter-clockwise in physical (x,y) basis, and clockwise in
%   image (i,j) basis.
%
%   RES = imRotate90(IMG, NUMBER, AXIS);
%   If IMG is a 3D image (either gray scale or color), AXIS is the axis
%   number, in XYZ convention: 1-> X-axis, 2->Y-axis, 3->Z-axis.
%   AXIS can also be specified as letter: 'x', 'y' or 'z'. If axis is not
%   specified, the default value 3 (for z axis) is used.
%
%   RES = imRotate90(IMG, AXIS, NUMBER);
%   Apply NUMBER rotation around the axis. NUMBER is the number of
%   rotations to apply, between 1 and 3. NUMER can also be negative, in
%   this case the rotation is performed in reverse direction.
%
%   [RES PERM] = imRotate90(...);
%   [RES PERM FLIP] = imRotate90(...);
%   Returns also informations about rotation:
%   PERM is the permutation of indices from the first image, such that
%   stackSize(RES) = stackSize(permute(IMG, PERM));
%   FLIP is the set of dimension indices that were flipped after dimension
%   permutation.
%
%   Example
%     % Rotate a grayscale image
%     img = imread('cameraman.tif');
%     img2 = imRotate90(img);
%     img3 = imRotate90(img, 3);
%     figure;
%     subplot(1, 3, 1); imshow(img);
%     subplot(1, 3, 2); imshow(img2);
%     subplot(1, 3, 3); imshow(img3);
%
%     % Rotate a color image
%     img = imread('peppers.png');
%     img2 = imRotate90(img);
%     figure; imshow(img2);
%
%     % Rotate a 3D image 
%     metadata = analyze75info('brainMRI.hdr');
%     img = analyze75read(metadata);
%     img2 = imRotate90(img, 1, 'z');
%     figure(1); clf;
%     imshow(rot90(img(:,:,5)));
%     title('rotated slice');
%
%   See also
%   imFlip, rot90

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2012-05-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% default are 90 degrees, and z axis
if nargin < 2
    number = 1;
end
if nargin < 3
    axis = 3;
end

% parse axis, and check bounds
axis = parseAxisIndex(axis);

% get rotation parameters in xyz ordering
[permInds, flipInds] = getStackRotate90Params(axis, number);

% check if image is color
colorImage = isColorImage(img);

% convert indices in xyz ordering to ijk ordering
permInds2 = xyz2ijk(permInds([2 1 3]), colorImage);
flipInds2 = xyz2ijk(flipInds, colorImage);

% in the case of color image, adds the channel coordinate after spatial
% coordinates
if colorImage
    permInds2 = [permInds2([1 2]) 3 permInds2(3)];
end

% apply matrix dimension permutation
res = permute(img, permInds2);

% depending on rotation, some dimensions must be fliped
% for i = 1:length(flipInds2)
%     res = flipdim(res, flipInds2(i));
% end
if verLessThan('matlab', '8.4.0')
    % use old function 'flipdim'
    for i = 1:length(flipInds2)
        res = flipdim(res, flipInds2(i)); %#ok<DFLIPDIM>
    end
else
    for i = 1:length(flipInds2)
        res = flip(res, flipInds2(i));
    end
end

function [permDims, flipDims] = getStackRotate90Params(axis, varargin)
%GETROTATE90PARAMETERS Return permutation and flip indices of 90° rotation
%
%   [PERMDIMS FLIPDIMS] = getStackRotate90Params(AXIS, NUMBER)
%   AXIS is the axis of rotation, between 1 and 3, corresponding to x, y
%   and z directions respectively.
%   NUMBER is the number of rotations around this axis, between 1 and 3.
%   NUMBER can also be 0 or 4, in this case this is equivalent to no
%   rotation at all.
%
%   Parameters are returned such that all rotations by 90° are direct in
%   the Oxyz basis, that is:
%   - rotation by 90° around X axis transforms Y axis to Z axis
%   - rotation by 90° around Y axis transforms Z axis to X axis
%   - rotation by 90° around Z axis transforms X axis to Y axis
%
%   Example
%   getStackRotate90Params
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% parse axis, and check bounds
axis = parseAxisIndex(axis);

% positive or negative rotation
n = 1;
if ~isempty(varargin)
    n = varargin{1};
end

% ensure n is between 0 (no rotation) and 3 (rotation in inverse direction)
n = mod(mod(n, 4) + 4, 4);

% case of no rotations (in case of...)
if n == 0
    permDims = [1 2 3];
    flipDims = [];
    return;
end

% all permutations: row for axis (xyz ordering), column for number of
% rotations, from 1 to 3
permDimParams = {...
    [1 3 2], [1 2 3], [1 3 2]; ...
    [3 2 1], [1 2 3], [3 2 1]; ...
    [2 1 3], [1 2 3], [2 1 3] };

% all axis flipping: row for axis (xyz ordering), column for number of
% rotations, from 1 to 3
flipDimParams = {...
    2, [2 3], 3; ...
    3, [1 3], 1; ...
    1, [1 2], 2 } ;

% compute rotation params in xyz ordering
permDims = permDimParams{axis, n};
flipDims = flipDimParams{axis, n};

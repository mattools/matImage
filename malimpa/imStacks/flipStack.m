function img = flipStack(img, axis)
%FLIPSTACK Flip a 3D image along specified X, Y, or Z dimension
%
%   RES = flipStack(IMG, AXIS);
%   Flips the stack in the given direction.
%   IMG is a 3D image (either gray scale or color), and AXIS is the axis
%   number, in XYZ convention: 1-> X-axis, 2->Y-axis, 3->Z-axis.
%   AXIS can also be specified as letter: 'x', 'y' or 'z'.
%
%
%   Example
%     % display slice of a flipped stack
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     % note: flip in the Y direction
%     I2 = flipStack(I, 2);
%     figure;
%     subplot(121); imshow(I(:,:,13));
%     subplot(122); imshow(I2(:,:,13));
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

% check if image is color
colorImage = length(size(img)) > 3;

% convert indices in xyz ordering to ijk ordering
flipInd = xyz2ijk(axis, colorImage);

% flip the inner array
img = flipdim(img, flipInd);

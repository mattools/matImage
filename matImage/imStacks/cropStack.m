function res = cropStack(img, box)
%CROPSTACK Crop a 3D image with the specified box limits
%
%   RES = cropStack(IMG, BOX);
%   Crops the input image IMG with the bounds specified by BOX.
%
%   Example
%     % display slice of a cropped stack
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     % note: flip in the Y direction
%     I2 = cropStack(I, [10 100 10 100 5 20]);
%     figure;
%     subplot(121); imshow(I(:,:,13));
%     subplot(122); imshow(I2(:,:,13));
%
%   See also
%   imStacks, rotateStack90, flipStack

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-07-22,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer

% compute ranges of indices
lx = box(1):box(2);
ly = box(3):box(4);
lz = box(5):box(6);

% check if image is color
if length(size(img)) > 3;
    res = img(ly, lx, :, lz);
else
    res = img(ly, lx, lz);
end

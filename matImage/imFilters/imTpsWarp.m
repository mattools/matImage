function res = imTpsWarp(img, pts1, pts2)
%IMTPSWARP Warp an image using Thin-Plate Splines transform
%
%   RES = imTpsWarp(IMG, PTS1, PTS2)
%   IMG:    the image to warp
%   PTS1:   the NK-by-2 array of landmark coordinates in reference space
%   PTS2:   the NK-by-2 array of landmark coordinates in image space
%
%   Example
%     img = imread('cameraman.tif');
%     [x y] = meshgrid(50:50:200, 50:50:200);
%     pts1 = [x(:) y(:)];
%     pts2 = pts1 + randn(size(pts1)) * 10;
%     res = imTpsWarp(img, pts1, pts2);
%     imshow(res, [0 255]); hold on;
%     plot([pts1(:,1) pts2(:,1)]', [pts1(:,2) pts2(:,2)]', 'b-')
%     plot(pts2(:,1), pts2(:,2), 'bo')
%
%   See also
%     imtransform, fitAffineTransform, imEvaluate
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-11-28,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% initialize the list of vertices for interpolation
dim = size(img);
lx = 1:dim(2);
ly = 1:dim(1);
[x, y] = meshgrid(lx, ly);

% rescale landmarks coordinates and image coordinates for better accuracy
scaleFactor = max(max(abs(x(:))), max(abs(y(:)))) * .01;
pts1 = pts1 / scaleFactor;
pts2 = pts2 / scaleFactor;
x = x / scaleFactor;
y = y / scaleFactor;

% create the K matrix
nk = size(pts1, 1);
K = zeros(nk, nk);
for i = 1:nk
    for j = [1:i-1 i+1:nk]
        r = vectorNorm(pts1(i,:) - pts1(j,:));
        K(i,j) = r * r * log(r);
    end
end

% create derived matrices
Q = [ones(nk,1) pts1];
L = [K Q ; Q' zeros(3,3)];

% compute inverse matrix
Linv = inv(L);

% keep only the upper-right part of the inverse matrix
Lk = Linv(1:nk, 1:nk);
L21 = Linv(nk+1:end, 1:nk);

% compute warping weights associated to each landmark
W = Lk * pts2;

% compute affine coefficients
A = L21 * pts2;

% affine part of TPS
x2 = x * A(2,1) + y * A(3, 1) + A(1,1);
y2 = x * A(2,2) + y * A(3, 2) + A(1,2);

% add contribution of each landmark
for k = 1:nk
    rho = hypot(x - pts1(k,1), y - pts1(k,2));
    rho = r2logr(rho);
    x2 = x2 + W(k,1) * rho;
    y2 = y2 + W(k,2) * rho;
end
   
% scale coordinates back
x2 = x2 * scaleFactor;
y2 = y2 * scaleFactor;

% evaluate interpolated image
res = imEvaluate(img, x2, y2);

function varargout = demoImJointHistogram(varargin)
%DEMOIMJOINTHISTOGRAM  One-line description here, please.
%   output = demoImJointHistogram(input)
%
%   Example
%   demoImJointHistogram
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-12-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2009 INRA - Cepia Software Platform.

%% Chargement des images

% image fixe
img1 = imread('img1.bmp');

% image a recaler
img2 = imread('img2.bmp');

% image apres recalage
rec = imread('res-rigid2.tif');

% nouvelle figure
figure(1); clf;

% affiche image de base
subplot(131);
imshow(img1);
title('image fixe');
subplot(132);
imshow(img2);
title('image a recaler');
subplot(133);
imshow(rec);
title('image recalee');


%% Avant recalage

% calcule histo joint
res = imJointHistogram(img1, img2);

% affiche image et histo joint (log)
figure(2);
subplot(121);
imshow(img2)
title('image a recaler');
subplot(122);
imshow(log(res), [0 log(max(res(:)))]);
title('joint histo');


%% Apres recalage

% calcule histo joint
res2 = imJointHistogram(img1, rec);

% affiche image et histo joint  (log)
figure(3);
subplot(121);
imshow(rec);
title('image recalee');
subplot(122);
imshow(log(res2), [0 log(max(res2(:)))]);
title('joint histo');


%% Decalage de l'image de depart

% histo joint apres decalage de 1 pixel
hDec1 = imJointHistogram(img1(1:end-1, :), img1(2:end, :));

% histo joint apres decalage de 2 pixels
hDec2 = imJointHistogram(img1(1:end-2, :), img1(3:end, :));

% affiche les histo joints
figure(4); clf;
subplot(121);
imshow(log(hDec1), [0 log(max(hDec1(:)))]);
title('decalage 1 px');
subplot(122);
imshow(log(hDec2), [0 log(max(hDec2(:)))]);
title('decalage 2 px');


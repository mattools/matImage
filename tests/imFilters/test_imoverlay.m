function test_suite = test_imOverlay(varargin)
%TEST_IMOVERLAY  One-line description here, please.
%
%   output = test_imOverlay(input)
%
%   Example
%   test_imOverlay
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

initTestSuite;


%% Tests for Grayscale image 2D

function test_overlayMask_gray2d %#ok<*DEFNU>

img = createGrayImage2d;
mask = createMask2d;
res = imOverlay(img, mask);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1));
assertEqual(uint8(100), res(4, 7, 1));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(0),   res(2, 4, 3));


function test_overlayColor_gray2d

img = createGrayImage2d;
mask = createMask2d;

% magenta overlay
res = imOverlay(img, mask, [1 0 1]);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1));
assertEqual(uint8(100), res(4, 7, 1));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(255), res(2, 4, 3));


function test_overlayColorCode_gray2d

img = createGrayImage2d;
mask = createMask2d;

% magenta overlay
res = imOverlay(img, mask, 'm');

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1));
assertEqual(uint8(100), res(4, 7, 1));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(255), res(2, 4, 3));


function test_overlayGrayImage_gray2d

img = createGrayImage2d;
mask = createMask2d;
ovr = createGrayOverlay2d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1));
assertEqual(uint8(100), res(4, 7, 1));

% pixels inside mask are set to red color
assertEqual(uint8(200), res(2, 4, 1));
assertEqual(uint8(200), res(2, 4, 2));
assertEqual(uint8(200), res(2, 4, 3));

function test_overlayColorImage_gray2d

img = createGrayImage2d;
mask = createMask2d;
ovr = createColorOverlay2d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1));
assertEqual(uint8(100), res(4, 7, 1));

% pixels inside mask are set to red color
assertEqual(uint8(50), res(2, 4, 1));
assertEqual(uint8(150), res(2, 4, 2));
assertEqual(uint8(250), res(2, 4, 3));


%% Tests for Color image 2D

function test_overlayMask_color2d

img = createColorImage2d;
mask = createMask2d;
res = imOverlay(img, mask);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2));
assertEqual(uint8(160), res(1, 1, 3));
assertEqual(uint8(80),  res(4, 7, 1));
assertEqual(uint8(120), res(4, 7, 2));
assertEqual(uint8(160), res(4, 7, 3));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(0),   res(2, 4, 3));


function test_overlayColor_color2d

img = createColorImage2d;
mask = createMask2d;

% magenta overlay
res = imOverlay(img, mask, [1 0 1]);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2));
assertEqual(uint8(160), res(1, 1, 3));
assertEqual(uint8(80),  res(4, 7, 1));
assertEqual(uint8(120), res(4, 7, 2));
assertEqual(uint8(160), res(4, 7, 3));


% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(255), res(2, 4, 3));


function test_overlayColorCode_color2d

img = createColorImage2d;
mask = createMask2d;

% magenta overlay
res = imOverlay(img, mask, 'm');

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2));
assertEqual(uint8(160), res(1, 1, 3));
assertEqual(uint8(80),  res(4, 7, 1));
assertEqual(uint8(120), res(4, 7, 2));
assertEqual(uint8(160), res(4, 7, 3));


% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1));
assertEqual(uint8(0),   res(2, 4, 2));
assertEqual(uint8(255), res(2, 4, 3));


function test_overlayGrayImage_color2d

img = createColorImage2d;
mask = createMask2d;
ovr = createGrayOverlay2d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2));
assertEqual(uint8(160), res(1, 1, 3));
assertEqual(uint8(80),  res(4, 7, 1));
assertEqual(uint8(120), res(4, 7, 2));
assertEqual(uint8(160), res(4, 7, 3));


% pixels inside mask are set to red color
assertEqual(uint8(200), res(2, 4, 1));
assertEqual(uint8(200), res(2, 4, 2));
assertEqual(uint8(200), res(2, 4, 3));

function test_overlayColorImage_color2d

img = createColorImage2d;
mask = createMask2d;
ovr = createColorOverlay2d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2));
assertEqual(uint8(160), res(1, 1, 3));
assertEqual(uint8(80),  res(4, 7, 1));
assertEqual(uint8(120), res(4, 7, 2));
assertEqual(uint8(160), res(4, 7, 3));


% pixels inside mask are set to red color
assertEqual(uint8(50), res(2, 4, 1));
assertEqual(uint8(150), res(2, 4, 2));
assertEqual(uint8(250), res(2, 4, 3));


%% Tests for Grayscale image 3D

function test_overlayMask_gray3d

img     = createGrayImage3d;
mask    = createMask3d;
res     = imOverlay(img, mask);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1, 1));
assertEqual(uint8(100), res(1, 1, 2, 1));
assertEqual(uint8(100), res(1, 1, 3, 1));
assertEqual(uint8(100), res(4, 7, 1, 9));
assertEqual(uint8(100), res(4, 7, 2, 9));
assertEqual(uint8(100), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(0),   res(2, 4, 3, 7));


function test_overlayColor_gray3d

img     = createGrayImage3d;
mask    = createMask3d;

% magenta overlay
res = imOverlay(img, mask, [1 0 1]);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1, 1));
assertEqual(uint8(100), res(1, 1, 2, 1));
assertEqual(uint8(100), res(1, 1, 3, 1));
assertEqual(uint8(100), res(4, 7, 1, 9));
assertEqual(uint8(100), res(4, 7, 2, 9));
assertEqual(uint8(100), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(255), res(2, 4, 3, 7));


function test_overlayColorCode_gray3d

img     = createGrayImage3d;
mask    = createMask3d;

% magenta overlay
res = imOverlay(img, mask, 'm');

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1, 1));
assertEqual(uint8(100), res(1, 1, 2, 1));
assertEqual(uint8(100), res(1, 1, 3, 1));
assertEqual(uint8(100), res(4, 7, 1, 9));
assertEqual(uint8(100), res(4, 7, 2, 9));
assertEqual(uint8(100), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(255), res(2, 4, 3, 7));


function test_overlayGrayImage_gray3d

img     = createGrayImage3d;
mask    = createMask3d;
ovr     = createGrayOverlay3d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1, 1));
assertEqual(uint8(100), res(1, 1, 2, 1));
assertEqual(uint8(100), res(1, 1, 3, 1));
assertEqual(uint8(100), res(4, 7, 1, 9));
assertEqual(uint8(100), res(4, 7, 2, 9));
assertEqual(uint8(100), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(200), res(2, 4, 1, 7));
assertEqual(uint8(200), res(2, 4, 2, 7));
assertEqual(uint8(200), res(2, 4, 3, 7));

function test_overlayColorImage_gray3d

img     = createGrayImage3d;
mask    = createMask3d;
ovr     = createColorOverlay3d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(100), res(1, 1, 1, 1));
assertEqual(uint8(100), res(1, 1, 2, 1));
assertEqual(uint8(100), res(1, 1, 3, 1));
assertEqual(uint8(100), res(4, 7, 1, 9));
assertEqual(uint8(100), res(4, 7, 2, 9));
assertEqual(uint8(100), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(50),  res(2, 4, 1, 7));
assertEqual(uint8(150), res(2, 4, 2, 7));
assertEqual(uint8(250), res(2, 4, 3, 7));


%% Tests for Color image 3D

function test_overlayMask_color3d

img     = createColorImage3d;
mask    = createMask3d;
res     = imOverlay(img, mask);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2, 1));
assertEqual(uint8(160), res(1, 1, 3, 1));
assertEqual(uint8(80),  res(4, 7, 1, 9));
assertEqual(uint8(120), res(4, 7, 2, 9));
assertEqual(uint8(160), res(4, 7, 3, 9));

% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(0),   res(2, 4, 3, 7));


function test_overlayColor_color3d

img     = createColorImage3d;
mask    = createMask3d;

% magenta overlay
res = imOverlay(img, mask, [1 0 1]);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2, 1));
assertEqual(uint8(160), res(1, 1, 3, 1));
assertEqual(uint8(80),  res(4, 7, 1, 9));
assertEqual(uint8(120), res(4, 7, 2, 9));
assertEqual(uint8(160), res(4, 7, 3, 9));


% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(255), res(2, 4, 3, 7));


function test_overlayColorCode_color3d

img     = createColorImage3d;
mask    = createMask3d;

% magenta overlay
res = imOverlay(img, mask, 'm');

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2, 1));
assertEqual(uint8(160), res(1, 1, 3, 1));
assertEqual(uint8(80),  res(4, 7, 1, 9));
assertEqual(uint8(120), res(4, 7, 2, 9));
assertEqual(uint8(160), res(4, 7, 3, 9));


% pixels inside mask are set to red color
assertEqual(uint8(255), res(2, 4, 1, 7));
assertEqual(uint8(0),   res(2, 4, 2, 7));
assertEqual(uint8(255), res(2, 4, 3, 7));


function test_overlayGrayImage_color3d

img     = createColorImage3d;
mask    = createMask3d;
ovr     = createGrayOverlay3d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2, 1));
assertEqual(uint8(160), res(1, 1, 3, 1));
assertEqual(uint8(80),  res(4, 7, 1, 9));
assertEqual(uint8(120), res(4, 7, 2, 9));
assertEqual(uint8(160), res(4, 7, 3, 9));


% pixels inside mask are set to red color
assertEqual(uint8(200), res(2, 4, 1, 7));
assertEqual(uint8(200), res(2, 4, 2, 7));
assertEqual(uint8(200), res(2, 4, 3, 7));


function test_overlayColorImage_color3d

img     = createColorImage3d;
mask    = createMask3d;
ovr     = createColorOverlay3d;

% magenta overlay
res = imOverlay(img, mask, ovr);

% check size
assertEqual([10 10 3 10], size(res));

% pixels outside mask do not change
assertEqual(uint8(80),  res(1, 1, 1, 1));
assertEqual(uint8(120), res(1, 1, 2, 1));
assertEqual(uint8(160), res(1, 1, 3, 1));
assertEqual(uint8(80),  res(4, 7, 1, 9));
assertEqual(uint8(120), res(4, 7, 2, 9));
assertEqual(uint8(160), res(4, 7, 3, 9));


% pixels inside mask are set to red color
assertEqual(uint8(50), res(2, 4, 1, 7));
assertEqual(uint8(150), res(2, 4, 2, 7));
assertEqual(uint8(250), res(2, 4, 3, 7));



%% utils for 2D images

function img = createGrayImage2d

img = zeros([10 10], 'uint8');
img(:) = 100;

function img = createColorImage2d

img = zeros([10 10 3], 'uint8');
img(:,:,1) = 80;
img(:,:,2) = 120;
img(:,:,3) = 160;

function mask = createMask2d

mask = false([10 10]);
mask(2:3, 4:6) = true;

function ovr = createGrayOverlay2d

ovr = zeros([10 10], 'uint8');
ovr(:) = 200;

function ovr = createColorOverlay2d

ovr = zeros([10 10 3], 'uint8');
ovr(:, :, 1) = 50;
ovr(:, :, 2) = 150;
ovr(:, :, 3) = 250;


%% utils for 3D images

function img = createGrayImage3d

img = zeros([10 10 10], 'uint8');
img(:) = 100;

function img = createColorImage3d

img = zeros([10 10 3 10], 'uint8');
img(:,:,1,:) = 80;
img(:,:,2,:) = 120;
img(:,:,3,:) = 160;

function mask = createMask3d

mask = false([10 10 10]);
mask(2:3, 4:6, 7:8) = true;

function ovr = createGrayOverlay3d

ovr = zeros([10 10 10], 'uint8');
ovr(:) = 200;

function ovr = createColorOverlay3d

ovr = zeros([10 10 3 10], 'uint8');
ovr(:, :, 1, :) = 50;
ovr(:, :, 2, :) = 150;
ovr(:, :, 3, :) = 250;


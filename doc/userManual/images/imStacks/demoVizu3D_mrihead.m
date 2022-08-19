%DEMOVIZU3D_MRIHEAD  One-line description here, please.
%
%   output = demoVizu3D_mrihead(input)
%
%   Example
%   demoVizu3D_mrihead
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-08-09,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.

% read data
img = analyze75read('brainMRI.hdr');

% adjust histogram
img = imAdjustDynamic(img);

figure(1); clf; hold on;
orthoSlices(img, [60 80 13], 'Spacing', [1 1 2.5]);
axis equal;                      % to have equal sizes
print(gcf, 'brainMRI_orthoSlices.png', '-dpng');

figure(2); clf; hold on;
orthoSlices3d(img, [60 80 13], [1 1 2.5]);
axis(imPhysicalExtent(img, [1 1 2.5]));   % setup axis limits
axis equal;                      % to have equal sizes
view(3);
print(gcf, 'brainMRI_orthoSlices3d.png', '-dpng');


% figure(3); clf; hold on;
% isosurface(gaussianFilter(img, [5 5 5], 2), 50);
% axis(physicalExtent(img));       % setup axis limits
% axis equal;                      % to have equal sizes
% view([145 25]); light;
% print(gcf, 'brainMRI_isosurface3d.png', '-dpng');

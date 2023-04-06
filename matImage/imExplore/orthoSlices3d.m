function varargout = orthoSlices3d(img, varargin)
%ORTHOSLICES3D Show three orthogonal slices of a 3D image
%
%   orthoSlices3d(IMG)
%   Show three orthogonal slices of the 3D image IMG in the same axis.
%
%   orthoSlices3d(IMG, POS)
%   Specifies the position of the intersection point of the three slices.
%   POS is 1-by-3 row vector containing the position of slices intersection
%   point, in image index coordinate between 1 and image size, in order 
%   [XPOS YPOS ZPOS].
%
%   orthoSlices3d(IMG, POS, SPACING)
%   Also specify the spacing between voxels, as a 1-by-3 row vector with
%   values: [SP_X SP_Y SP_Z].
%
%   orthoSlices3d(..., 'displayRange', RANGE)
%   Specifies the grayscale range of the data. RANGE should be a 1-by-2 row
%   vector containing min and max values to display. Display will be
%   adjusted such that min value correspond to black (value 0), and max
%   value correspond to white (value 255).
%
%   orthoSlices3d(..., 'ColorMap', MAP)
%   Specifies the colormap to display the data with. MAP should be a
%   255-by-3 array.
%
%   Examples
%   % Display MRI head using three 3D orthogonal slices
%     img = analyze75read(analyze75info('brainMRI.hdr'));
%     figure(1); clf; hold on;
%     orthoSlices3d(img, [60 80 13], [1 1 2.5]);
%     axis equal;                          % to have equal sizes
%     view(3);
%
%   % Same image displayed with different grayscale calibration
%     img = analyze75read(analyze75info('brainMRI.hdr'));
%     figure; clf; hold on;
%     orthoSlices3d(img, [60 80 13], [1 1 2.5], 'displayRange', [0 90], 'lut', 'jet');
%     axis equal; view(3);
%
%
%   See also
%   stackSlice, orthoSlices, showXSlice, showYSlice, showZSlice, slice3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-30,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2010 INRA - Cepia Software Platform.


%% Parse input arguments

% get stack size (in x, y, z order)
siz = stackSize(img);

% extract position of middle point
if ~isempty(varargin) && ~ischar(varargin{1})
    pos = varargin{1};
    varargin(1) = [];
else
    % use center as default position
    pos = ceil(siz / 2);
end

% extract spacing
spacing = [1 1 1];
if ~isempty(varargin) && ~ischar(varargin{1})
    spacing = varargin{1};
    if numel(spacing) == 1
        % in case of scalar spacing, convert to row vector
        spacing = [1 1 1] * spacing;
    end
    varargin(1) = [];
end

% origin
origin = [0 0 0];

% extract options specified by strings
options = cell(1, 0);
while length(varargin) > 1
    param = varargin{1};
    switch lower(param)
        case 'origin'
            origin = varargin{2};
        case 'displayrange'
            options = [options {'DisplayRange', varargin{2}}]; %#ok<AGROW>
        case {'colormap', 'lut'}
            options = [options {'ColorMap', varargin{2}}]; %#ok<AGROW>
        otherwise
            error(['Unknown parameter: ' param]);
    end
    varargin(1:2) = [];
end


%% Display slices

% display three orthogonal slices
hold on;
hyz = slice3d(img, 1, pos(1), spacing, options{:});
hxz = slice3d(img, 2, pos(2), spacing, options{:});
hxy = slice3d(img, 3, pos(3), spacing, options{:});

% compute display extent (add a 0.5 limit around each voxel)
corner000 = (zeros(1, 3) + .5) .* spacing + origin;
corner111 = (siz + .5) .* spacing + origin;
extent = [corner000 ; corner111];
extent = extent(:)';

% setup display
axis equal;
axis(extent);

if nargout > 2
    varargout = {hxy, hyz, hxz};
end

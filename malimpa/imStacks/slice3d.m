function hs = slice3d(img, dim, index, varargin)
%SLICE3D Show a moving 3D slice of an image
%
%   slice3d(IMG, DIR)
%   slice3d(IMG, DIR, INDEX)
%   IMG is a 3D (grayscale) or 4D (color) image, with size Ny-by-Nx-by-Nz
%   or Ny-by-Nx-by-3-by-Nz. 
%   DIM is the direction of slicing, that can be:
%   1, corresponding to the 'x' direction (array direction n° 2)
%   2, corresponding to the 'y' direction (array direction n° 1)
%   3, corresponding to the 'z' direction (array direction n° 3)
%   INDEX is the index of the slice in the corresponding direction. Default
%   is the middle of the image in the given direction.
%
%   slice3d(IMG, DIR, INDEX, SCALE)
%   give the voxel resolution for each one of the x,y,z directions.
%
%   slice3d(..., 'DisplayRange', RANGE)
%   Specifies the grayscale range of the data. RANGE should be a 1-by-2 row
%   vector containing min and max values to display. Display will be
%   adjusted such that min value correspond to black (value 0), and max
%   value correspond to white (value 255).
%
%   slice3d(..., 'ColorMap', MAP)
%   Specifies the color map to display the data with. MAP should be a
%   255-by-3 array, see the colromap function for examples.
%
%   See also
%   orthoSlices, orthoSlices3d, colormap
%
%   References
%   Largely inspired by file 'slice3i' from Anders Brun, see FEx:
%   http://www.mathworks.fr/matlabcentral/fileexchange/25923
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Input arguments extraction

% get stack size (in x, y, z order)
siz = stackSize(img);

% use a default position if not specified
if nargin < 3
    index = ceil(siz/2);
end

% check axis direction
dim = parseAxisIndex(dim);

% extract spatial calibration
if ~isempty(varargin) && isnumeric(varargin{1})
    var = varargin{1};
    if numel(var) == 3
        % resolution is given for each x, y, and z directions
        dcm = diag([var 1]);
        
    elseif all(size(var) >= [3 3])
        % resolution is given as a transformation matrix
        dcm = var;
        dcm(4, 4) = 1;
        
    else
        error('Unable to parse spatial calibration');
    end
    varargin(1) = [];
    
else
    % no spatial calibration: use identity matrix
    dcm = eye(4);
end

% default display calibration
displayRange = [0 255];
lut = [];

% extract display calibration
while length(varargin) > 1
    param = varargin{1};
    switch lower(param)
        case 'displayrange'
            displayRange = varargin{2};
        case {'lut', 'colormap'}
            lut = varargin{2};
        otherwise
            error(['Unknown parameter: ' param]);
    end
    varargin(1:2) = [];
end


%% Extract and normalise slice

% extract the slice
slice = stackSlice(img, dim, index);

slice = computeSliceRGB(slice, displayRange, lut);


%% Extract slice coordinates

% 
switch dim
    case 1
        % X Slice
        
        % compute coords of u and v
        vy = ((0:siz(2)) + .5);
        vz = ((0:siz(3)) + .5);
        [ydata zdata] = meshgrid(vy, vz);
        
        % coord of slice supporting plane
        lx = 1:siz(1);
        xdata = ones(size(ydata)) * lx(index);
        
   case 2
        % Y Slice
       
        % compute coords of u and v
        vx = ((0:siz(1)) + .5);
        vz = ((0:siz(3)) + .5);
        [zdata xdata] = meshgrid(vz, vx);

        % coord of slice supporting plane
        ly = 1:siz(2);
        ydata = ones(size(xdata)) * ly(index);

    case 3
        % Z Slice

        % compute coords of u and v
        vx = ((0:siz(1)) + .5);
        vy = ((0:siz(2)) + .5);
        [xdata ydata] = meshgrid(vx, vy);
        
        % coord of slice supporting plane
        lz = 1:siz(3);
        zdata = ones(size(xdata)) * lz(index);
        
    otherwise
        error('Unknown stack direction');
end

% transform coordinates from image reference to spatial reference
hdata = ones(1, numel(xdata));
trans = dcm(1:3, :) * [xdata(:)'; ydata(:)'; zdata(:)'; hdata];
xdata(:) = trans(1,:); 
ydata(:) = trans(2,:); 
zdata(:) = trans(3,:); 


%% Display slice in 3D

% global parameters for surface display
params = [{'facecolor', 'texturemap', 'edgecolor', 'none'}, varargin];

% display voxel values in appropriate reference space
hs = surface(xdata, ydata, zdata, slice, params{:});


% set up slice data
data.handle = hs;
data.img    = img;
data.dim    = dim;
data.index  = index;
data.dcm    = dcm;
data.displayRange = displayRange;
data.lut    = lut;
set(hs, 'UserData', data);

% set up mouse listener
set(hs, 'ButtonDownFcn', @startDragging);



function startDragging(src, event) %#ok<INUSD>
%STARTDRAGGING  One-line description here, please.
%
%   output = startDragging(input)
%
%   Example
%   startDragging
%
%   See also
%

data = get(src, 'UserData');

% store data for creating ray
data.startRay   = get(gca, 'CurrentPoint');
data.startIndex = data.index;

% update data of slice object
set(src, 'UserData', data);

% store reference to slice object in figure object
hFig = gcbf();
set(hFig, 'UserData', src);

% set up listeners for figure object
set(hFig, 'WindowButtonMotionFcn', @dragSlice);
set(hFig, 'WindowButtonUpFcn', @stopDragging);


function stopDragging(src, event) %#ok<INUSD>
%STOPDRAGGING  One-line description here, please.
%
%   output = stopDragging(input)
%
%   Example
%   stopDragging
%
%   See also
%


% remove figure listeners
hFig = src;
set(hFig, 'WindowButtonUpFcn', '');
set(hFig, 'WindowButtonMotionFcn', '');

% get slice reference
hs   = get(src, 'UserData');
data = get(hs, 'UserData');

% reset slice data
data.startray = [];
set(hs, 'UserData', data);

% reset figure data
set(hFig, 'UserData', []);

% update display
drawnow;


function dragSlice(src, event) %#ok<INUSD>
%DRAGSLICE  One-line description here, please.
%
%   output = dragSlice(input)
%
%   Example
%   dragSlice
%
%   See also
%


%% Extract data

% Extract slice data
hs      = get(src, 'UserData');
data    = get(hs, 'UserData');

% basic checkup
if ~isfield(data, 'startRay')
    return;
end
if isempty(data.startRay)
    return;
end

if ~isfield(data, 'dcm')
    data.dcm = eye(4);
end


%% Compute new slice index

% dimension in xyz
dim = data.dim;

% get the ray used for computing slice position
sliceNormal = data.dcm(1:3, [4 dim])';

% position of initial ray
pos0 = posProjRayOnRay(data.startRay, sliceNormal);

% position of current ray
currentRay = get(gca, 'CurrentPoint');
pos = posProjRayOnRay(currentRay, sliceNormal);

% compute difference in positions
slicediff = pos - pos0;

index = data.startIndex + round(slicediff);
index = min(max(1, index), stackSize(data.img, data.dim));
data.index = index;

% Store gui object
set(hs, 'UserData', data);


%% Update content of the surface object with current slice

% extract slice corresponding to current index
slice = stackSlice(data.img, data.dim, data.index);

% convert to renderable RGB
slice = computeSliceRGB(slice, data.displayRange, data.lut);

% setup display data
set(hs, 'CData', slice);


%% Update position of the slice along its direction

imgSize = size(data.img);

% the mesh used to render image has one element more, to enclose all pixels
meshSize = [size(slice, 1) size(slice, 2)] + 1;

isOrtho = sum(abs(data.dcm([2 3 5 7 9 10]))) < 1e-12;

if isOrtho
    % in the case of scaling + translation, use simple processing (faster)
    switch data.dim
        case 1
            xpos = data.index * data.dcm(1,1) + data.dcm(1,4);
            xdata = ones(meshSize) * xpos;
            set(hs, 'xdata', xdata);
            
        case 2
            ypos = data.index * data.dcm(2,2) + data.dcm(2,4);
            ydata = ones(meshSize) * ypos;
            set(hs, 'ydata', ydata);
            
        case 3
            zpos = data.index * data.dcm(3,3) + data.dcm(3,4);
            zdata = ones(meshSize) * zpos;
            set(hs, 'zdata', zdata);
            
        otherwise
            error('Unknown stack direction');
    end
    
else
    % for general matrices, computes transformed coordinates (seems to be
    % slower)
    switch data.dim
        case 1
            % compute coords of u and v
            vy = ((0:imgSize(1)) + .5);
            vz = ((0:imgSize(3)) + .5);
            [ydata zdata] = meshgrid(vy, vz);

            lx = 1:imgSize(2);
            xdata = ones(meshSize) * lx(index);

        case 2
            % compute coords of u and v
            vx = ((0:imgSize(2)) + .5);
            vz = ((0:imgSize(3)) + .5);
            [zdata xdata] = meshgrid(vz, vx);

            ly = 1:imgSize(1);
            ydata = ones(meshSize) * ly(index);

        case 3
            % compute coords of u and v
            vx = ((0:imgSize(2)) + .5);
            vy = ((0:imgSize(1)) + .5);
            [xdata ydata] = meshgrid(vx, vy);

            lz = 1:imgSize(3);
            zdata = ones(meshSize) * lz(index);

        otherwise
            error('Unknown stack direction');
    end

    % transform coordinates from image reference to spatial reference
    hdata = ones(1, numel(xdata));
    trans = data.dcm(1:3,:) * [xdata(:)'; ydata(:)'; zdata(:)'; hdata];
    xdata(:) = trans(1,:); 
    ydata(:) = trans(2,:); 
    zdata(:) = trans(3,:); 
    set(hs, 'xdata', xdata, 'ydata', ydata, 'zdata', zdata);
end

% update display
drawnow;


function pos = posProjRayOnRay(ray1, ray2)
% ray1 and ray2 given as 2-by-3 arrays

u = ray1(2,:) - ray1(1,:);
v = ray2(2,:) - ray2(1,:);
w = ray1(1,:) - ray2(1,:);

a = dot(u, u, 2);
b = dot(u, v, 2);
c = dot(v, v, 2);
d = dot(u, w, 2);
e = dot(v, w, 2);

pos = (a*e - b*d) / (a*c - b^2);

function varargout = slicer(varargin)
%SLICER Interactive visualization of 3D images
%
%   SLICER is an graphical interface to explore slices of a 3D image.
%   Index of the current slice is given under the slider, mouse position as
%   well as cursor value are indicated when mouse is moved over image, and
%   scrollbars allow to navigate within image.
%   
%   SLICER should work with any kind of 3D images: binary, gray scale
%   (integer or floating-point) or color RGB.
%
%   slicer(IMG)
%   where IMG is a preloaded M*N*P matrix, opens the slicer GUI,
%   initialized with image IMG.
%   User can change current slice with the slider to the left, X and Y
%   position with the two corresponding sliders, and change the zoom in the
%   View menu.
%
%   slicer(IMGNAME, ...)
%   Load the stack specified by IMGNAME. It can be either a tif bundle, the
%   first file of a series, or a 3D image stored in one of the medical
%   image format:
%   * DICOM (*.dcm) 
%   * Analyze (*.hdr) 
%   * MetaImage (*.mhd, *.mha) 
%   It is also possible to import a raw data file, from the File->Import
%   menu.
%
%   slicer
%   without argument opens a dialog to read a file (either a set of slices
%   or a bundle-stack).
%
%   slicer(..., PARAM, VALUE)
%   Specifies one or more display options as name-value parameter pairs.
%   Available parameter names are:
%   * 'slice'       the display uses slice given by VALUE as current slice
%   * 'position'    VALUE contains a 1-by-2 vector corresponding to the 
%         (x,y) indices of the upper-left displayed pixel, starting from 1,
%         and up to the number of voxels in that dimension
%   * 'zoom'        set up the initial zoom (the ratio between the number
%         of voxels, or user units for calibrated images, and the number of
%         points on the screen). 
%   * 'name'        gives a name to the image (for display in title bar)
%   * 'spacing'     specifies the size of voxel elements. VALUE is a 1-by-3
%         row vector containing spacing in x, y and z direction.
%   * 'origin'      specifies coordinate of first voxel in user space
%   * 'displayRange' the values of min and max gray values to display. The
%         default behaviour is to use [0 255] for uint8 images, or to
%         compute bounds such as 95% of the voxels are converted to visible
%         gray levels for other image types.
%
%   Requires:
%   * readstack for importing stacks
%   * Image Processing Toolbox for reading 2D and 3D images
%
%   Examples:
%       % Explore 3D image stored in 3D Analyze format
%   	metadata = analyze75info('brainMRI.hdr');
%   	IMG = analyze75read(metadata);
%       slicer(IMG);
%
%       % show the 10-th slice, with initial magnification equal to 8
%       slicer(IMG, 'slice', 10, 'zoom', 8, 'name', 'Brain');
%       
%   ---------
%   author: David Legland, david.legland(at)grignon.inra.fr
%   INRA - Cepia Software Platform
%   created the 21/11/2003 
%   http://www.pfl-cepia.inra.fr/index.php?page=slicer

%   HISTORY
%   28/06/2004 allows small images
%   15/10/2004 add slider for positioning, zoom, and possibility to load
%       images
%   18/10/2004 correct bug for input image type (was set to uint8), and
%       in positioning. Also add remembering of last opened path.
%   19/10/2004 correct bugs in display (view window too large)
%   26/10/2004 correct bug for color images (were seen as gray-scale)
%   25/03/2005 add size of image in title, and starting options
%   29/03/2005 automatically find best zoom when starting, if no zoom is
%       specified. Add doc.
%   21/02/2006 adapt to windows file format
%   11/08/2006 display value of clicked points
%   14/11/2006 add possibility to use slicer('imageName.tif');
%   30/11/2006 correct bug for binary images introduced with last modif.
%   06/12/2006 another bug correction for control on images
%   08/08/2007 improve control on coordinate of clicked pixel 
%   05/01/2010 remove buttons, and put zooms in menu
%   06/01/2010 change license, update help, add histogram
%   09/03/2010 use dim(1)=x, dim(2)=y
%   09/03/2010 add support for voxel spacing, change input options syntax
%   10/03/2010 update help, add more input options, update pixel display
%   20/06/2010 add a dialog to change image resolution
%   22/06/2010 keep grayscale range when transforming image, add about dlg
%   12/10/2010 add support to vector images (display the vector norm)
%   19/10/2010 add shortcuts and menu shortcuts
%   22/10/2010 add support for import of raw stacks
%   25/10/2010 change management of 3D rotations
%   05/11/2010 display RGB histogram as 3 separate bands
%   10/11/2010 add support for Look-Up Tables, clean up menus
%   11/01/2011 fix calibration bugs, update display
%   02/03/2011 add support for single color LUTs
%   27/04/2011 read indexed dicom images, rewrite image import
%   27/04/2011 enhance histogram and display of float RGB
%   12/08/2011 fix bug when running without input
%   29/08/2011 add support for continuous z-sliding

% Last Modified by GUIDE v2.5 26-Apr-2011 10:57:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @slicer_OpeningFcn, ...
                   'gui_OutputFcn',  @slicer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargin && isnumeric(varargin{1})
    varargin = [varargin(1) {'name', inputname(1)} varargin(2:end)];
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%  ===========================================================
%% Initialization functions

% --- Executes just before slicer is made visible.
function slicer_OpeningFcn(hObject, eventdata, handles, varargin)  %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to slicer (see VARARGIN)


% Choose default command line output for slicer
handles.output = hObject;

% set up global options
handles.view = [512 512]; % in pixels
handles.lastPath = pwd;
handles.titlePattern = 'Slicer - %s [%dx%dx%d] - %g:%g';
handles.pixelCoordRounded = true;

% reset image information
handles = resetImageData(handles);

% attach a listener for mouse wheel scrolling
set(handles.mainFrame, 'WindowScrollWheelFcn', @mouseWheelScrolled);

% setup listeners for slider continuous changes
hListener = handle.listener(handles.moveZSlider, 'ActionEvent', ...
    @moveZSlider_Callback2);
setappdata(handles.moveZSlider, 'sliderListeners', hListener);

% Update handles structure
guidata(hObject, handles);


% if no image specified, open a dialog to choose the file to load
if isempty(varargin)
    showLoadImageDialog(handles);
    handles = guidata(hObject);
    
    % in case the user cancels, display an empty image
    if isempty(get(handles.imageDisplay, 'UserData'))
        % initialize with a default image
        img = zeros([256, 256, 10], 'uint8');
        img(:) = 255;
        set(handles.imageDisplay, 'UserData', img);
        handles = setupImage(handles);
    end

else

    var = varargin{1};
    if isnumeric(var) || islogical(var)
        % when input is a 3D or 4D numeric array, use it as image data
        if length(size(var)) < 3
            error('Input should be a 3 or 4 dimensions matrix');
        end
        set(handles.imageDisplay, 'UserData', var);
        handles = setupImage(handles);

    elseif ischar(var)
        % if a character string is given, try to load from an image file
        importImageDataFile(handles, var);
        handles = guidata(handles.mainFrame);
        
    elseif isa(var, 'Image')
        % Try to interpret as Image object (not included in default slicer)
        if ndims(var) ~= 3
            error('Need an <Image> object with dimension 3');
        end

        set(handles.imageDisplay, 'UserData', getBuffer(var));
        handles = setupImage(handles);

        % extract image name
        name = var.name;
        if ~isempty(name)
            handles.imgName = name;
        end

        % extract spatial calibration
        handles.voxelOrigin     = var.origin;
        handles.voxelSize       = var.spacing;
        handles.voxelSizeUnit   = var.unitName;

    else
        error('First argument of "slicer" should be either an image or a string');
    end
    varargin(1) = [];
end

% Set current slice in the middle of the stack by default
handles.slice = ceil(handles.dim(3) / 2);
setSlice(handles);

% Parses other input arguments
handles = parseInputOptions(handles, varargin{:});

updateTitle(handles);

% Update handles structure
guidata(hObject, handles);


function handles = parseInputOptions(handles, varargin)
% Parse optional input arguments

% iterate over couples of input arguments
while length(varargin) > 1
    param = varargin{1};
    switch lower(param)
        case 'slice'
            % setup initial slice
            pos = varargin{2};
            handles.slice = pos(1);
            
        case 'position'
            % setup position of upper-left visible pixel (1-indexed)
            pos = varargin{2};
            handles.cornerPixel = pos(1:2);
            
        case 'zoom'
            % setup initial zoom
            zoom = varargin{2};
            if zoom > handles.zoomMin && zoom < handles.zoomMax
                handles.zoom = zoom;
            else
                disp('slicer: zoom value outside allowed limits');
            end
            
        case 'spacing'
            handles.voxelSize = varargin{2};
        case 'origin'
            handles.voxelOrigin = varargin{2};
        case 'name'
            handles.imgName = varargin{2};
        case 'displayrange'
            handles.grayscaleExtent = varargin{2};
        otherwise
            error(['Unknown parameter name: ' param]);
    end
    varargin(1:2) = [];
end

function handles = resetImageData(handles)
% Reset handles fields corresponding to image info to default values

% display info

% size of the view box, in pixels
handles.view            = [512 512];

handles.dim             = [10 10 10];

% index of current slice
handles.slice           = 1;

% index of first visible pixel (x, y indices)
handles.cornerPixel     = [1 1];

% position, in user unit, of first visible point in viewbox
handles.cornerPosition  = [0 0];

% current zoom: mutliplier applied to user units when converted to pixel
handles.zoom            = 1;

% TODO: zoomMin and zoomMax should depend on image
handles.zoomMin         = 1 / 256;
handles.zoomMax         = 256;  

% Calibration info, in user unit, in xyz order
handles.voxelOrigin     = [0 0 0];
handles.voxelSize       = [1 1 1];
handles.voxelSizeUnit   = '';

% grayscale calibration, will be initialized automatically
handles.grayscaleExtent = [];

% initialize image info flags
handles.color   = false;
handles.vector  = false;

% empty lut (corresponds to usual gray-scale)
handles.lut     = [];

% meta info

% name of image
handles.imgName = '';

% meta-information obtained with rich formats (analyze, metaImage...)
% given as a structure, and dependent on fileformat used
handles.imgInfo = [];


function h_img = displayNewImage(handles)

% extract data
dim     = handles.dim;
zoom    = handles.zoom;
view    = handles.view;

cdata = computeDisplayData(handles);

% reset current axis
cla(handles.imageDisplay);
hold on;

% create an empty image with the appropriate size and data,
% and init to the specified slice
if handles.color
    % display as color image
    h_img = imshow(cdata, 'parent', handles.imageDisplay);
else
    % Display as gray-scale
    % compute grayscale extent
    extent = handles.grayscaleExtent;
    
    % show grayscale image with appropriate display range
    h_img = imshow(cdata, ...
        'parent', handles.imageDisplay, ...
        'DisplayRange', extent);
    
    % apply image LUT
    if isempty(handles.lut)
        colormap(gray);
    else
        colormap(handles.lut);
    end
end

% extract calibration data
spacing = handles.voxelSize(1:2);
origin  = handles.voxelOrigin(1:2);

% set up appropriate axes
xdata   = ([0 dim(1)-1] * spacing(1) + origin(1));
ydata   = ([0 dim(2)-1] * spacing(2) + origin(2));
set(h_img, 'XData', xdata);
set(h_img, 'YData', ydata);

% user-coordinates of corner point
cornerPoint = (handles.cornerPixel - 1) .* spacing + origin;

% setup bounds of viewport: one half-pixel around each bound
viewMin = cornerPoint - spacing / 2;
viewMax = cornerPoint + view ./ zoom + spacing / 2;
set(handles.imageDisplay, 'XLim', [viewMin(1) viewMax(1)]);
set(handles.imageDisplay, 'YLim', [viewMin(2) viewMax(2)]);

% set up the gui options of image
hold on;
set(h_img, 'ButtonDownFcn', ...
    'slicer(''imageDisplay_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
set(gcf, 'WindowButtonMotionFcn', ...
    'slicer(''imageDisplay_ButtonMotionFcn'',gcbo,[],guidata(gcbo))');

% update X and Y sliders
updateXYSliders(handles);

% update control for changing slice
zmax    = dim(3);
zslice  = handles.slice;
zslice  = min(max(zslice, 1), zmax);
handles.slice = zslice;

updateZControls(handles);

updateTitle(handles);


function data = computeDisplayData(handles)
% Extract data to display as color or grayscale planar image

img = get(handles.imageDisplay, 'UserData');
zslice = handles.slice;

if handles.color
    % display as color image
    data = img(:, :, :, zslice);
    
elseif handles.vector
    % in case of a vector image, display the norm of the vector
    dim = size(img);
    data = zeros(dim(1), dim(2));
    for i = 1:size(img, 3)
        data = data + double(img(:, :, i, zslice)) .^ 2;
    end
    data = sqrt(data);
    
else
    % for grayscale images, simply extract the appropriate slice
    data = img(:, :, zslice);
end


function setImageLUT(hObject, eventdata, handles, lutName) %#ok<INUSL,DEFNU>
% Change the LUT of the grayscale image, and refresh the display
% lut is specified by its name.

nGrays = 256;
if strmatch(lutName, 'inverted')
    lut = repmat((255:-1:0)', 1, 3) / 255;
    
elseif strmatch(lutName, 'blue-gray-red')
    lut = gray(nGrays);
    lut(1,:) = [0 0 1];
    lut(end,:) = [1 0 0];
    
elseif strmatch(lutName, 'colorcube')
    img = get(handles.imageDisplay, 'userdata');
    nLabels = round(max(img(:)));
    map = colorcube(double(nLabels) + 2);
    lut = [0 0 0; map(sum(map==0, 2)~=3 & sum(map==1, 2)~=3, :)];
    
elseif strmatch(lutName, 'redLUT')
    lut = gray(nGrays);
    lut(:, 2:3) = 0;

elseif strmatch(lutName, 'greenLUT')
    lut = gray(nGrays);
    lut(:, [1 3]) = 0;

elseif strmatch(lutName, 'blueLUT')
    lut = gray(nGrays);
    lut(:, 1:2) = 0;

elseif strmatch(lutName, 'yellowLUT')
    lut = gray(nGrays);
    lut(:, 3) = 0;

elseif strmatch(lutName, 'cyanLUT')
    lut = gray(nGrays);
    lut(:, 1) = 0;

elseif strmatch(lutName, 'magentaLUT')
    lut = gray(nGrays);
    lut(:, 2) = 0;

else
    lut = feval(lutName, nGrays);
end

handles.lut = lut;
colormap(handles.imageDisplay, lut);

% update gui data
guidata(handles.mainFrame, handles);


function updateTitle(handles)
% set up title of the figure, containing name of figure and current zoom

% setup name
if isempty(handles.imgName)
    imgName = 'Unknown Image';
else
    imgName = handles.imgName;
end

% display new title
zoom = handles.zoom;
title = sprintf(handles.titlePattern, imgName, ...
    handles.dim, max(1, zoom), max(1, 1/zoom));
set(handles.mainFrame, 'Name', title);


function setupSliderHandle(hd, mini, maxi, value, step)
% setup min, max, 
set(hd, 'Min', mini);
set(hd, 'Max', maxi);

% compute step if not specified
if ~exist('step', 'var')
    step = .05;
end
step2 = min(step*10, (maxi-mini)/2);

% setup step, or make slider invisible
eps = 1e-10;
if value-mini >= -eps && value-maxi <= eps && (maxi-mini) > eps
    value = min(max(value, mini), maxi);
    set(hd, 'value', value);
    set(hd, 'sliderstep', [step step2]);
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end


function [mini maxi] = computeGrayScaleExtent(img)
% compute grayscale extent of a grayscale image

% check image data type
if isa(img, 'uint8')
    % use min-max values depending on image type
    [mini maxi] = computeTypeExtent(img);
    
elseif islogical(img)
    % for binary images, the grayscale extent is defined by the type
    mini = 0;
    maxi = 1;
    
elseif ndims(img) > 3
    % case of vector image: compute max of norm
    dim = size(img);
    norm = zeros(dim([1 2 4]));
    for i = 1:dim(3)
        norm = norm + squeeze(img(:,:,i,:)) .^ 2;
    end
    
    mini = 0;
    maxi = sqrt(max(norm(:)));
    
else
    % for float images, display 99 percents of dynamic
    [mini maxi] = computeGrayscaleAdjustement(img, .01);
    
end

function [mini maxi] = computeTypeExtent(img)
% use min-max values depending on image type
type = class(img);
mini = intmin(type);
maxi = intmax(type);

% if image has only positive values, use 0 as min
if min(img(:)) >= 0
    mini = 0;
end

    
function [mini maxi] = computeExtremeValues(img) %#ok<DEFNU>
% compute min and max (finite) values in image

mini = min(img(isfinite(img)));
maxi = max(img(isfinite(img)));

% If the difference is too small, use default range check
if abs(maxi-mini) < 1e-12
    warning('Slicer:Grayscale', ...
        'could not determine grayscale extent from data');
    mini = 0;
    maxi = 1;
end

function [mini maxi] = computeGrayscaleAdjustement(img, alpha)
% compute grayscale range that maximize vizualisation

% use default value for alpha if not specified
if nargin == 1
    alpha = .01;
end

% extreme values in image
minValue = min(img(isfinite(img)));
maxValue = max(img(isfinite(img)));

% compute histogram
x = linspace(double(minValue), double(maxValue), 10000);
h = hist(double(img(:)), x);

% special case of images with black background
if h(1) > sum(h) * .2
    x = x(2:end);
    h = h(2:end);
end

cumh = cumsum(h);
cdf  = cumh / cumh(end);

% find indices of extreme values
ind1 = find(cdf >= alpha/2,   1, 'first');
ind2 = find(cdf <= 1-alpha/2, 1, 'last');

% compute grascale extent
mini = floor(x(ind1));
maxi = ceil(x(ind2));

% small control to avoid mini==maxi
if abs(maxi - mini) < 1e-12
    mini = minValue;
    maxi = maxValue;
    
    if abs(maxi - mini) < 1e-12
        mini = 0;
        maxi = 1;
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = slicer_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function moveZSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to moveZSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject, 'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor')); %#ok<UNRCH>
end


%  ===========================================================
%% General purpose functions


% ------------------------------------------------
function setSlice(handles)
% change the current slice.
% slice number is the third value of field POS in handles.

% get slice
slice = handles.slice;

% change inner data of image
cdata = computeDisplayData(handles);
set(handles.h_img, 'CData', cdata);

% update gui information for slider and textbox
set(handles.moveZSlider, 'Value', slice);
set(handles.sliceNumberText, 'String', num2str(slice));

% update gui data
guidata(handles.mainFrame, handles);


% ------------------------------------------------
function setZoom(handles)
% Update zoom of current display
% handles    structure with handles and user data (see GUIDATA)


zoom = handles.zoom;

% check zoom has valid values
if zoom > handles.zoomMax || zoom < handles.zoomMin
    disp('zoom value out of bounds');
    return;
end

% compute display extent, in physical coordinates
xlim = get(handles.imageDisplay, 'XLim');
ylim = get(handles.imageDisplay, 'YLim');

viewSize = handles.view/zoom;
viewCorner1 = [xlim(1) ylim(1)];
viewCorner2 = viewCorner1 + viewSize;

% 
imageExtent = computeImagePhysicalExtent(handles);
if viewCorner2(1) > imageExtent(2)
    viewCorner1(1) = imageExtent(1);
end
if viewCorner2(2) > imageExtent(4)
    viewCorner1(2) = imageExtent(3);
end
viewCorner2 = viewCorner1 + viewSize;

set(handles.imageDisplay, 'XLim', [viewCorner1(1) viewCorner2(1)]);
set(handles.imageDisplay, 'YLim', [viewCorner1(2) viewCorner2(2)]);

handles.cornerPosition = viewCorner1;

% update title of the frame
updateTitle(handles);

updateXYSliders(handles);

% gui data already updated in updateXYSLiders
%guidata(handles.mainFrame, handles);

function updateXYSliders(handles)
% update sliders for x and y positions

% current zoom
zoom = handles.zoom;

% set up appropriate axes
xlim = get(handles.imageDisplay, 'XLim');
ylim = get(handles.imageDisplay, 'YLim');

% image extent in physical coordinates
imageExtent = computeImagePhysicalExtent(handles);

% size of viewbox in user units
viewSize = handles.view / zoom;

% compute limit for x slider bar
xmin = imageExtent(1);
xmax = imageExtent(2) - viewSize(1);
hd = handles.moveXSlider;
setupSliderHandle(hd, xmin, xmax, xlim(1), .01);

% compute limit for y slider bar
ymin = imageExtent(3);
ymax = imageExtent(4) - viewSize(2);
hd = handles.moveYSlider;
setupSliderHandle(hd, ymin, ymax, ymax-ylim(1)+ymin, .01);

guidata(handles.mainFrame, handles);


function chooseCenterSlice(handles)

% max possible slice
zmax = handles.dim(3);

% setup current slice
handles.slice = ceil(zmax / 2);

% update controls
updateZControls(handles);

setSlice(handles);


function updateZControls(handles)
% update controls for changing slice

% max possible slice
zmax = handles.dim(3);

% check current slice is valid
zslice = handles.slice;
zslice = min(max(zslice, 1), zmax);
handles.slice = zslice;

% update slice slider
hd = handles.moveZSlider;
setupSliderHandle(hd, 1, zmax, zslice, 1/zmax);

% update text area
set(handles.sliceNumberText, 'String', num2str(zslice));


function extent = computeImagePhysicalExtent(handles)

dim = handles.dim;
spacing = handles.voxelSize;
origin = handles.voxelOrigin;

p0 = ([0 0 0] - .5) .* spacing + origin;
p1 = (    dim - .5) .* spacing + origin;
extent = [p0 ; p1];
extent = extent(:)';


% ------------------------------------------------
function setPosition(handles)
% change the position of top-left corner of view.
%   - update axis limits
%   - update X- and Y-sliders

pos     = handles.cornerPosition;

% compute center of display, in physical coordinates
xlim = get(handles.imageDisplay, 'XLim');
ylim = get(handles.imageDisplay, 'YLim');

% extent of the view, in physical coord
viewSize = [xlim(2)-xlim(1) ylim(2)-ylim(1)];

% new position of upper-left corner of view port
pos2 = pos + viewSize;
set(handles.imageDisplay, 'xlim', [pos(1) pos2(1)]);
set(handles.imageDisplay, 'ylim', [pos(2) pos2(2)]);

set(handles.moveXSlider, 'Value', pos(1));
ymin = get(handles.moveYSlider, 'Min');
ymax = get(handles.moveYSlider, 'Max');
set(handles.moveYSlider, 'Value', ymax-pos(2)+ymin);

guidata(handles.mainFrame, handles);


% ===========================================================
% callback function for GUI components


% ----------------------------------------------------
%% callback functions for sliders



% --- Executes on slider movement.
function moveZSlider_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to moveZSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute new value from slicer position, and update textString
zslice = round(get(hObject, 'Value'));
zslice = max(get(hObject, 'Min'), min(get(hObject, 'Max'), zslice));

handles.slice = zslice;
setSlice(handles);

function moveZSlider_Callback2(hObject, eventdata, handles) %#ok<INUSD>

% compute new value from slicer position, and update textString
zslice = round(get(hObject, 'Value'));
zslice = max(get(hObject, 'Min'), min(get(hObject, 'Max'), zslice));

handles = guidata(gcbf);

handles.slice = zslice;
setSlice(handles);


% --- Executes on slider movement.
function moveXSlider_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to moveXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute value inside of bounds
value = get(hObject, 'Value');
value = min(max(get(hObject, 'Min'), value), get(hObject, 'Max'));

% update GUI
handles.cornerPosition(1) = value;
setPosition(handles);


% --- Executes during object creation, after setting all properties.
function moveXSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to moveXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor')); %#ok<UNRCH>
end


% --- Executes on slider movement.
function moveYSlider_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to moveYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute value inside of bounds
value = get(hObject, 'Value');
value = min(max(get(hObject, 'Min'), value), get(hObject, 'Max'));
value = get(hObject, 'Max')-value+get(hObject, 'Min');

% update GUI
handles.cornerPosition(2) = value;
setPosition(handles);


% --- Executes during object creation, after setting all properties.
function moveYSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to moveYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor')); %#ok<UNRCH>
end


% ----------------------------------------------------
%% callback functions for text areas


% --- Executes during object creation, after setting all properties.
function sliceNumberText_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to sliceNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes when a new text is typed in sliceNumberText
function sliceNumberText_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to sliceNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceNumberText as text
%        str2double(get(hObject,'String')) returns contents of sliceNumberText as a double

% get entered value for z-slice
zslice = str2double(get(hObject, 'String'));

% in case of wrong edit, set the string to current value of zslice
if isnan(zslice)
    zslice = handles.slice;
end

% compute slice number, inside of image bounds
zslice = min(max(1, round(zslice)), handles.dim(3));

% update text and slider info
handles.slice = zslice;
setSlice(handles);


% ===========================================================
%% callback function for Menu components


% --------------------------------------------------------------------
function menuFiles_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nothing to do ....

% --------------------------------------------------------------------
function itemOpen_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to itemOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

showLoadImageDialog(handles);


function showLoadImageDialog(handles)
% Display the dialog, determines imaeg type, and setup image accordingly

[filename, pathname] = uigetfile( ...
    {'*.gif;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.hdr;*.dcm;*.mhd', ...
    'All Image Files (*.tif, *.hdr, *.dcm, *.mhd, *.bmp, *.jpg)'; ...
    '*.tif;*.tiff',             'TIF Files (*.tif, *.tiff)'; ...
    '*.bmp',                    'BMP Files (*.bmp)'; ...
    '*.hdr',                    'Mayo Analyze Files (*.hdr)'; ...
    '*.dcm',                    'DICOM Files (*.dcm)'; ...
    '*.mhd;*.mha',              'MetaImage data files (*.mha, *.mhd)'; ...
    '*.*',                      'All Files (*.*)'}, ...
    'Choose a stack or the first slice of a series:', ...
    handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importImageDataFile(handles, fullfile(pathname, filename))


function importImageDataFile(handles, filename)
% Generic function to import data file
% dispatch to more specialized functions depending on file extension

[filepath basename ext] = fileparts(filename); %#ok<ASGLU>

switch lower(ext)
    case {'.mhd', '.mha'}
        importMetaImage(handles, filename);
    case '.hdr'
        importAnalyzeImage(handles, filename);
    case '.dcm'
        importDicomImage(handles, filename);
    otherwise
        readImageStack(handles, filename);
end
    

function readImageStack(handles, filename)

handles = resetImageData(handles);
img = readstack(filename);
set(handles.imageDisplay, 'userdata', img);

[pathname filename ext] = fileparts(filename);
handles.imgName     = [filename ext];
handles.lastPath    = pathname;

handles = setupImage(handles);
chooseCenterSlice(handles);



% --------------------------------------------------------------------
function menuImport_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to menuImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function itemImportDicom_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to itemImportDicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename, pathname] = uigetfile( ...
    {'*.dcm', 'DICOM Files (*.dcm)'; ...
    '*.*',                      'All Files (*.*)'}, ...
    'Choose the DICOM File:', ...
    handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importDicomImage(handles, fullfile(pathname, filename));


function importDicomImage(handles, filename)

% read image data
info        = dicominfo(filename);
[img map]   = dicomread(info);
img = squeeze(img);

% convert indexed image to true RGB image
if ~isempty(map)
    dim = size(img);
    inds = img;
    img = zeros([dim(1) dim(2) 3 dim(3)]);
    for i = 1:3
        img(:,:,i,:) = reshape(map(inds(:), i), dim);
    end
end

% update display
handles = resetImageData(handles);
set(handles.imageDisplay, 'userdata', img);

[pathname filename ext] = fileparts(filename);
handles.imgName     = [filename ext];
handles.lastPath    = pathname;
handles.imgInfo     = info;

handles = setupImage(handles);
chooseCenterSlice(handles);



% --------------------------------------------------------------------
function itemImportAnalyze_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to itemImportAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile( ...
    {'*.hdr', 'Mayo Analyze Files (*.hdr)'; ...
    '*.*',                      'All Files (*.*)'}, ...
    'Choose the Mayo Analyze header:', ...
    handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importAnalyzeImage(handles, fullfile(pathname, filename));


function importAnalyzeImage(handles, filename)

info = analyze75info(filename);

handles = resetImageData(handles);
set(handles.imageDisplay, 'userdata', analyze75read(info));

% setup calibration
if isfield(info, 'PixelDimensions')
    handles.voxelSize = info.('PixelDimensions');
end
if isfield(info, 'VoxelUnits')
    handles.voxelSizeUnit = info.('VoxelUnits');
end


[pathname filename ext] = fileparts(filename);
handles.imgName = [filename ext];
handles.lastPath = pathname;
handles.imgInfo = info;

handles = setupImage(handles);
chooseCenterSlice(handles);



% --------------------------------------------------------------------
function itemImportInterfile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to itemImportInterfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile( ...
    {'*.hdr', 'Interfile header Files (*.hdr)'; ...
    '*.*',   'All Files (*.*)'}, ...
    'Choose the Interfile header:', ...
    handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importInterfileImage(handles, fullfile(pathname, filename));


function importInterfileImage(handles, filename)

info = interfileinfo(filename);
handles = resetImageData(handles);
set(handles.imageDisplay, 'userdata', interfileread(info));

[pathname filename ext] = fileparts(filename);
handles.imgName     = [filename ext];
handles.lastPath    = pathname;
handles.imgInfo     = info;

handles = setupImage(handles);
chooseCenterSlice(handles);



% --------------------------------------------------------------------
function itemImportMetaImage_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to itemImportMetaImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile( ...
       {'*.mhd;*.mha', 'MetaImage data file(*.mha, *.mhd)'; ...
        '*.*',   'All Files (*.*)'}, ...
        'Choose the MetaImage header:', ...
        handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importMetaImage(handles, fullfile(pathname, filename));


function importMetaImage(handles, filename)

info = metaImageInfo(filename);

handles = resetImageData(handles);
set(handles.imageDisplay, 'userdata', metaImageRead(info));

% setup calibration
if isfield(info, 'ElementSize')
    handles.voxelSize = info.('ElementSize');
else
    isfield(info, 'ElementSpacing')
    handles.voxelSize = info.('ElementSpacing');
end
if isfield(info, 'ElementOrigin')
    handles.voxelOrigin = info.('ElementOrigin');
end

% setup file infos
[pathname filename ext] = fileparts(filename);
handles.imgName     = [filename ext];
handles.lastPath    = pathname;
handles.imgInfo     = info;


handles = setupImage(handles);
chooseCenterSlice(handles);


% --------------------------------------------------------------------
function itemImportRawData_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemImportRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename, pathname] = uigetfile( ...
       {'*.raw', 'Raw data file(*.raw)'; ...
        '*.*',   'All Files (*.*)'}, ...
        'Import Raw Data', ...
        handles.lastPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

importRawDataImage(handles, fullfile(pathname, filename));


function importRawDataImage(handles, filename)

% dialog to choose image dimensions
answers = inputdlg(...
    {'X Size (columns):', 'Y Size (rows):', 'Z Size (slices):'}, ...
    'Input Image Dimensions',...
    1, {'10', '10', '10'});
if isempty(answers)
    return;
end

% parse dimensions
dims = [0 0 0];
for i = 1:3
    num = str2num(answers{i}); %#ok<ST2NM>
    if isempty(num)
        errordlg(sprintf('Could not parse input number %d', i), ...
            'Parsing error');
        return;
    end
    dims(i) = num;
end

% dialog to choose data type
types = {'uint8', 'int8', 'uint16', 'int16', 'single', 'double'};
[selection, ok] = listdlg(...
    'ListString', types, ...
    'PromptString', 'Choose Data Type:', ...
    'SelectionMode', 'single', ...
    'Name', 'Data Type');
if ~ok
    return;
end

% read raw stack (use correction of some bugs in 'readstack' function)
dataType = types{selection};
img = readstack(fullfile(pathname, filename), dataType, dims([2 1 3]));
img = permute(img, [2 1 3]);

handles = resetImageData(handles);

set(handles.imageDisplay, 'userdata', img);

% setup file infos
handles.imgName  = filename;
handles.lastPath = pathname;


handles = setupImage(handles);
chooseCenterSlice(handles);


function handles = setupImage(handles)
% This function is called after an image has been loaded.
% Only image is valid. This function set up other fields from the
% values of current image, stored as userdata of 'imageDisplay' object.
%
% Returns the modified data structure

% get imag data
img = get(handles.imageDisplay, 'userdata');

% compute image dimension and determines if image is color or grayscale
dim = size(img);

% check image type
handles.color = false;
handles.vector = false;
if length(dim) > 3
    valMin = min(img(:));
    valMax = max(img(:));
    % choose image nature
    if dim(3) ~= 3 || valMin < 0 || (isfloat(img) && valMax > 1)
        handles.vector = true;
    else
        handles.color = true;
    end
    % keep only spatial dimensions
    dim = dim([1 2 4]);
end

% eventually compute grayscale extent
if ~handles.color
    handles.grayscaleExtent = computeGrayScaleExtent(img);
    [mini maxi] = computeGrayScaleExtent(img);
    handles.grayscaleExtent  = [mini maxi];
end

% conversion from Matlab convention to XYZ convention
dim = dim([2 1 3]);
handles.dim = dim;

% setup zoom
zoom = computeBestZoom(handles);
handles.zoom = zoom;

% display the new image
h_img = displayNewImage(handles);
handles.h_img = h_img;

% update gui data
guidata(handles.mainFrame, handles);


function zoom = computeBestRoundedZoom(handles)
% setup initial zoom: find best zoom, rounded to the closest power of 2.

% round zoom to closest power of 2
zoom = computeBestZoom(handles);
zoom = power(2, round(log2(zoom)));


function zoom = computeBestZoom(handles)
% find the zoom that best fit the greater dimension

% get data
dim     = handles.dim;
view    = handles.view;
spacing = handles.voxelSize;

% compute best zoom
zoom = min(view(1:2) ./ dim(1:2) ./ spacing(1:2));


% --------------------------------------------------------------------
function itemQuit_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFrame);


% --------------------------------------------------------------------
function menuImage_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to menuImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuView_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to menuView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuChangeLUT_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to menuChangeLUT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function itemSetMatlabLut_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to itemSetMatlabLut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function setColorLut_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to setColorLut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function itemDisplayImageInfo_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemDisplayImageInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

info = handles.imgInfo;
if isempty(info)
    errordlg('No meta-information defined for this image', ...
        'Image Error', 'modal');
    return;
end

% extract field names
fields = fieldnames(info);
nFields = length(fields);

% create data table as a cell array of strings
data =cell(nFields, 2);
for i=1:nFields
    data{i, 1} = fields{i};
    dat = info.(fields{i});
    if ischar(dat)
        data{i,2} = dat;
    elseif isnumeric(dat)
        data{i,2} = num2str(dat);
    else
        data{i,2} = '...';
    end
end

% create name for figure
if isempty(handles.imgName)
    name = 'Image Metadata';
else
    name = sprintf('MetaData for image <%s>', handles.imgName);
end

% creates and setup newfigure
f   = figure('MenuBar', 'none', 'Name', name);
set(f, 'units', 'pixels');
pos = get(f, 'position');
width = pos(3);
% sum of width is not equal to 1 to avoid rounding errors.
columnWidth = {round(width * .30), round(width * .69)}; 

% display the data table
uitable(...
    'Parent', f, ...
    'Units','normalized',...
    'Position', [0 0 1 1], ...
    'Data', data, ...
    'RowName', [], ...
    'ColumnName', {'Name', 'Value'}, ...
    'ColumnWidth', columnWidth, ...
    'ColumnFormat', {'char', 'char'}, ...
    'ColumnEditable', [false, false]);


% --------------------------------------------------------------------
function itemChangeVoxelSize_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemChangeVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% configure dialog
spacing = handles.voxelSize;
prompt = {...
    'Size in X direction:', ...
    'Size in Y direction:', ...
    'Size in Z direction:', ...
    'Unit name:'};
title = 'Image resolution';
defaultValues = [cellstr(num2str(spacing'))' {handles.voxelSizeUnit}];

% ask for answer
answer = inputdlg(prompt, title, 1, defaultValues);
if isempty(answer)
    return;
end

for i = 1:3
    spacing(i) = str2double(answer{i});
    if isnan(spacing(i))
        warning('slicer:parsing', 'could not parse resolution string');
        return;
    end
end
handles.voxelSize = spacing;
handles.voxelSizeUnit = answer{4};

% setup zoom
zoom = computeBestRoundedZoom(handles);
handles.zoom = zoom;

% display the new image
h_img = displayNewImage(handles);
handles.h_img = h_img;

% update gui data
guidata(handles.mainFrame, handles);



% --------------------------------------------------------------------
function menuGrayscaleRange_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU> 
% hObject    handle to menuGrayscaleRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function itemGrayRangeImage_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemGrayRangeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.color || handles.vector
    return
end

% compute grayscale extent
img = get(handles.imageDisplay, 'userdata');
mini = min(img(:));
maxi = max(img(:));

% setup appropriate grayscale for image
set(get(handles.h_img, 'parent'), 'CLim', [mini maxi]);

% stores grayscale infos
handles.grayscaleExtent = [mini maxi];
guidata(handles.mainFrame, handles);


% --------------------------------------------------------------------
function itemGrayRangeDataType_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemGrayRangeDataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.color || handles.vector
    return
end

img = get(handles.imageDisplay, 'userdata');

% compute grayscale extent
mini = 0;
maxi = 1;
if isinteger(img)
    type = class(img);
    mini = intmin(type);
    maxi = intmax(type);
elseif isfloat(img)
    mini = min(img(:));
    maxi = max(img(:));
end

% setup appropriate grayscale for image
set(get(handles.h_img, 'parent'), 'CLim', [mini maxi]);

% stores grayscale infos
handles.grayscaleExtent = [mini maxi];
guidata(handles.mainFrame, handles);


% --------------------------------------------------------------------
function itemGrayRangeManual_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemGrayRangeManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.color || handles.vector
    return
end

img = get(handles.imageDisplay, 'userdata');

% get extreme values for grayscale in image
minimg = min(img(:));
maximg = max(img(:));

% get actual value for grayscale range
ax = get(handles.h_img, 'parent');
clim = get(ax, 'CLim');

% define dialog options
if isinteger(minimg)
    prompt = {...
        sprintf('Min grayscale value (%d):', minimg), ...
        sprintf('Max grayscale value (%d):', maximg)};
else
    prompt = {...
        sprintf('Min grayscale value (%f):', minimg), ...
        sprintf('Max grayscale value (%f):', maximg)};
end    
dlg_title = 'Input for grayscale range';
num_lines = 1;
def = {num2str(clim(1)), num2str(clim(2))};

% open the dialog
answer = inputdlg(prompt, dlg_title, num_lines, def);

% if user cancel, return
if isempty(answer)
    return;
end

% convert input texts into numerical values
mini = str2double(answer{1});
maxi = str2double(answer{2});

% setup appropriate grayscale for image
set(get(handles.h_img, 'parent'), 'CLim', [mini maxi]);

% stores grayscale infos
handles.grayscaleExtent = [mini maxi];
guidata(handles.mainFrame, handles);


% --------------------------------------------------------------------
function menuTransform_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU> 
% hObject    handle to menuTransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function itemRotateImageLeft_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 3, -1);

% --------------------------------------------------------------------
function itemRotateImageRight_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 3, 1);

% --------------------------------------------------------------------
function itemRotateImageXUp_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageXUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 1, -1);

% --------------------------------------------------------------------
function itemRotateImageXDown_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageXDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 1, 1);

% --------------------------------------------------------------------
function itemRotateImageYLeft_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageYLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 2, -1);

% --------------------------------------------------------------------
function itemRotateImageYRight_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemRotateImageYRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateImage(handles, 2, 1);


function handles = rotateImage(handles, axis, n)
% Rotate the inner 3D image and the associated meta-information
% axis is given between 1 and 3, in XYZ convention
% n is the number of rotations (typically 1, 2, 3 or -1)

% extract image data
img = get(handles.imageDisplay, 'userdata');

% convert to ijk ordering
axis = xyz2ijk(axis);

% performs image rotation, and get axis permutation parameters
[img inds] = rotateStack90(img, axis, n);

set(handles.imageDisplay, 'userdata', img);

% permute meta info
handles.dim         = handles.dim(inds);
handles.voxelSize   = handles.voxelSize(inds);
handles.voxelOrigin = handles.voxelOrigin(inds);

% computes new best zoom
handles.zoom        = computeBestRoundedZoom(handles);

% for rotation that imply z axis, need to change zslice
if axis ~= 3
    % setup current slice in the middle of the stack
    handles.slice = round(handles.dim(3)/2);
end

% display the new image
handles.h_img       = displayNewImage(handles);

% need to update handles for h_img
guidata(handles.mainFrame, handles);


% --------------------------------------------------------------------
function itemFlipImageX_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemFlipImageX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.imageDisplay, 'userdata', ...
    flipdim(get(handles.imageDisplay, 'userdata'), 2));

% display the new image
handles.h_img       = displayNewImage(handles);
% need to update handles for h_img
guidata(handles.mainFrame, handles);

% --------------------------------------------------------------------
function itemFlipImageY_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemFlipImageY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.imageDisplay, 'userdata', ...
    flipdim(get(handles.imageDisplay, 'userdata'), 1));

% display the new image
handles.h_img       = displayNewImage(handles);
% need to update handles for h_img
guidata(handles.mainFrame, handles);

% --------------------------------------------------------------------
function itemFlipImageZ_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemFlipImageZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dim = 3;
if handles.color || handles.vector
    dim = 4;
end
set(handles.imageDisplay, 'userdata', ...
    flipdim(get(handles.imageDisplay, 'userdata'), dim));

% display the new image
handles.h_img       = displayNewImage(handles);

% need to update handles for h_img
guidata(handles.mainFrame, handles);



% --------------------------------------------------------------------
function itemShowOrthoSlices_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemShowOrthoSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get display data
pos = round(handles.dim / 2);
spacing = handles.voxelSize;

% create figure with 3 orthogonal slices
figure();
orthoSlices(get(handles.imageDisplay, 'userdata'), pos, spacing, ...
    'DisplayRange', handles.grayscaleExtent, 'lut', handles.lut);


% --------------------------------------------------------------------
function itemShow3dOrthoSlices_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemShow3dOrthoSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get display data
pos = round(handles.dim / 2);
spacing = handles.voxelSize;

% create figure with 3 orthogonal slices
figure();
orthoSlices3d(get(handles.imageDisplay, 'userdata'), pos, spacing, ...
    'DisplayRange', handles.grayscaleExtent, 'lut', handles.lut);

view(3);

% --------------------------------------------------------------------
function itemZoomIn_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.zoom = handles.zoom*2;
setZoom(handles);


% --------------------------------------------------------------------
function itemZoomOut_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.zoom = handles.zoom/2;
setZoom(handles);


% --------------------------------------------------------------------
function itemZoomOne_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemZoomOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.zoom = 1;
setZoom(handles);


% --------------------------------------------------------------------
function itemZoomBest_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemZoomBest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.zoom = computeBestZoom(handles);

% update properties
setZoom(handles);


% --------------------------------------------------------------------
function itemViewHistogram_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to itemViewHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create new figure
if isempty(handles.imgName)
    name = 'Image Histogram';
else
    name = ['Histogram of image ' handles.imgName];
end
figure('Name', name, 'NumberTitle', 'Off');

fprintf('Computing histogram...');

img = get(handles.imageDisplay, 'UserData');

% in the case of vector image, compute histogram of image norm
if handles.vector
    img = sqrt(sum(double(img) .^ 2, 3));
end

if ~handles.color
    % Process gray-scale image
    [minimg maximg] = computeGrayScaleExtent(img);
    x = linspace(double(minimg), double(maximg), 256);
    hist(double(img(:)), x);
    colormap jet;
    
elseif handles.color
    % process RGB 3D image
    
    % determine max value in the channels
    if isinteger(img)
        maxi = 255;
    else
        maxi = 1;
    end
    
    % compute histogram of each channel
    h = zeros(256, 3);
    x = linspace(0, maxi, 256);
    for i = 1:3
        im = img(:,:,i,:);
        h(:,i) = hist(double(im(:)), x);
    end
    
    % display each color histogram as stairs, to see the 3 curves
    hh = stairs(x, h);
    set(hh(1), 'color', [1 0 0]); % red
    set(hh(2), 'color', [0 1 0]); % green
    set(hh(3), 'color', [0 0 1]); % blue
    
    minimg = 0;
    maximg = maxi;
end

fprintf(' done\n');
xlim([minimg maximg]);


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU> 
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nothing to do ....


% --------------------------------------------------------------------
function itemAbout_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to itemAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

title = 'About Slicer';
info = dir(which('slicer'));
message = {...
    '       3D Slicer for Matlab', ...
    ['          v ' datestr(info.datenum, 1)], ...
    '', ...
    '     Author: David Legland', ...
    'david.legland@grignon.inra.fr', ...
    '        (c) INRA - Cepia', ...
    ''};
msgbox(message, title);


% --------------------------------------------------------------------
function imageDisplay_ButtonDownFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% Update display of mouse coordinate and pixel value

% get axis coordinate of point, and convert to image coord
point = get(handles.imageDisplay, 'currentPoint');
displayPixelCoords(handles, point);

function imageDisplay_ButtonMotionFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% Update display of mouse coordinate and pixel value

% get axis coordinate of point, and convert to image coord
point = get(handles.imageDisplay, 'currentPoint');
displayPixelCoords(handles, point);

function mouseWheelScrolled(hObject, eventdata)

handles = guidata(hObject);
newIndex = handles.slice - eventdata.VerticalScrollCount;
newIndex = min(max(newIndex, 1), handles.dim(3));

handles.slice = newIndex;
setSlice(handles);


function displayPixelCoords(handles, point)

point = point(1, 1:2);
coord = round(pointToIndex(handles, point));

% control on bounds of image
if sum(coord < 1) > 0 || sum(coord > handles.dim(1:2)) > 0
    set(handles.pointValueText, 'string', '');
    return;
end

% Display coordinates of clicked point
if sum(handles.voxelSize ~= 1) > 0
    locString = sprintf('(x,y) = (%d,%d) px = (%5.2f,%5.2f) %s', ...
        coord(1), coord(2), point(1), point(2), handles.voxelSizeUnit);
else
    locString = sprintf('(x,y) = (%d,%d) px', coord(1), coord(2));
end

set(handles.pointXText, 'String', locString);
img = get(handles.imageDisplay, 'userdata');

% Display value of selected pixel
if handles.color
    % case of color pixel: values are red, green and blue
    rgb = img(coord(2), coord(1), :, handles.slice);
    if isinteger(rgb)
        pattern = 'RGB=(%d %d %d)';
    else
        pattern = 'RGB=(%g %g %g)';
    end
    valueString = sprintf(pattern, rgb(1), rgb(2), rgb(3));
    
elseif handles.vector
    % case of vector image: compute norm of the pixel
    values = img(coord(2), coord(1), :, handles.slice);
    norm = sqrt(sum(double(values(:)) .^ 2));
    valueString = sprintf('value=%g', norm);
    
else
    % case of a gray-scale pixel
    value = img(coord(2), coord(1), handles.slice);
    if ~isfloat(value)
        valueString = sprintf('value=%3d', value);
    else
        valueString = sprintf('value=%g', value);
    end
end
set(handles.pointValueText, 'string', valueString);


function point = displayToUserPoint(handles, point)  %#ok<INUSL,DEFNU> 
% Converts a point in view coordinate to a point in user coordinate

function index = pointToIndex(handles, point)
% Converts coordinates of a point in physical dimension to image index
% First element is column index, second element is row index, both are
% given in floating point and no rounding is performed.
spacing = handles.voxelSize(1:2);
origin  = handles.voxelOrigin(1:2);
index   = (point - origin) ./ spacing + 1;

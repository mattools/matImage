classdef Slicer < handle
%GUI for exploration of 3D images, using Object Oriented Programming.
%
%   SLICER is an graphical interface to explore slices of a 3D image.
%   Index of the current slice is given under the slider, mouse position as
%   well as cursor value are indicated when mouse is moved over image, and
%   scrollbars allow to navigate within image.
%   
%   SLICER should work with any kind of 3D images: binary, gray scale
%   (integer or floating-point) or color RGB.
%
%   slicer(IMG);
%   where IMG is a preloaded M*N*P matrix, opens the slicer GUI,
%   initialized with image IMG.
%   User can change current slice with the slider to the left, X and Y
%   position with the two corresponding sliders, and change the zoom in the
%   View menu.
%
%   Slicer(IMGNAME, ...);
%   Load the stack specified by IMGNAME. It can be either a tif bundle, the
%   first file of a series, or a 3D image stored in one of the medical
%   image format:
%   * DICOM (*.dcm) 
%   * Analyze (*.hdr) 
%   * MetaImage (*.mhd, *.mha) 
%   It is also possible to import a raw data file, from the File->Import
%   menu.
%
%   Slicer
%   without argument opens with an empty interface, and allows to open an
%   image through the menu.
%
%   Slicer(..., PARAM, VALUE);
%   Specifies one or more display options as name-value parameter pairs.
%   Available parameter names are:
%
%   * 'Slice'       the display uses slice given by VALUE as current slice
%
%   * 'Name'        gives a name to the image (for display in title bar)
%
%   * 'Spacing'     specifies the size of voxel elements. VALUE is a 1-by-3
%         row vector containing spacing in x, y and z direction.
%
%   * 'Origin'      specifies coordinate of first voxel in user space
%
%   * 'UnitName'    the name of the unit used for spatial calibration (can
%         be any string, default is empty).
%
%   * 'DisplayRange' the values of min and max gray values to display. The
%         default behaviour is to use [0 255] for uint8 images, or to
%         compute bounds such as 95% of the voxels are converted to visible
%         gray levels for other image types.
%
%   * 'ColorMap'    The colormap used for displaying grayscale images
%         (default is gray). Should be a N-by-3 array of double, with N=256
%         for grayscale or intensity images, as N=the number of labels for
%         label images, and N=2 for binary images.
%
%   * 'BackgroundColor'    the color used as background for label images.
%
%   * 'ImageType'   The type of image, used for adapting display. Can be
%           one of 'binary', 'grayscale', 'intensity', 'label', 'color',
%           'vector', 'none'. Default value is assessed from data type and
%           size.
%
%   * 'Parent'  another instance of Slicer, that is used to initialize
%           several parameters like spatial resolution, display range, LUT
%           for display...
%           
%
%   Example
%   % Explore human brain MRI
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     Slicer(I);
%
%   % show the 10-th slice, and add some setup
%     Slicer(I, 'Slice', 10, 'Spacing', [1 1 2.5], 'Name', 'Brain', 'DisplayRange', [0 90]);
%
%   See also
%     imStacks, imscrollpanel
%
%   Requires
%       GUI Layout Toolbox version 2.0, or 1.17 (try to switch depending on
%       Matlab version)
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-04-12,    using Matlab 7.9.0.529 (R2009b)
% https://github.com/mattools/matImage
% Copyright 2011 INRAE - BIA - BIBS

%% Properties
properties
    % Image data stored as a 3D or 4D array, in YX(C)Z order.
    ImageData;
    
    % type of image. Can be one of:
    % 'binary'
    % 'grayscale'
    % 'intensity'
    % 'label'
    % 'color' 
    % 'vector'
    % 'none'
    ImageType;
    
    % size of the reference image (1-by-3 row vector, in XYZ order)
    ImageSize;
    
    % extra info for image, such as the result of imfinfo
    ImageInfo;
    
    % extra info for image, such as the result of imfinfo
    ImageName;

    % displayed data (2D image)
    Slice;
    
    % z-index of slice within 3D image
    SliceIndex;
    
    % used to adjust constrast of the slice
    DisplayRange;
    
    % Look-up table for display of uint8, label and binary images.
    % can be empty, in obj case gray colormap is assumed 
    ColorMap = [];

    % background color for label to RGB conversion. Given as RGB triplet of
    % values bewteen 0 and 1. Default is white = (1,1,1).
    BgColor = [1 1 1];

    % calibration information for image
    VoxelOrigin;
    VoxelSize;
    VoxelSizeUnit;
    
    % shortcut for avoiding many tests. Should be set to true when either
    % voxelOrigin, voxelsize or voxelSizeUnit is different from its default
    % value.
    Calibrated = false;
    
    % keep last path for opening new images
    LastPath = pwd;
    
    % list of handles to the widgets.
    % Structure with following fields:
    % * Figure:     the main figure
    % * SubFigures: a list of figures that can be closed when the main
    %           figure is closed
    % * Image:      the image display
    % * ImageAxis:  the axis containing the image
    % * ZSlider:    the slider used to change the slice index
    % * ZEdit:      the edit uicontrol used to change slice index
    % * ZProfileFigure used to display the profile along z 
    % * ZProfileAxis used to display the profile along z 
    Handles;
    
    % the last position of mouse click, in user coordinates.
    LastClickedPoint = []; 
end 


%% Constructor
methods
    function obj = Slicer(varargin)
        
        % call parent constructor
        obj = obj@handle();
        
        % initialize structure containing handles
        obj.Handles = struct();
        
        % keep pointer to current path
        obj.LastPath = pwd;
        
        % initialize using image given as argument
        if ~isempty(varargin)
            var = varargin{1};
            if isa(var, 'Image')
                setupImageFromClass(obj, var);
            elseif ischar(var)
                setupImageFromFile(obj, var);
            else
                if ndims(var) < 3 %#ok<ISMAT>
                    error('Requires input image with at least 3 dimensions');
                end
                setupImageData(obj, var, inputname(1));
            end
            varargin(1) = [];
            
            if isempty(obj.ImageData)
                return;
            end
            
        else
            obj.ImageData = [];
            obj.ImageType = 'none';
        end
        
        % parses input arguments, given as list of name-value pairs
        parsesInputArguments();
        
        % add checkup on visible image slice
        if ~isempty(obj.ImageData)
            obj.SliceIndex = min(obj.SliceIndex, obj.ImageSize(3));
        end
        
        updateCalibrationFlag(obj);

        % create default figure
        fig = figure();
        set(fig, 'Menubar', 'none');
        set(fig, 'NumberTitle', 'off');
        set(fig, 'Name', 'Slicer');
        
        obj.Handles.Figure = fig;
        obj.Handles.SubFigures = [];
        
        % create main figure menu and layout
        setupMenuBar(obj);
        setupLayout(fig);
        
        % setup new image display
        if ismember(obj.ImageType, {'label', 'binary'})
            maxi = max(obj.ImageData(:));
            obj.DisplayRange  = [0 maxi];
            
            if isempty(obj.ColorMap)
                obj.ColorMap = jet(double(maxi));
            end
            colormap([obj.BgColor ; obj.ColorMap]);
        end
        updateSlice(obj);
        displayNewImage(obj);
        updateTitle(obj);
        
        % setup listeners associated to the figure
        set(fig, 'WindowButtonDownFcn', @obj.mouseButtonPressed);
        set(fig, 'WindowButtonMotionFcn', @obj.mouseDragged);
        set(fig, 'WindowScrollWheelFcn', @obj.mouseWheelScrolled);
        set(fig, 'NextPlot', 'new');

        function parsesInputArguments()
            % iterate over couples of input arguments to setup display
            while length(varargin) > 1
                param = varargin{1};
                switch lower(param)
                    case 'parent'
                        % copy some settings from parent Slicer 
                        parent = varargin{2};
                        obj.SliceIndex     = parent.SliceIndex;
                        obj.VoxelSize      = parent.VoxelSize;
                        obj.VoxelOrigin    = parent.VoxelOrigin;
                        obj.VoxelSizeUnit  = parent.VoxelSizeUnit;
                        obj.Calibrated     = parent.Calibrated;
                        obj.ImageType      = parent.ImageType;
                        obj.DisplayRange   = parent.DisplayRange;
                        obj.ColorMap       = parent.ColorMap;
                        obj.BgColor        = parent.BgColor;
                        
                    case 'slice'
                        % setup initial slice
                        pos = varargin{2};
                        obj.SliceIndex = pos(1);
                        
                    % Setup spatial calibration
                    case 'spacing'
                        obj.VoxelSize = varargin{2};
                        if ~obj.Calibrated
                            obj.VoxelOrigin = [0 0 0];
                        end
                        obj.Calibrated = true;
                        
                    case 'origin'
                        obj.VoxelOrigin = varargin{2};
                        obj.Calibrated = true;
                        
                    case 'unitname'
                        obj.VoxelSizeUnit = varargin{2};
                        obj.Calibrated = true;
                       
                    case 'name'
                        obj.ImageName = varargin{2};
                        
                    case 'imagetype'
                        obj.ImageType = varargin{2};
                        
                    % Setup image display
                    case 'displayrange'
                        obj.DisplayRange = varargin{2};
                    case 'colormap'
                        obj.ColorMap = varargin{2};
                    case 'backgroundcolor'
                        obj.BgColor = varargin{2};
                        
                    otherwise
                        error(['Unknown parameter name: ' param]);
                end
                varargin(1:2) = [];
            end

        end
        
        function setupLayout(hf)
            % Creates the widgets that constitute the Slicer main frame
            
            if verLessThan('matlab', '8.4')
                % horizontal layout
                mainPanel = uiextras.HBox('Parent', hf, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                
                % panel for slider + slice number
                leftPanel = uiextras.VBox('Parent', mainPanel, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            else
                % horizontal layout
                mainPanel = uix.HBox('Parent', hf, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                
                % panel for slider + slice number
                leftPanel = uix.VBox('Parent', mainPanel, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            end
            
            if ~isempty(obj.ImageData)
                % slider for slice
                zmin = 1;
                zmax = obj.ImageSize(3);
                zstep1 = 1/zmax;
                zstep2 = min(10/zmax, .5);
                obj.Handles.ZSlider = uicontrol('Style', 'slider', ...
                    'Parent', leftPanel, ...
                    'Min', zmin, 'Max', zmax', ...
                    'SliderStep', [zstep1 zstep2], ...
                    'Value', obj.SliceIndex, ...
                    'Callback', @obj.onSliceSliderChanged, ...
                    'BackgroundColor', [1 1 1]);
                
                % code for dragging the slider thumb
                % @see http://undocumentedmatlab.com/blog/continuous-slider-callback
                if verLessThan('matlab', '8.4')
                    hListener = handle.listener(obj.Handles.ZSlider, ...
                        'ActionEvent', @obj.onSliceSliderChanged);
                    setappdata(obj.Handles.ZSlider, 'sliderListeners', hListener);
                else
                    addlistener(obj.Handles.ZSlider, ...
                        'ContinuousValueChange', @obj.onSliceSliderChanged);
                end
                
                % edition of slice number
                obj.Handles.ZEdit = uicontrol('Style', 'edit', ...
                    'Parent', leftPanel, ...
                    'String', num2str(obj.SliceIndex), ...
                    'Callback', @obj.onSliceEditTextChanged, ...
                    'BackgroundColor', [1 1 1]);
                
                if verLessThan('matlab', '8.4')
                    leftPanel.Sizes = [-1 20];
                else
                    leftPanel.Heights = [-1 20];
                end
            end
            
            
            % panel for image display + info panel
            if verLessThan('matlab', '8.4')
                rightPanel = uiextras.VBox('Parent', mainPanel);
            else
                rightPanel = uix.VBox('Parent', mainPanel);
            end
            
            % scrollable panel for image display
            scrollPanel = uipanel('Parent', rightPanel);
            
            if ~isempty(obj.ImageData)
                ax = axes('parent', scrollPanel, ...
                    'units', 'normalized', ...
                    'position', [0 0 1 1]);
                obj.Handles.ImageAxis = ax;

                % initialize image display with default image.
                hIm = imshow(zeros([10 10], 'uint8'), 'parent', ax);
                obj.Handles.ScrollPanel = imscrollpanel(scrollPanel, hIm);
                set(scrollPanel, 'resizeFcn', @obj.onScrollPanelResized);

                % keep widgets handles
                obj.Handles.Image = hIm;
            end
            
            % info panel for cursor position and value
            obj.Handles.InfoPanel = uicontrol(...
                'Parent', rightPanel, ...
                'Style', 'text', ...
                'String', ' x=    y=     I=', ...
                'HorizontalAlignment', 'left');
            
            % set up relative sizes of layouts
            if verLessThan('matlab', '8.4')
                rightPanel.Sizes = [-1 20];
                mainPanel.Sizes = [30 -1];
            else
                rightPanel.Heights = [-1 20];
                mainPanel.Widths = [30 -1];
            end
            
            % once each panel has been resized, setup image magnification
            if ~isempty(obj.ImageData)
                api = iptgetapi(obj.Handles.ScrollPanel);
                mag = api.findFitMag();
                api.setMagnification(mag);
            end
        end
        
    end % constructor

end % construction function

%% General use methods
methods
    function createNewSlicer(obj, imgData, newName, varargin)
        % Creates a new Slicer figure with given data, and keeping the
        % settings of the current slicer.
        options = {...
            'spacing', obj.VoxelSize, ...
            'origin', obj.VoxelOrigin, ...
            'slice', obj.SliceIndex, ...
            'name', newName};
        
        Slicer(imgData, options{:}, varargin{:});
    end
    
    function setupImageData(obj, img, imgName)
        % replaces all informations about image
        
        % Setup image data and type
        obj.ImageData = img;
        obj.ImageType = 'grayscale';
        
        % compute size, and detect RGB
        dim = size(img);
        nd = length(dim);
        
        % check image type
        if nd > 3
            % Image is 3D color or vector
            
            % extreme values
            valMin = min(img(:));
            valMax = max(img(:));
            
            % determines image nature
            if dim(3) ~= 3 || valMin < 0 || (isfloat(img) && valMax > 1)
                obj.ImageType = 'vector';
            else
                obj.ImageType = 'color';
            end
            
            % keep only spatial dimensions
            dim = dim([1 2 4]);
        elseif nd == 2
            dim = [dim 1];
        end
        
        % convert to use dim(1)=x, dim(2)=y, dim(3)=z
        obj.ImageSize = dim([2 1 3]);
        
        % eventually compute grayscale extent
        if ~strcmp(obj.ImageType, 'color')
            [mini, maxi] = computeGrayScaleExtent(obj);
            obj.DisplayRange  = [mini maxi];
        end
        
        % empty colorMap by default
        obj.ColorMap = [];
        
        % default slice index is in the middle of the stack
        obj.SliceIndex = ceil(dim(3) / 2);
        
        % setup default calibration
        obj.VoxelOrigin    = [1 1 1];
        obj.VoxelSize      = [1 1 1];
        obj.VoxelSizeUnit  = '';
        
        % update image name
        obj.ImageName = imgName;
        
        updateSlice(obj);
    end
    
    function setupImageFromClass(obj, img)
        % Initialize gui data from an Image class
        % 
        
        if ndims(img) ~= 3
            error('Need an <Image> object of dimension 3');
        end
        
        % intialize with image data
        setupImageData(obj, getBuffer(img), img.Name);
        
        % extract spatial calibration
        obj.VoxelOrigin     = img.Origin;
        obj.VoxelSize       = img.Spacing;
        obj.VoxelSizeUnit   = img.UnitName;
    end
    
    function setupImageFromFile(obj, fileName)
        % replaces all informations about image
        
        [filepath, basename, ext] = fileparts(fileName); %#ok<ASGLU>
        
        switch lower(ext)
            case {'.mhd', '.mha'}
                importMetaImage(obj, fileName);
            case '.dcm'
                importDicomImage(obj, fileName);
            case '.hdr'
                importAnalyzeImage(obj, fileName);
            case '.vm'
                importVoxelMatrix(obj, fileName);
            otherwise
                readImageStack(obj, fileName);
        end

    end
    
    function readImageStack(obj, fileName)
        % Read image stack, either as single file bundle or as file series
        
        [img, map] = readstack(fileName);
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];
        
        setupImageData(obj, img, imgName);
        
        % calibrate colormap if present
        if ~isempty(map)
            obj.ColorMap = map;
        end
        
        obj.LastPath = pathName;
        
        
        % try to read file info
        if exist(fileName, 'file')
            info = imfinfo(fileName);
            info = info(1);
            
            % extract image resolution (pixel size)
            if isfield(info, 'XResolution')
                xresol = info.('XResolution');
                yresol = xresol;
                if isfield(info, 'YResolution')
                    yresol = info.('YResolution');
                end
                obj.VoxelSize = [xresol yresol 1];
            end
            
            obj.ImageInfo = info;
        end
    end
    
    function importMetaImage(obj, fileName)
        % Load a metaImage file
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];

        info = metaImageInfo(fileName);

        % update display
        setupImageData(obj, metaImageRead(info), imgName);

        % setup spatial calibration
        if isfield(info, 'ElementSize')
            obj.VoxelSize = info.('ElementSize');
        else
            isfield(info, 'ElementSpacing')
            obj.VoxelSize = info.('ElementSpacing');
        end
        if isfield(info, 'Offset')
            obj.VoxelOrigin = info.('Offset');
        end
        if isfield(info, 'ElementOrigin')
            obj.VoxelOrigin = info.('ElementOrigin');
        end
        
        obj.LastPath = pathName;
        obj.ImageInfo = info;
    end
    
    function importDicomImage(obj, fileName)
        
        % read image data
        info = dicominfo(fileName);
        [img, map] = dicomread(info);
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
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        setupImageData(obj, img, imgName);
        
        obj.LastPath = pathName;
        obj.ImageInfo = info;
    end
    
    function importAnalyzeImage(obj, fileName)
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];

        info = analyze75info(fileName);
        
        % update display
        setupImageData(obj, analyze75read(info), imgName);
        
        % setup calibration
        if isfield(info, 'PixelDimensions')
            obj.VoxelSize = info.('PixelDimensions');
        end
        if isfield(info, 'VoxelUnits')
            obj.VoxelSizeUnit = info.('VoxelUnits');
        end
        
        obj.LastPath = pathName;
        obj.ImageInfo = info;
    end
    
    function importInterfileImage(obj, fileName)
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        info = interfileinfo(fileName);
        setupImageData(obj, interfileread(info), imgName);

        obj.LastPath = pathName;
        obj.ImageInfo = info;
    end
    
    
    function importRawDataImage(obj, fileName)
        
        % dialog to choose image dimensions
        answers = inputdlg(...
            {'X Size (columns):', 'Y Size (rows):', 'Z Size (slices):', ...
            'Channel number:'}, ...
            'Input Image Dimensions',...
            1, {'10', '10', '10', '1'});
        if isempty(answers)
            return;
        end
        
        % parse dimensions
        dims = [0 0 0 0];
        for i = 1:4
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
        
        % if number of channels is specified, use it as third dimension
        if dims(4) > 1
            dims = dims([1 2 4 3]);
        end
        
        % read raw stack (use correction of some bugs in 'readstack' function)
        dataType = types{selection};
        img = readstack(fileName, dataType, dims);
                
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];
        
        Slicer(img, 'name', imgName);
        
        % setup file infos
        obj.LastPath = pathName;
    end
    
    function importVoxelMatrix(obj, fileName)
        
        types = {'uint8', 'uint16', 'int16', 'single', 'double'};
        [sel, ok] = listdlg(...
            'PromptString', 'Choose data type:',...
            'SelectionMode', 'single',...
            'ListString', types, ...
            'Name', 'Data Type');
        if ~ok 
            return;
        end
        dataType = types{sel};
        
        % read image data
        try
            data = readVoxelMatrix(fileName, dataType);
        catch %#ok<CTCH>
            [path, name] = fileparts(fileName); %#ok<ASGLU>
            errordlg(['Could not import voxel Matrix File ' name], ...
                'File Error', 'modal');
            return;
        end
        
        % determine image name
        [pathName, baseName, ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        setupImageData(obj, data, imgName);
       
        obj.LastPath = pathName;

    end 
end
    
%% Some methods for image manipulation
methods
    function [mini, maxi] = computeGrayScaleExtent(obj)
        % compute grayscale extent of obj inner image
        
        if isempty(obj.ImageData)
            mini = 0; 
            maxi = 1;
            return;
        end
        
        % check image data type
        if strcmp(obj.ImageType, 'binary') || islogical(obj.ImageData)
            % for binary images, the grayscale extent is defined by the type
            mini = 0;
            maxi = 1;
            
        elseif strcmp(obj.ImageType, 'grayscale') && isa(obj.ImageData, 'uint8')
            % use min-max values depending on image type
            mini = 0;
            maxi = 255;
            
        elseif strcmp(obj.ImageType, 'vector')
            % case of vector image: compute max of norm
            
            dim = size(obj.ImageData);
            
            norm = zeros(dim([1 2 4]));
            
            for i = 1:dim(3)
                norm = norm + squeeze(obj.ImageData(:,:,i,:)) .^ 2;
            end
            
            mini = 0;
            maxi = sqrt(max(norm(:)));
            
        elseif strcmp(obj.ImageType, 'label')
            mini = 0;
            maxi = max(obj.ImageData(:));
            
        else
            % for float images, display 99 percents of dynamic
            [mini, maxi] = computeGrayscaleAdjustement(obj, .01);            
        end
    end
    
    function [mini, maxi] = computeGrayscaleAdjustement(obj, alpha)
        % compute grayscale range that maximize vizualisation
        
        if isempty(obj.ImageData)
            mini = 0; 
            maxi = 1;
            return;
        end
        
        % use default value for alpha if not specified
        if nargin == 1
            alpha = .01;
        end
        
        % sort values that are valid (avoid NaN's and Inf's)
        values = sort(obj.ImageData(isfinite(obj.ImageData)));
        n = length(values);

        % compute values that enclose (1-alpha) percents of all values
        mini = values( floor((n-1) * alpha/2) + 1);
        maxi = values( floor((n-1) * (1-alpha/2)) + 1);

        % small control to avoid mini==maxi
        minDiff = 1e-12;
        if abs(maxi - mini) < minDiff
            % use extreme values in image
            mini = values(1);
            maxi = values(end);
            
            % if not enough, set range to [0 1].
            if abs(maxi - mini) < minDiff
                mini = 0;
                maxi = 1;
            end
        end
    end
    
    function rotateImage(obj, axis, n)
        % Rotate the inner 3D image and the associated meta-information
        % axis is given between 1 and 3, in XYZ convention
        % n is the number of rotations (typically 1, 2, 3 or -1)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % convert to ijk ordering
        indices = [2 1 3];
        axis = indices(axis);
        
        % performs image rotation, and get axis permutation parameters
        [obj.ImageData, inds] = rotateStack90(obj.ImageData, axis, n);
        
        % permute meta info
        obj.ImageSize   = obj.ImageSize(inds);
        obj.VoxelSize   = obj.VoxelSize(inds);
        obj.VoxelOrigin = obj.VoxelOrigin(inds);
        
        % for rotation that imply z axis, need to change zslice
        if axis ~= 3
            % update limits of zslider
            set(obj.Handles.ZSlider, 'min', 1);
            set(obj.Handles.ZSlider, 'max', obj.ImageSize(3));
        
            % setup current slice in the middle of the stack
            newIndex = ceil(obj.ImageSize(3) / 2);
            updateSliceIndex(obj, newIndex);
        end
        
        % update and display the new slice
        updateSlice(obj);
        displayNewImage(obj);
        updateTitle(obj);
    end
    
    
    function displayNewImage(obj)
        % Refresh image display of the current slice
        
        if isempty(obj.ImageData)
            return;
        end
        
        api = iptgetapi(obj.Handles.ScrollPanel);
        api.replaceImage(obj.Slice);
        
        % extract calibration data
        spacing = obj.VoxelSize(1:2);
        origin  = obj.VoxelOrigin(1:2);
        
        % set up spatial calibration
        dim     = obj.ImageSize;
        xdata   = ([0 dim(1)-1] * spacing(1) + origin(1));
        ydata   = ([0 dim(2)-1] * spacing(2) + origin(2));
        
        set(obj.Handles.Image, 'XData', xdata);
        set(obj.Handles.Image, 'YData', ydata);
        
        % compute image extent in physical coordinates
        p0 = ([0 0]    - .5) .* spacing + origin;
        p1 = (dim(1:2) - .5) .* spacing + origin;
        
        % setup axis extent
        set(obj.Handles.ImageAxis, 'XLim', [p0(1) p1(1)]);
        set(obj.Handles.ImageAxis, 'YLim', [p0(2) p1(2)]);
        
        % for grayscale and vector images, adjust display range and LUT
        if ~strcmp(obj.ImageType, 'color')
            set(obj.Handles.ImageAxis, 'CLim', obj.DisplayRange);
            
            % setup the appropriate color map (stored color map, plus
            % eventullay the background color for label images)
            cmap = obj.ColorMap;
            if  ~isempty(cmap)
                if strcmp(obj.ImageType, 'label')
                    cmap = [obj.BgColor ; cmap];
                end
                colormap(obj.Handles.ImageAxis, cmap);
            end
        end
        
        % adjust zoom to view the full image
        api = iptgetapi(obj.Handles.ScrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
    end
    
end



%% Callbacks for File Menu
methods
    function onOpenImage(obj, hObject, eventdata)
        showOpenImageDialog(obj);
    end
    
    function onOpenDemoImage(obj, hObject, eventdata)  %#ok<INUSL>
        
        demoName = get(hObject, 'UserData');
        switch demoName
            case 'brainMRI'
                metadata = analyze75info('brainMRI.hdr');
                img = analyze75read(metadata);
                Slicer(img, ...
                    'Spacing', [1 1 2.5], ...
                    'Name', 'Brain', ...
                    'DisplayRange', [0 90]);
                
            case 'unitBall'
                lx = linspace(-1, 1, 101);
                [x, y, z] = meshgrid(lx, lx, lx);
                dist = sqrt(max(1 - (x.^2 + y.^2 + z.^2), 0));
                Slicer(dist, ...
                    'Origin', [-1 -1 -1], ...
                    'Spacing', [.02 .02 .02], ...
                    'Name', 'Unit Ball');
                
            otherwise
                error(['Unknown demo image: ' demoName]);
        end
    end
    
    function onImportRawData(obj, hObject, eventdata)
        [fileName, pathName] = uigetfile( ...
       {'*.raw', 'Raw data file(*.raw)'; ...
        '*.*',   'All Files (*.*)'}, ...
        'Import Raw Data', ...
        obj.LastPath);
        
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end
        
        importRawDataImage(obj, fullfile(pathName, fileName));
    end
    
    function showOpenImageDialog(obj, hObject, eventdata)
        % Display the dialog, determines image type, and setup image accordingly
        
        [fileName, pathName] = uigetfile( ...
            {'*.gif;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.hdr;*.dcm;*.mhd;*.lsm;*.vm', ...
            'All Image Files (*.tif, *.hdr, *.dcm, *.mhd, *.lsm, *.bmp, *.jpg)'; ...
            '*.tif;*.tiff',             'TIF Files (*.tif, *.tiff)'; ...
            '*.bmp',                    'BMP Files (*.bmp)'; ...
            '*.hdr',                    'Mayo Analyze Files (*.hdr)'; ...
            '*.dcm',                    'DICOM Files (*.dcm)'; ...
            '*.mhd;*.mha',              'MetaImage data files (*.mha, *.mhd)'; ...
            '*.lsm',                    'Zeiss LSM files(*.lsm)'; ...
            '*.vm',                     'Voxel Matrix data files(*.vm)'; ...
            '*.*',                      'All Files (*.*)'}, ...
            'Choose a stack or the first slice of a series:', ...
            obj.LastPath);
        
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end

        % open a new Slicer with the specified file
        Slicer(fullfile(pathName, fileName));
        
    end
    
    function onImportFromWorkspace(obj, hObject, eventdata)
        % Import an image from a variable in current workspace

        % open dialog to input image name
        prompt = {'Enter Variable Name:'};
        title = 'Import From Workspace';
        lines = 1;
        def = {'ans'};
        answer = inputdlg(prompt, title, lines, def);
        
        % if user cancels, answer is empty
        if isempty(answer)
            return;
        end
        
        data = evalin('base', answer{1});
        
        if ndims(data) < 3 %#ok<ISMAT>
            errordlg('Input Image must have at least 3 dimensions');
            return;
        end
        
        Slicer(data, 'Name', answer{1});
    end
    
    
    function onSaveImage(obj, hObject, eventdata)
        % Display the dialog, determines image type, and save image 
        % accordingly

        if isempty(obj.ImageData)
            return;
        end
        
        % show save image dialog
        [fileName, pathName, filterIndex] = uiputfile( ...
            {'*.tif;*.tiff;*.hdr;*.dcm;*.mhd', ...
            'All Supported Files (*.tif, *.dcm, *.mhd)'; ...
            '*.tif;*.tiff',             'TIF stacks (*.tif, *.tiff)'; ...
            '*.dcm',                    'DICOM Files (*.dcm)'; ...
            '*.mhd;*.mha',              'MetaImage data files (*.mha, *.mhd)'; ...
            }, ...
            'Save 3D Image', ...
            obj.LastPath);
        
        % if user cancel, quit dialog
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end

        % if no extension is specified, put another one
        [path, baseName, ext] = fileparts(fileName); %#ok<ASGLU>
        if isempty(ext)
            filterExtensions = {'.mhd', '.tif', '.dcm', '.mhd'};
            fileName = [fileName filterExtensions{filterIndex}];
        end

        % create full file name
        fullName = fullfile(pathName, fileName);
        
        % save image data
        [path, baseName, ext] = fileparts(fileName); %#ok<ASGLU>
        switch (ext)
            case {'.mha', '.mhd'}
                metaImageWrite(obj.ImageData, fullName);
                
            case {'.tif', '.tiff'}
                savestack(obj.ImageData, fullName);
                
            case '.dcm'
                dicomwrite(obj.ImageData, fullName);
    
            otherwise
                error(['Non supported File Format: ' ext]);
        end
    end

    function onExportToWorkspace(obj, hObject, eventdata)
        % Export current image data to workspace
        
        % open dialog to input image name
        prompt = {'Enter image name:'};
        title = 'Export Image Data';
        lines = 1;
        def = {'img'};
        answer = inputdlg(prompt, title, lines, def);
        
        % if user cancels, answer is empty
        if isempty(answer)
            return;
        end
        
        assignin('base', answer{1}, obj.ImageData);
    end
 
end


%% Callbacks for Image menu
methods
    function onDisplayImageInfo(obj, varargin)
        % hObject    handle to itemDisplayImageInfo (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        if isempty(obj.ImageData)
            errordlg('No image loaded', 'Image Error', 'modal');
            return;
        end
        
        info = obj.ImageInfo;
        if isempty(info)
            errordlg('No meta-information defined for obj image', ...
                'Image Error', 'modal');
            return;
        end
        
        % extract field names
        fields = fieldnames(info);
        nFields = length(fields);
        
        % create data table as a cell array of strings
        data = cell(nFields, 2);
        for i = 1:nFields
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
        if isempty(obj.ImageName)
            name = 'Image Metadata';
        else
            name = sprintf('MetaData for image <%s>', obj.ImageName);
        end
        
        % creates and setup new figure
        f = figure('MenuBar', 'none', 'Name', name);
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
        
    end
 
    function onChangeResolution(obj, varargin)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % configure dialog
        spacing = obj.VoxelSize;
        prompt = {...
            'Voxel size in X direction:', ...
            'Voxel size in Y direction:', ...
            'Voxel size in Z direction:', ...
            'Unit name:'};
        title = 'Image resolution';
        defaultValues = [cellstr(num2str(spacing'))' {obj.VoxelSizeUnit}];
        
        % ask for answer
        answer = inputdlg(prompt, title, 1, defaultValues);
        if isempty(answer)
            return;
        end
        
        % parse resolution in each direction
        for i = 1:3
            spacing(i) = str2double(answer{i});
            if isnan(spacing(i))
                warning('Slicer:onChangeResolution:Parsing', ...
                    ['Could not parse the string: ' answer{i}]);
                return;
            end
        end
        
        % set up the new resolution
        obj.VoxelSize = spacing;
        obj.VoxelSizeUnit = answer{4};
        
        updateCalibrationFlag(obj);
        
        % re-display the image
        displayNewImage(obj);
        updateTitle(obj);
    end
    
    function onChangeImageOrigin(obj, varargin)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % configure dialog
        origin = obj.VoxelOrigin;
        prompt = {...
            'Image origin in X direction:', ...
            'Image origin in Y direction:', ...
            'Image origin in Z direction:'};
        title = 'Change Image origin';
        defaultValues = [cellstr(num2str(origin'))' {obj.VoxelSizeUnit}];
        
        % ask for answer
        answer = inputdlg(prompt, title, 1, defaultValues);
        if isempty(answer)
            return;
        end
        
        % parse resolution in each direction
        for i = 1:3
            origin(i) = str2double(answer{i});
            if isnan(origin(i))
                warning('Slicer:onChangeResolution:Parsing', ...
                    ['Could not parse the string: ' answer{i}]);
                return;
            end
        end
        
        % set up the new resolution
        obj.VoxelOrigin = origin;
        updateCalibrationFlag(obj);
        
        % re-display the image
        displayNewImage(obj);
        updateTitle(obj);
    end
    
    function updateCalibrationFlag(obj)
        obj.Calibrated = ...
            sum(obj.VoxelSize ~= 1) > 0 || ...
            sum(obj.VoxelOrigin ~= 1) > 0 || ...
            ~isempty(obj.VoxelSizeUnit);
    end
    
    function onConvertColorToGray(obj, hObject, eventData)
        % convert RGB image to grayscale
        
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is color
        if ~strcmp(obj.ImageType, 'color')
            return;
        end
        
        % compute conversion coefficients
        mat = inv([...
            1.0  0.956  0.621; ...
            1.0 -0.272 -0.647; ...
            1.0 -1.106  1.703 ]);
        coefs = mat(1, :);

        % convert inner image data
        newData = squeeze(imlincomb(...
            coefs(1), obj.ImageData(:,:,1,:), ...
            coefs(2), obj.ImageData(:,:,2,:), ...
            coefs(3), obj.ImageData(:,:,3,:)));
        createNewSlicer(obj, newData, obj.ImageName);
    end
    
    function onConvertIntensityToColor(obj, hObject, eventData)
        % convert grayscale to RGB using current colormap
        
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is grayscale
        if ~ismember(obj.ImageType, {'grayscale', 'intensity'})
            return;
        end
        
        % choose the colormap
        cmap = obj.ColorMap;
        if isempty(cmap)
            cmap = gray(max(obj.ImageData(:)));
        end
        
        % convert inner image data
        newData = uint8(double2rgb(obj.ImageData, ...
            cmap, obj.DisplayRange, obj.BgColor) * 255);
        createNewSlicer(obj, newData, obj.ImageName);
    end
    
    function onConvertLabelsToColor(obj, hObject, eventData)
        % convert grayscale to RGB using current colormap
        
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is label
        if ~ismember(obj.ImageType, {'label', 'binary'})
            return;
        end
        
        % choose the colormap
        cmap = obj.ColorMap;
        if isempty(cmap)
            cmap = jet(256);
        end
        
        % colormap has 256 entries, we need only a subset
        nLabels = max(obj.ImageData(:));
        if size(cmap, 1) ~= nLabels
            inds = round(linspace(1, size(cmap,1), nLabels));
            cmap = cmap(inds, :);
        end
        
        % convert inner image data
        newData = label2rgb3d(obj.ImageData, cmap, obj.BgColor, 'shuffle');
        createNewSlicer(obj, newData, obj.ImageName);
    end

    function onChangeImageType(obj, hObject, eventData)
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is grayscale
        if ~ismember(obj.ImageType, {'grayscale', 'binary', 'label', 'intensity'})
            return;
        end

        % convert inner data array
        newType = get(hObject, 'UserData');
        switch newType
            case 'binary'
                obj.ImageData = obj.ImageData > 0;
            case 'grayscale'
                obj.ImageData = uint8(obj.ImageData);
            case 'intensity'
                obj.ImageData = double(obj.ImageData);
            case 'label'
                maxValue = max(obj.ImageData(:));
                if maxValue <= 255
                    obj.ImageData = uint8(obj.ImageData);
                elseif maxValue < 2^16
                    obj.ImageData = uint16(obj.ImageData);
                end
        end
        
        % update image type
        obj.ImageType = newType;
        
        % update display range
        [mini, maxi] = computeGrayScaleExtent(obj);
        obj.DisplayRange  = [mini maxi];

        % update display
        setupMenuBar(obj);
        updateSlice(obj);
        displayNewImage(obj);
        updateColorMap(obj);
        updateTitle(obj);
    end

    function onChangeDataType(obj, hObject, eventData)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(obj.ImageType, 'grayscale')
            return;
        end

        % convert inner data array
        newType = get(hObject, 'UserData');
        switch newType
            case 'binary'
                obj.ImageData = obj.ImageData > 0;
            case 'gray8'
                obj.ImageData = uint8(obj.ImageData);
            case 'gray16'
                obj.ImageData = uint16(obj.ImageData);
            case 'double'
                obj.ImageData = double(obj.ImageData);
        end
        
        % update display range
        [mini, maxi] = computeGrayScaleExtent(obj);
        obj.DisplayRange  = [mini maxi];

        % update display
        updateSlice(obj);
        displayNewImage(obj);
        updateTitle(obj);
    end
    
    function onSplitRGB(obj, hObject, eventdata) 
        
        if isempty(obj.ImageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(obj.ImageType, 'color')
            return;
        end
        
        createNewSlicer(obj, squeeze(obj.ImageData(:,:,1,:)), ...
            [obj.ImageName '-red']);
        createNewSlicer(obj, squeeze(obj.ImageData(:,:,2,:)), ...
            [obj.ImageName '-green']);
        createNewSlicer(obj, squeeze(obj.ImageData(:,:,3,:)), ...
            [obj.ImageName '-blue']);
    end
end


%% Callbacks for View menu
methods
    function onSetImageDisplayExtent(obj, hObject, eventdata)
        % compute grayscale extent from data in image

        if isempty(obj.ImageData)
            return;
        end
        
        if ~ismember(obj.ImageType, {'grayscale', 'intensity'})
            return;
        end
        
        % extreme values in image
        minValue = min(obj.ImageData(isfinite(obj.ImageData)));
        maxValue = max(obj.ImageData(isfinite(obj.ImageData)));
        
        % avoid special degenerate cases
        if abs(maxValue - minValue) < 1e-12
            minValue = 0;
            maxValue = 1;
        end
        
        % set up range
        obj.DisplayRange = [minValue maxValue];
        set(obj.Handles.ImageAxis, 'CLim', obj.DisplayRange);
        
        if isfield(obj.Handles, 'zProfileFigure')
            updateZProfileDisplay(obj);
        end
    end
    
    function onSetDatatypeDisplayExtent(obj, hObject, eventdata)
        % compute grayscale extent from image datatype

        if isempty(obj.ImageData)
            return;
        end
        
        if ~ismember(obj.ImageType, {'grayscale', 'intensity'})
            return;
        end
        
        mini = 0; maxi = 1;
        if isinteger(obj.ImageData)
            type = class(obj.ImageData);
            mini = intmin(type);
            maxi = intmax(type);
        end

        obj.DisplayRange = [mini maxi];
        set(obj.Handles.ImageAxis, 'CLim', obj.DisplayRange);
        
        if isfield(obj.Handles, 'zProfileFigure')
            updateZProfileDisplay(obj);
        end
    end
    
    function onSetManualDisplayExtent(obj, hObject, eventdata)
        if isempty(obj.ImageData)
            return;
        end
        
        if ~ismember(obj.ImageType, {'grayscale', 'intensity'})
            return;
        end
        
        % get extreme values for grayscale in image
        minimg = min(obj.ImageData(:));
        maximg = max(obj.ImageData(:));
        
        % get actual value for grayscale range
        clim = get(obj.Handles.ImageAxis, 'CLim');
        
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
        if isnan(mini) || isnan(maxi)
            return;
        end
        
        obj.DisplayRange = [mini maxi];
        
        % setup appropriate grayscale for image
        set(obj.Handles.ImageAxis, 'CLim', [mini maxi]);
        
        if isfield(obj.Handles, 'zProfileFigure')
            updateZProfileDisplay(obj);
        end
    end
    
    function onSelectLUT(obj, hObject, eventdata)
        % Change the LUT of the grayscale image, and refresh the display
        % colorMap name is specified by 'UserData' field of hObject
        
        if isempty(obj.ImageData)
            return;
        end
        
        cmapName = get(hObject, 'UserData');
        disp(['Change LUT to: ' cmapName]);
        
        nGrays = 256;
        if strcmp(obj.ImageType, 'label')
            nGrays = double(max(obj.ImageData(:)));
        end
        
        if strcmp(cmapName, 'gray')
            % for gray-scale, use an empty LUT
            obj.ColorMap = [];
            obj.ColorMap = gray(nGrays);
            
        elseif strcmp(cmapName, 'inverted')
            grayMax = nGrays - 1;
            obj.ColorMap = repmat((grayMax:-1:0)', 1, 3) / grayMax;
            
        elseif strcmp(cmapName, 'blue-gray-red')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(1,:) = [0 0 1];
            obj.ColorMap(end,:) = [1 0 0];
            
        elseif strcmp(cmapName, 'colorcube')
            nLabels = round(double(max(obj.ImageData(:))));
            map = colorcube(nLabels+2);
            % remove black and white colors
            isValidColor = sum(map==0, 2) ~= 3 & sum(map==1, 2) ~= 3;
            obj.ColorMap = [0 0 0; map(isValidColor, :)];
            
        elseif strcmp(cmapName, 'redLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, 2:3) = 0;
            
        elseif strcmp(cmapName, 'greenLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, [1 3]) = 0;
            
        elseif strcmp(cmapName, 'blueLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, 1:2) = 0;
            
        elseif strcmp(cmapName, 'yellowLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, 3) = 0;
            
        elseif strcmp(cmapName, 'cyanLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, 1) = 0;
            
        elseif strcmp(cmapName, 'magentaLUT')
            obj.ColorMap = gray(nGrays);
            obj.ColorMap(:, 2) = 0;
            
        else
            obj.ColorMap = feval(cmapName, nGrays);
        end

        updateColorMap(obj);
    end
    
    function updateColorMap(obj)
        % refresh the color map of current display
        
        % get current color map, or create a new one
        cmap = obj.ColorMap;
        if isempty(cmap)
            cmap = jet(256);
        end

        % adapt color map for label
        if strcmp(obj.ImageType, 'label')
            cmap = [obj.BgColor; cmap(2:end,:)];
        end
        
        colormap(obj.Handles.ImageAxis, cmap);
    end
    
    function onSelectBackgroundColor(obj, varargin)
        
        colorNames = {'White', 'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
        colors = [1 1 1; 0 0 0; 1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0];
        
        [ind, ok] = listdlg(...
            'PromptString', 'Background Color:',...
            'SelectionMode', 'Single',...
            'ListString', colorNames);
        if ~ok 
            return;
        end
        
        obj.BgColor = colors(ind, :);
        updateColorMap(obj);
    end
    
    function onShowOrthoPlanes(obj, varargin)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % compute display settings
        pos = ceil(obj.ImageSize / 2);
        spacing = obj.VoxelSize;
        
        % determine the LUT to use (default is empty)
        ortholut = [];
        if ~isColorStack(obj.ImageData) && ~isempty(obj.ColorMap)
            ortholut = obj.ColorMap;
        end
        
        % create figure with 3 orthogonal slices
        figure();
        orthoSlices(obj.ImageData, pos, spacing, ...
            'displayRange', obj.DisplayRange, 'LUT', ortholut);
    end
    
    function onShowOrthoSlices3d(obj, varargin)
        % Open a dialog to choose options, then display 3D orthoslices
        if isempty(obj.ImageData)
            return;
        end
        OrthoSlicer3dOptionsDialog(obj);
    end

    function onShowIsosurface(obj, varargin)
        % Choose an isosurface value, then computes the corresponding
        % surface mesh
        
        % check validity of input image
        if isempty(obj.ImageData)
            return;
        end
        if ~ismember(obj.ImageType, {'grayscale', 'intensity'})
            return;
        end
        
        % open options dialog for isosurface
        IsosurfaceOptionsDialog(obj);
    end
    
    function onShowLabelIsosurfaces(obj, varargin)
        % Open a dialog to choose options, then display label isosurfaces
        
        % check validity of input image
        if isempty(obj.ImageData)
            return;
        end
        if ~ismember(obj.ImageType, {'label', 'binary'})
            return;
        end
        
        % open options dialog for isosurface of label images
        LabelIsosurfacesOptionsDialog(obj);
    end
    
    function rgb = createRGBImage(obj)
        % compute a RGB stack that can be easily displayed
        
        if isempty(obj.ImageData)
            return;
        end
        
        if strcmp(obj.ImageType, 'color')
            rgb = obj.ImageData;
            return;
        end
        
        if ismember(obj.ImageType, {'grayscale', 'label', 'binary'})
            data = double(obj.ImageData);
            
        elseif strcmp(obj.ImageType, 'vector')
            data = zeros(obj.ImageSize);
            for i = 1:size(obj.ImageData, 3)
                data = data + squeeze(obj.ImageData(:,:,i,:)) .^ 2;
            end
            data = sqrt(data);
        end
        
        % convert to uint8, using current display range
        range = obj.DisplayRange;
        data = uint8(255 * (data - range(1)) / (range(2) - range(1)));
        
        % eventually apply a LUT
        if ~isempty(obj.ColorMap)
            lutMax = max(obj.ColorMap(:));
            dim = obj.ImageSize;
            rgb = zeros([dim(2) dim(1) 3 dim(3)], 'uint8');
            
            % compute each channel
            for c = 1 : size(obj.ColorMap, 2)
                res = zeros(size(data));
                for i = 0:size(obj.ColorMap, 1)-1
                    res(data == i) = obj.ColorMap(i+1, c);
                end
                rgb(:,:,c,:) = uint8(res * 255 / lutMax);
            end
            
        else
            rgb = repmat(permute(data, [1 2 4 3]), [1 1 3 1]);
        end
    end
    
    function onZoomIn(obj, varargin)
        if isempty(obj.ImageData)
            return;
        end
        
        api = iptgetapi(obj.Handles.ScrollPanel);
        mag = api.getMagnification();
        api.setMagnification(mag * 2);
        obj.updateTitle();
    end
    
    function onZoomOut(obj, varargin)
        if isempty(obj.ImageData)
            return;
        end
        
        api = iptgetapi(obj.Handles.ScrollPanel);
        mag = api.getMagnification();
        api.setMagnification(mag / 2);
        obj.updateTitle();
    end
    
    function onZoomOne(obj, varargin)
        if isempty(obj.ImageData)
            return;
        end
        
        api = iptgetapi(obj.Handles.ScrollPanel);
        api.setMagnification(1);
        obj.updateTitle();
    end
    
    function onZoomBest(obj, varargin)
        if isempty(obj.ImageData)
            return;
        end
        
        api = iptgetapi(obj.Handles.ScrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
        obj.updateTitle();
    end

    function onZoomValue(obj, hObject, eventData)
        % zoom to a given scale, stored in user data of calling object.
        % zoom value is given as binary power:
        % v positive ->  zoom = 2^v:1
        % v = 0      ->  zoom =   1:1
        % v negative ->  zoom = 1:2^v
        if isempty(obj.ImageData)
            return;
        end

        % get magnification
        mag = get(hObject, 'Userdata');
            
        % setup magnification of current view
        api = iptgetapi(obj.Handles.ScrollPanel);
        api.setMagnification(mag);
        obj.updateTitle();
    end 
end

%% Callbacks for Process menu
methods
    function onFlipImage(obj, hObject, eventdata)
        
        if isempty(obj.ImageData)
            return;
        end
        
        dim = get(hObject, 'UserData');
        if verLessThan('matlab', '8.1')
            obj.ImageData = flipdim(obj.ImageData, dim); %#ok<DFLIPDIM>
        else
            obj.ImageData = flip(obj.ImageData, dim);
        end
        obj.updateSlice;
        obj.displayNewImage;
    end
    
    function onRotateImage(obj, hObject, eventdata)
        % Rotate an image by 90 degrees along x, y or z axis.
        % Axis ID and number of 90 degrees rotations are given by user data
        % of the calling menu
        
        if isempty(obj.ImageData)
            return;
        end
        
        data = get(hObject, 'UserData');
        obj.rotateImage(data(1), data(2));
    end
    
    function onCropImage(obj, hObject, eventdata)
        % Crop the 3D image.
        % Opens a dialog, that choose options, then create new slicer
        % object with cropped image.
        
        if isempty(obj.ImageData)
            return;
        end
        
        CropStackDialog(obj);
    end
    
    function onCropLabel(obj, hObject, eventdata)
        % Crop the 3D image portion corresponding to a label.
        % Opens a dialog, that choose options, then create new slicer
        % object with cropped image.
        
        % basic input check
        if isempty(obj.ImageData)
            return;
        end
        if ~strcmp(obj.ImageType, 'label')
            return;
        end
        
        % open a dialog to choose a label
        maxLabel = max(obj.ImageData(:));
        prompt = sprintf('Input Label Index (max=%d)', maxLabel);
        answer = inputdlg(...
            prompt,...
            'Crop Label Dialog', ...
            1, ...
            {'1'});
        
        % parse answer
        if isempty(answer)
            return;
        end
        index = str2double(answer{1});
        if isnan(index)
            return;
        end
        
        % apply crop label operation
        img2 = imCropLabel(obj.ImageData, index);
        
        % compute colormap of new slicer object
        cmap = obj.ColorMap;
        if isempty(cmap)
            cmap = jet(maxLabel);
        end
        cmap = [obj.BgColor ; cmap(index, :)];
        
        % create new Slicer object with the crop result
        Slicer(img2, 'imageType', 'binary', ...
            'colorMap', cmap, 'backgroundColor', obj.BgColor);
    end
    
    function onToggleZProfileDisplay(obj, src, eventData)
        
        if isfield(obj.Handles, 'ZProfileFigure')
            % close figure
            hFig = obj.Handles.ZProfileFigure;
            if ishandle(hFig)
                close(hFig);
            end
            
            % remove from sub-figure list
            obj.Handles.SubFigures(obj.Handles.SubFigures == hFig) = [];
            
            % clear field
            obj.Handles = rmfield(obj.Handles, 'ZProfileFigure');
            
            % set menu entry to false
            set(src, 'Checked', 'Off');
            return;
        end

        % creates a new figure, display profile
        obj.Handles.ZProfileFigure = figure;
        set(obj.Handles.ZProfileFigure, 'Name', 'Z-Profile');
        
        % add to list of sub-figures
        obj.Handles.SubFigures = [obj.Handles.SubFigures, obj.Handles.ZProfileFigure];
        
        % configure axis
        ax = gca;
        hold(ax, 'on');
        set(ax, 'xlim', [1 obj.ImageSize(3)]);
        set(ax, 'ylim', obj.DisplayRange);
        titleStr = 'Z-profile';
        if ~isempty(obj.ImageName)
            titleStr = [titleStr ' of ' obj.ImageName];
        end
        title(ax, titleStr);
        xlabel(ax, 'Slice index');
        ylabel(ax, 'Image intensity');
        
        % plot line marker for current slice
        hZLine = plot(ax, [obj.SliceIndex obj.SliceIndex], obj.DisplayRange, 'k');
        
        % store settings
        userdata = struct('profiles', [], 'profileHandles', [], 'zLineHandle', hZLine);
        set(gca, 'userdata', userdata);
        obj.Handles.ZProfileAxis = ax;
        
        % set menu entry to true
        set(src, 'Checked', 'On');
            
%         if ~isempty(obj.LastClickedPoint)
%             updateZProfiles(obj);
%         end
    end
    
    function onDisplayHistogram(obj, varargin)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % in the case of vector image, compute histogram of image norm
        img = obj.ImageData;
        if strcmp(obj.ImageType, 'vector')
            img = sqrt(sum(double(img) .^ 2, 3));
        end
        
        useBackground = ~strcmp(obj.ImageType, 'label');
        hd = SlicerHistogramDialog(img, 'useBackground', useBackground);
        
        obj.Handles.SubFigures = [obj.Handles.SubFigures, hd];
    end 
end

%% Callbacks for Help menu
methods
    function onAbout(obj, varargin)
        title = 'About Slicer';
        info = dir(which('Slicer.m'));
        message = {...
            '       3D Slicer for Matlab', ...
            ['         v ' datestr(info.datenum, 1)], ...
            '', ...
            '      Author: David Legland', ...
            '      david.legland@inra.fr ', ...
            '       (c) INRA - Cepia', ...
            '', ...
            };
        msgbox(message, title);
    end
    
end


%% GUI Items callback
methods
    function onSliceSliderChanged(obj, hObject, eventdata) %#ok<*INUSD>
        if isempty(obj.ImageData)
            return;
        end
        
        zslice = round(get(hObject, 'Value'));
        zslice = max(get(hObject, 'Min'), min(get(hObject, 'Max'), zslice));

        updateSliceIndex(obj, zslice);
    end
        
    function onSliceEditTextChanged(obj, varargin)
        
        if isempty(obj.ImageData)
            return;
        end
        
        % get entered value for z-slice
        zslice = str2double(get(obj.Handles.ZEdit, 'String'));
        
        % in case of wrong edit, set the string to current value of zslice
        if isnan(zslice)
            zslice = obj.SliceIndex;
        end
        
        % compute slice number, inside of image bounds
        zslice = min(max(1, round(zslice)), obj.ImageSize(3));
        updateSliceIndex(obj, zslice);
    end
    
    function updateSliceIndex(obj, newIndex)
        if isempty(obj.ImageData)
            return;
        end
        
        obj.SliceIndex = newIndex;
        
        updateSlice(obj);
        
        set(obj.Handles.Image, 'CData', obj.Slice);
        
        % update gui information for slider and textbox
        set(obj.Handles.ZSlider, 'Value', newIndex);
        set(obj.Handles.ZEdit, 'String', num2str(newIndex));
        
        % Eventually updates display of z-profile
        if isfield(obj.Handles, 'ZProfileFigure')
            updateZProfileDisplay(obj);
        end
    end
    
    function updateSlice(obj)
        if isempty(obj.ImageData)
            return;
        end
        
        index = obj.SliceIndex;
        if strcmp(obj.ImageType, 'vector')
            % vector image
            dim = size(obj.ImageData);
            obj.Slice = zeros([dim(1) dim(2)]);
            for i = 1:dim(3)
                obj.Slice = obj.Slice + obj.ImageData(:,:,i,index) .^ 2;
            end
            obj.Slice = sqrt(obj.Slice);
        else
            % graycale or color image
            obj.Slice = stackSlice(obj.ImageData, 3, index);
        end
    end
    
    function updateTitle(obj)
        % set up title of the figure, containing name of figure and current zoom
        
        % small checkup, because function can be called before figure was
        % initialised
        if ~isfield(obj.Handles, 'Figure')
            return;
        end
        
        if isempty(obj.ImageData)
            set(obj.Handles.Figure, 'Name', 'Slicer - No image');
            return;
        end
        
        % setup name
        if isempty(obj.ImageName)
            imgName = 'Unknown Image';
        else
            imgName = obj.ImageName;
        end
        
        % determine the type to display:
        % * data type for intensity / grayscale image
        % * type of image otherwise
        switch obj.ImageType
            case 'grayscale'
                type = class(obj.ImageData);
            otherwise
                type = obj.ImageType;
        end
        
        % compute image zoom
        api = iptgetapi(obj.Handles.ScrollPanel);
        zoom = api.getMagnification();
        
        % compute new title string 
        titlePattern = 'Slicer - %s [%d x %d x %d %s] - %g:%g';
        titleString = sprintf(titlePattern, imgName, ...
            obj.ImageSize, type, max(1, zoom), max(1, 1/zoom));

        % display new title
        set(obj.Handles.Figure, 'Name', titleString);
    end
end

%% Mouse management
methods
    function mouseButtonPressed(obj, hObject, eventdata)
        if isempty(obj.ImageData)
            return;
        end
        
        point = get(obj.Handles.ImageAxis, 'CurrentPoint');
        
        obj.LastClickedPoint = point(1,:);
        displayPixelCoords(obj, point);
        
        % Eventually process display of z-profile
        if isfield(obj.Handles, 'ZProfileFigure')
            updateZProfiles(obj);
        end
    end
    
    function mouseDragged(obj, hObject, eventdata)
        if isempty(obj.ImageData)
            return;
        end
        
        % update display of mouse cursor coordinates
        point = get(obj.Handles.ImageAxis, 'CurrentPoint');
        obj.LastClickedPoint = point(1,:);
        displayPixelCoords(obj, point);
    end
    
    function mouseWheelScrolled(obj, hObject, eventdata) %#ok<INUSL>
        if isempty(obj.ImageData)
            return;
        end

        % refresh display of current slice
        newIndex = obj.SliceIndex - eventdata.VerticalScrollCount;
        newIndex = min(max(newIndex, 1), obj.ImageSize(3));
        updateSliceIndex(obj, newIndex);
        
        % update display of mouse cursor coordinates
        point = get(obj.Handles.ImageAxis, 'CurrentPoint');
        displayPixelCoords(obj, point);
    end
    
    function displayPixelCoords(obj, point)
        if isempty(obj.ImageData)
            return;
        end
        
        point = point(1, 1:2);
        coord = round(pointToIndex(obj, point));
        
        % control on bounds of image
        if sum(coord < 1) > 0 || sum(coord > obj.ImageSize(1:2)) > 0
            set(obj.Handles.InfoPanel, 'string', '');
            return;
        end
        
        % Display coordinates of clicked point
        if obj.Calibrated
            % Display pixel + physical position
            locString = sprintf('(x,y) = (%d,%d) px = (%5.2f,%5.2f) %s', ...
                coord(1), coord(2), point(1), point(2), obj.VoxelSizeUnit);
        else
            % Display only pixel position
            locString = sprintf('(x,y) = (%d,%d) px', coord(1), coord(2));
        end
        
        % Display value of selected pixel
        if strcmp(obj.ImageType, 'color')
            % case of color pixel: values are red, green and blue
            rgb = obj.ImageData(coord(2), coord(1), :, obj.SliceIndex);
            valueString = sprintf('  RGB = (%d %d %d)', ...
                rgb(1), rgb(2), rgb(3));
            
        elseif strcmp(obj.ImageType, 'vector')
            % case of vector image: compute norm of the pixel
            values  = obj.ImageData(coord(2), coord(1), :, obj.SliceIndex);
            norm    = sqrt(sum(double(values(:)) .^ 2));
            valueString = sprintf('  value = %g', norm);
            
        else
            % case of a gray-scale pixel
            value = obj.ImageData(coord(2), coord(1), obj.SliceIndex);
            if ~isfloat(value)
                valueString = sprintf('  value = %3d', value);
            else
                valueString = sprintf('  value = %g', value);
            end
        end
        
        set(obj.Handles.InfoPanel, 'string', [locString '  ' valueString]);
    end

    function updateZProfiles(obj)
        % add or replace z-profiles using last clicked point
        
        % convert mouse coordinates to pixel coords
        if isempty(obj.LastClickedPoint)
            return;
        end
        coord = round(pointToIndex(obj, obj.LastClickedPoint(1, 1:2)));
        
        % control on bounds of image
        if sum(coord < 1) > 0 || sum(coord > obj.ImageSize(1:2)) > 0
            return;
        end

        % extract profile
        profile = permute(obj.ImageData(coord(2), coord(1), :, :), [4 3 1 2]);
        
        % add profile to axis user data
        userdata = get(obj.Handles.ZProfileAxis, 'userdata');
        if strcmp(get(obj.Handles.Figure, 'SelectionType'), 'normal')
            % replace profile list with current profile
            userdata.profiles = profile;
            delete(userdata.profileHandles);
            h = plot(obj.Handles.ZProfileAxis, profile, 'b');
            userdata.profileHandles = h;
        else
            % add the current profile to profile list
            userdata.profiles = [userdata.profiles profile];
            h = plot(obj.Handles.ZProfileAxis, profile, 'b');
            userdata.profileHandles = [userdata.profileHandles h];
        end
        
        set(obj.Handles.ZProfileAxis, 'userdata', userdata);
    end
    
    function updateZProfileDisplay(obj)
        % update display of Z-profiles

        % update axis settings
        set(obj.Handles.ZProfileAxis, 'ylim', obj.DisplayRange);
        
        % update position of Z line marker
        userdata = get(obj.Handles.ZProfileAxis, 'userdata');
        hZLine = userdata.zLineHandle;
        set(hZLine, 'XData', [obj.SliceIndex obj.SliceIndex]);
        set(hZLine, 'YData', obj.DisplayRange);
    end
    
    function index = pointToIndex(obj, point)
        % Converts coordinates of a point in physical dimension to image index
        % First element is column index, second element is row index, both are
        % given in floating point and no rounding is performed.
        spacing = obj.VoxelSize(1:2);
        origin  = obj.VoxelOrigin(1:2);
        index   = (point - origin) ./ spacing + 1;
    end

end

%% Figure Callbacks
methods
    function close(obj, hObject, eventdata)
        % close the main figure, and all sub figures
        close(obj.Handles.Figure);
    end
            
    function onScrollPanelResized(obj, varargin)
        % function called when the Scroll panel has been resized
        
        if isempty(obj.ImageData)
            return;
        end
        
        scrollPanel = obj.Handles.ScrollPanel;
        api = iptgetapi(scrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
        updateTitle(obj);
    end
    
end % general methods

%% GUI Utilities
methods
    function setupMenuBar(obj)
        % Refresh the menu bar of application main figure.
        % Some menu items may be valid or invalide depending on the current
        % image class or size
        
        hf = obj.Handles.Figure;
        
        % remove menuitems that could already exist
        % (obj is the case when the image type is changed, for example)
        children = get(hf, 'children');
        delete(children(strcmp(get(children, 'Type'), 'uimenu')));
        
        % setup some flags that will able/disable some menu items
        if ~isempty(obj.ImageData)
            imageFlag = 'on';
        else
            imageFlag = 'off';
        end
        if strcmp(obj.ImageType, 'color')
            colorFlag = 'on';
        else
            colorFlag = 'off';
        end
        if ismember(obj.ImageType, {'label', 'binary'})
            labelFlag = 'on';
        else
            labelFlag = 'off';
        end
        if ismember(obj.ImageType, {'grayscale', 'label', 'binary'})
            grayscaleFlag = 'on';
        else
            grayscaleFlag = 'off';
        end
        if ismember(obj.ImageType, {'grayscale', 'label', 'binary', 'intensity'})
            scalarFlag = 'on';
        else
            scalarFlag = 'off';
        end
        if ismember(obj.ImageType, {'grayscale', 'intensity'})
            intensityFlag = 'on';
        else
            intensityFlag = 'off';
        end
        
        % files
        menuFiles = uimenu(hf, 'Label', '&Files');
        
        uimenu(menuFiles, ...
            'Label', '&Open...', ...
            'Accelerator', 'O', ...
            'Callback', @obj.onOpenImage);
        uimenu(menuFiles, ...
            'Label', 'Import &Raw Data...', ...
            'Callback', @obj.onImportRawData);
        uimenu(menuFiles, ...
            'Label', '&Import From Workspace...', ...
            'Callback', @obj.onImportFromWorkspace);
        menuDemo = uimenu(menuFiles, ...
            'Label', 'Demo Images');
        uimenu(menuDemo, ...
            'Label', 'Brain MRI', ...
            'UserData', 'brainMRI', ...
            'Callback', @obj.onOpenDemoImage);
        uimenu(menuDemo, ...
            'Label', 'Unit Ball', ...
            'UserData', 'unitBall', ...
            'Callback', @obj.onOpenDemoImage);

        uimenu(menuFiles, ...
            'Label', '&Save Image...', ...
            'Separator', 'On', ...
            'Enable', imageFlag, ...
            'Accelerator', 'S', ...
            'Callback', @obj.onSaveImage);
        uimenu(menuFiles, ...
            'Label', '&Export To Workspace...', ...
            'Enable', imageFlag, ...
            'Callback', @obj.onExportToWorkspace);
        uimenu(menuFiles, ...
            'Label', '&Close', ...
            'Separator', 'On', ...
            'Accelerator', 'W', ...
            'Callback', @obj.close);
        
        % Image
        menuImage = uimenu(hf, 'Label', '&Image', ...
            'Enable', imageFlag);
        
        uimenu(menuImage, ...
            'Label', 'Image &Info...', ...
            'Enable', imageFlag, ...
            'Accelerator', 'I', ...
            'Callback', @obj.onDisplayImageInfo);
        uimenu(menuImage, ...
            'Label', 'Spatial &Calibration...', ...
            'Enable', imageFlag, ...
            'Callback', @obj.onChangeResolution);
        uimenu(menuImage, ...
            'Label', 'Image &Origin...', ...
            'Enable', imageFlag, ...
            'Callback', @obj.onChangeImageOrigin);
        
        menuChangeImageType = uimenu(menuImage, ...
            'Label', 'Change Image Type', ...
            'Enable', scalarFlag, ...
            'Separator', 'On');
        uimenu(menuChangeImageType, ...
            'Label', 'Binary', ...
            'UserData', 'binary', ...
            'Callback', @obj.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Gray scale', ...
            'UserData', 'grayscale', ...
            'Callback', @obj.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Intensity', ...
            'UserData', 'intensity', ...
            'Callback', @obj.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Label', ...
            'UserData', 'label', ...
            'Callback', @obj.onChangeImageType);

        menuChangeGrayLevels = uimenu(menuImage, ...
            'Label', 'Change Gray levels', ...
            'Enable', grayscaleFlag);
        uimenu(menuChangeGrayLevels, ...
            'Label', '2 levels (Binary)', ...
            'UserData', 'binary', ...
            'Callback', @obj.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', '8 levels (uint8)', ...
            'UserData', 'gray8', ...
            'Callback', @obj.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', '16 levels (uint16)', ...
            'UserData', 'gray16', ...
            'Callback', @obj.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', 'intensity (double)', ...
            'UserData', 'double', ...
            'Callback', @obj.onChangeDataType);
        
        uimenu(menuImage, ...
            'Label', 'Convert Intensity to Color', ...
            'Enable', grayscaleFlag, ...
            'Callback', @obj.onConvertIntensityToColor);
        
        uimenu(menuImage, ...
            'Label', 'Convert Labels to Color', ...
            'Enable', labelFlag, ...
            'Callback', @obj.onConvertLabelsToColor);
        
        uimenu(menuImage, ...
            'Label', 'RGB to Gray', ...
            'Enable', colorFlag, ...
            'Callback', @obj.onConvertColorToGray);
        
        uimenu(menuImage, ...
            'Label', 'Split RGB', ...
            'Enable', colorFlag, ...
            'Callback', @obj.onSplitRGB);
        
        
        % View
        menuView = uimenu(hf, 'Label', '&View', ...
            'Enable', imageFlag);
        
        % Display range menu
        displayRangeMenu = uimenu(menuView, ...
            'Label', '&Display Range', ...
            'Enable', grayscaleFlag);
        uimenu(displayRangeMenu, ...
            'Label', '&Image', ...
            'Callback', @obj.onSetImageDisplayExtent);
        uimenu(displayRangeMenu, ...
            'Label', '&Data Type', ...
            'Callback', @obj.onSetDatatypeDisplayExtent);
        uimenu(displayRangeMenu, ...
            'Label', '&Manual', ...
            'Callback', @obj.onSetManualDisplayExtent);
        
        % LUTs menu
        menuLut = uimenu(menuView, ...
            'Label', '&Look-Up Table', ...
            'Enable', grayscaleFlag);
        uimenu(menuLut, ...
            'Label', 'Gray', ...
            'UserData', 'gray', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Inverted', ...
            'UserData', 'inverted', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Gray with Blue and Red', ...
            'UserData', 'blue-gray-red', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Jet', ...
            'UserData', 'jet', ...
            'Separator', 'On', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'HSV', ...
            'UserData', 'hsv', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Color Cube', ...
            'UserData', 'colorcube', ...
            'Callback', @obj.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Prism', ...
            'UserData', 'prism', ...
            'Callback', @obj.onSelectLUT);
        
        % Matlab LUT's
        matlabLutsMenu = uimenu(menuLut, ...
            'Label', 'Matlab''s LUT', ...
            'Separator', 'On');
        uimenu(matlabLutsMenu, ...
            'Label', 'Hot', ...
            'UserData', 'hot', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Cool', ...
            'UserData', 'cool', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Spring', ...
            'UserData', 'spring', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Summer', ...
            'UserData', 'summer', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Autumn', ...
            'UserData', 'autumn', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Winter', ...
            'UserData', 'winter', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Bone', ...
            'UserData', 'bone', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Copper', ...
            'UserData', 'copper', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Pink', ...
            'UserData', 'pink', ...
            'Callback', @obj.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Lines', ...
            'UserData', 'lines', ...
            'Callback', @obj.onSelectLUT);
        
        colorLutsMenu = uimenu(menuLut, ...
            'Label', 'Simple Colors');
        uimenu(colorLutsMenu, ...
            'Label', 'Red', ...
            'UserData', 'redLUT', ...
            'Callback', @obj.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Green', ...
            'UserData', 'greenLUT', ...
            'Callback', @obj.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Blue', ...
            'UserData', 'blueLUT', ...
            'Callback', @obj.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Yellow', ...
            'UserData', 'yellowLUT', ...
            'Callback', @obj.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Cyan', ...
            'UserData', 'cyanLUT', ...
            'Callback', @obj.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Magenta', ...
            'UserData', 'magentaLUT', ...
            'Callback', @obj.onSelectLUT);
        
        uimenu(menuLut, ...
            'Label', 'Background Color...', ...
            'Separator', 'On', ...
            'Callback', @obj.onSelectBackgroundColor);

        
        uimenu(menuView, ...
            'Label', 'Show Ortho Slices', ...
            'Separator', 'On', ...
            'Enable', imageFlag, ...
            'Callback', @obj.onShowOrthoPlanes);
        uimenu(menuView, ...
            'Label', 'Show 3D Ortho Slices', ...
            'Enable', imageFlag, ...
            'Callback', @obj.onShowOrthoSlices3d);
        uimenu(menuView, ...
            'Label', 'Isosurface Rendering', ...
            'Enable', intensityFlag, ...
            'Callback', @obj.onShowIsosurface);
        uimenu(menuView, ...
            'Label', 'Binary/Labels Surface Rendering', ...
            'Enable', labelFlag, ...
            'Callback', @obj.onShowLabelIsosurfaces);
        
        % Zoom menu items
        uimenu(menuView, ...
            'Label', 'Zoom &In', ...
            'Separator', 'On', ...
            'Callback', @obj.onZoomIn);
        uimenu(menuView, ...
            'Label', 'Zoom &Out', ...
            'Callback', @obj.onZoomOut);
        uimenu(menuView, ...
            'Label', 'Zoom 1:1', ...
            'Callback', @obj.onZoomOne);
        menuZoom = uimenu(menuView, ...
            'Label', 'Choose value');
        uimenu(menuView, ...
            'Label', 'Zoom &Best', ...
            'Accelerator', 'B', ...
            'Callback', @obj.onZoomBest);
        uimenu(menuZoom, ...
            'Label', '10:1', ...
            'UserData', 10, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '4:1', ...
            'UserData', 4, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '2:1', ...
            'UserData', 2, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:1', ...
            'UserData', 1, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:2', ...
            'UserData', 1/2, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:4', ...
            'UserData', 1/4, ...
            'Callback', @obj.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:10', ...
            'UserData', 1/10, ...
            'Callback', @obj.onZoomValue);
        
        
        % Process menu
        menuProcess = uimenu(hf, ...
            'Label', '&Process', ...
            'Enable', imageFlag);
        
        menuTransform = uimenu(menuProcess, ...
            'Label', 'Geometric &Transforms');
        uimenu(menuTransform, ...
            'Label', '&Horizontal Flip', ...
            'UserData', 2, ...
            'Callback', @obj.onFlipImage);
        uimenu(menuTransform, ...
            'Label', '&Vertical Flip', ...
            'UserData', 1, ...
            'Callback', @obj.onFlipImage);
        uimenu(menuTransform, ...
            'Label', 'Flip &Z', ...
            'UserData', 3, ...
            'Callback', @obj.onFlipImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate &Left', ...
            'Separator', 'On', ...
            'UserData', [3 -1], ...
            'Accelerator', 'L', ...
            'Callback', @obj.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate &Right', ...
            'UserData', [3 1], ...
            'Callback', @obj.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate X Up', ...
            'UserData', [1 -1], ...
            'Accelerator', 'R', ...
            'Callback', @obj.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate X Down', ...
            'UserData', [1 1], ...
            'Callback', @obj.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate Y Left', ...
            'UserData', [2 1], ...
            'Callback', @obj.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate Y Right', ...
            'UserData', [2 -1], ...
            'Callback', @obj.onRotateImage);
        
        uimenu(menuProcess, ...
            'Label', 'Crop Image', ...
            'Callback', @obj.onCropImage);
        uimenu(menuProcess, ...
            'Label', 'Crop Label', ...
            'Enable', labelFlag, ...
            'Callback', @obj.onCropLabel);
        uimenu(menuProcess, ...
            'Label', 'Toggle Z-Profile Display', ...
            'Callback', @obj.onToggleZProfileDisplay);

        uimenu(menuProcess, ...
            'Label', 'View &Histogram', ...
            'Separator', 'On', ...
            'Accelerator', 'H', ...
            'Callback', @obj.onDisplayHistogram);
        
        
        % Help
        menuHelp = uimenu(hf, 'Label', '&Help');
        uimenu(menuHelp, ...
            'Label', '&About...', ...
            'Accelerator', 'A', ...
            'Callback', @obj.onAbout);
    end
    
end

%% Methods for text display
methods
    function disp(obj)
        % display a resume of the slicer structure
                        
        if isempty(obj.ImageData)
            fprintf('Slicer object, with no image.\n')
        else
            fprintf('Slicer object, containing a %d x %d x %d %s image.\n', ...
                obj.ImageSize, obj.ImageType);
        end
        
        % calibration information for image
        if obj.Calibrated
            fprintf('  Voxel spacing = [ %g %g %g ] %s\n', ...
                obj.VoxelSize, obj.VoxelSizeUnit');
            fprintf('  Image origin  = [ %g %g %g ] %s\n', ...
                obj.VoxelOrigin, obj.VoxelSizeUnit');
        end

        % determines whether empty lines should be printed or not
        if strcmp(get(0, 'FormatSpacing'), 'loose')
            fprintf('\n');
        end
        
    end
end

end

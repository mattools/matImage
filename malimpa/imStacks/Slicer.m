classdef Slicer < handle
%SLICER GUI for exploration of 3D images, using Object Oriented Programming
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
%   * 'slice'       the display uses slice given by VALUE as current slice
%
%   * 'name'        gives a name to the image (for display in title bar)
%
%   * 'spacing'     specifies the size of voxel elements. VALUE is a 1-by-3
%         row vector containing spacing in x, y and z direction.
%
%   * 'origin'      specifies coordinate of first voxel in user space
%
%   * 'unitName'    the name of the unit used for spatial calibration (can
%         be any string, default is empty).
%
%   * 'displayRange' the values of min and max gray values to display. The
%         default behaviour is to use [0 255] for uint8 images, or to
%         compute bounds such as 95% of the voxels are converted to visible
%         gray levels for other image types.
%
%   * 'colorMap'    The colormap used for displaying grayscale images
%         (default is gray).
%
%   * 'imageType'   The type of image, used for adapting display. Can be
%           one of 'binary', 'grayscale', 'intensity', 'label', 'color',
%           'vector', 'none'. Default value is assessed from data type and
%           size.
%
%   Example
%   % Explore human brain MRI
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     Slicer(I);
%
%   % show the 10-th slice, and add some setup
%     Slicer(I, 'slice', 10, 'spacing', [1 1 2.5], 'name', 'Brain', 'displayRange', [0 90]);
%
%   See also
%     imStacks, imscrollpanel
%
%   Requires
%       GUILayout-v1p9
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-04-12,    using Matlab 7.9.0.529 (R2009b)
% http://www.pfl-cepia.inra.fr/index.php?page=slicer
% Copyright 2011 INRA - Cepia Software Platform.

%% Properties
properties
    % reference image (can be 2D, 3D or 4D)
    imageData;
    
    % type of image. Can be one of:
    % 'binary'
    % 'grayscale'
    % 'intensity'
    % 'label'
    % 'color' 
    % 'vector'
    % 'none'
    imageType;
    
    % size of the reference image (1-by-3 row vector, in XYZ order)
    imageSize;
    
    % extra info for image, such as the result of imfinfo
    imageInfo;
    
    % extra info for image, such as the result of imfinfo
    imageName;

    % displayed data (2D image)
    slice;
    
    % z-index of slice within 3D image
    sliceIndex;
    
    % used to adjust constrast of the slice
    displayRange;
    
    % Look-up table for display of uint8, label and binary images.
    % can be empty, in this case gray colormap is assumed 
    colorMap;

    % background color for label to RGB conversion. Given as RGB triplet
    % value bewteen 0 and 1. Default is white.
    bgColor = [1 1 1];

    % calibration information for image
    voxelOrigin;
    voxelSize;
    voxelSizeUnit;
    
    % shortcut for avoiding many tests. Should be set to true when either
    % voxelOrigin, voxelsize or voxelSizeUnit is different from its default
    % value.
    calibrated = false;
    
    % keep last path for opening new images
    lastPath = pwd;
    
    % list of handles to the widgets
    handles;
    
end 


%% Constructor
methods
    function this = Slicer(varargin)
        
        % call parent constructor
        this = this@handle();
        
        % initialize structure containing handles
        this.handles = struct();
        
        % keep pointer to current path
        this.lastPath = pwd;
        
        % initialize using image given as argument
        if ~isempty(varargin)
            var = varargin{1};
            if isa(var, 'Image')
                setupImageFromClass(this, var);
            elseif ischar(var)
                setupImageFromFile(this, var);
            else
                setupImageData(this, var, inputname(1));
            end
            varargin(1) = [];
            
            if isempty(this.imageData)
                return;
            end
            
        else
            this.imageData = [];
            this.imageType = 'none';
        end
        
        % initialize to empty LUT
        this.colorMap = [];
        
        % parses input arguments
        parsesInputArguments();
        
        updateCalibrationFlag(this);

        % create default figure
        fig = figure();
        set(fig, 'Menubar', 'none');
        set(fig, 'NumberTitle', 'off');
        set(fig, 'Name', 'Slicer');
        
        this.handles.figure = fig;
        this.handles.subFigures = [];
        
        % create main figure menu and layout
        setupMenuBar(this);
        setupLayout(fig);
        
        % setup new image display
        if strcmp(this.imageType, 'label')
            maxi = max(this.imageData(:));
            this.displayRange  = [0 maxi];
            this.colorMap = [this.bgColor; jet(255)];
        end
        updateSlice(this);
        displayNewImage(this);
        updateTitle(this);
        
        % setup listeners associated to the figure
        set(fig, 'WindowButtonMotionFcn', @this.mouseDragged);
        set(fig, 'WindowScrollWheelFcn', @this.mouseWheelScrolled);
        set(fig, 'NextPlot', 'new');

        function parsesInputArguments()
            % iterate over couples of input arguments to setup display
            while length(varargin) > 1
                param = varargin{1};
                switch lower(param)
                    case 'slice'
                        % setup initial slice
                        pos = varargin{2};
                        this.sliceIndex = pos(1);
                        
                    % Setup spatial calibration
                    case 'spacing'
                        this.voxelSize = varargin{2};
                        if ~this.calibrated
                            this.voxelOrigin = [0 0 0];
                        end
                        this.calibrated = true;
                        
                    case 'origin'
                        this.voxelOrigin = varargin{2};
                        this.calibrated = true;
                        
                    case 'unitname'
                        this.voxelSizeUnit = varargin{2};
                        this.calibrated = true;
                       
                    case 'name'
                        this.imageName = varargin{2};
                        
                    case 'imagetype'
                        this.imageType = varargin{2};
                        
                    % Setup image display
                    case 'displayrange'
                        this.displayRange = varargin{2};
                    case 'colormap'
                        this.colorMap = varargin{2};
                        
                    otherwise
                        error(['Unknown parameter name: ' param]);
                end
                varargin(1:2) = [];
            end

        end
        
        function setupLayout(hf)
            
            % horizontal layout
            mainPanel = uiextras.HBox('Parent', hf, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            
            % panel for slider + slice number
            leftPanel = uiextras.VBox('Parent', mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            
            if ~isempty(this.imageData)
                % slider for slice
                zmin = 1;
                zmax = this.imageSize(3);
                this.handles.zSlider = uicontrol('Style', 'slider', ...
                    'Parent', leftPanel, ...
                    'Min', zmin, 'Max', zmax', ...
                    'Value', this.sliceIndex, ...
                    'Callback', @this.onSliceSliderChanged, ...
                    'BackgroundColor', [1 1 1]);
                
                % code for dragging the slider thumb
                hListener = handle.listener(this.handles.zSlider, ...
                    'ActionEvent', @this.onSliceSliderChanged);
                setappdata(this.handles.zSlider, 'sliderListeners', hListener);
                
                % edition of slice number
                this.handles.zEdit = uicontrol('Style', 'edit', ...
                    'Parent', leftPanel, ...
                    'String', num2str(this.sliceIndex), ...
                    'Callback', @this.onSliceEditTextChanged, ...
                    'BackgroundColor', [1 1 1]);
                
                leftPanel.Sizes = [-1 20];
            end
            
            
            % panel for image display + info panel
            rightPanel = uiextras.VBox('Parent', mainPanel);
            
            % scrollable panel for image display
            scrollPanel = uipanel('Parent', rightPanel, ...
                'resizeFcn', @this.onScrollPanelResized);
            
            if ~isempty(this.imageData)
                ax = axes('parent', scrollPanel, ...
                    'units', 'normalized', ...
                    'position', [0 0 1 1]);
                this.handles.imageAxis = ax;

                % initialize image display with default image.
                hIm = imshow(zeros([10 10], 'uint8'), 'parent', ax);
                this.handles.scrollPanel = imscrollpanel(scrollPanel, hIm);

                % keep widgets handles
                this.handles.image = hIm;
            end
            
            % info panel for cursor position and value
            this.handles.infoPanel = uicontrol(...
                'Parent', rightPanel, ...
                'Style', 'text', ...
                'String', ' x=    y=     I=', ...
                'HorizontalAlignment', 'left');
            
            % set up relative sizes of layouts
            rightPanel.Sizes = [-1 20];
            mainPanel.Sizes = [30 -1];
            
            % once each panel has been resized, setup image magnification
            if ~isempty(this.imageData)
                api = iptgetapi(this.handles.scrollPanel);
                mag = api.findFitMag();
                api.setMagnification(mag);
            end
        end
        
    end % constructor

end % construction function

%% General use methods
methods
    function createNewSlicer(this, imgData, newName, varargin)
        % Creates a new Slicer figure with given data, and keeping the
        % settings of the current slicer.
        options = {...
            'spacing', this.voxelSize, ...
            'origin', this.voxelOrigin, ...
            'slice', this.sliceIndex, ...
            'name', newName};
        
        Slicer(imgData, options{:}, varargin{:});
    end
    
    function setupImageData(this, img, imgName)
        % replaces all informations about image
        
        % Setup image data and type
        this.imageData = img;
        this.imageType = 'grayscale';
        
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
                this.imageType = 'vector';
            else
                this.imageType = 'color';
            end
            
            % keep only spatial dimensions
            dim = dim([1 2 4]);
        elseif nd == 2
            dim = [dim 1];
        end
        
        % convert to use dim(1)=x, dim(2)=y, dim(3)=z
        this.imageSize = dim([2 1 3]);
        
        % eventually compute grayscale extent
        if ~strcmp(this.imageType, 'color')
            [mini maxi] = computeGrayScaleExtent(this);
            this.displayRange  = [mini maxi];
        end
        
        % empty colorMap by default
        this.colorMap = [];
        
        % default slice index is in the middle of the stack
        this.sliceIndex = ceil(dim(3) / 2);
        
        % setup default calibration
        this.voxelOrigin    = [1 1 1];
        this.voxelSize      = [1 1 1];
        this.voxelSizeUnit  = '';
        
        % update image name
        this.imageName = imgName;
        
        updateSlice(this);
    end
    
    function setupImageFromClass(this, img)
        % Initialize gui data from an Image class
        % 
        
        if ndims(img) ~= 3
            error('Need an <Image> object of dimension 3');
        end
        
        % intialize with image data
        setupImageData(this, getBuffer(img), img.name);
        
        % extract spatial calibration
        this.voxelOrigin     = img.origin;
        this.voxelSize       = img.spacing;
        this.voxelSizeUnit   = img.unitName;
    end
    
    function setupImageFromFile(this, fileName)
        % replaces all informations about image
        
        [filepath basename ext] = fileparts(fileName); %#ok<ASGLU>
        
        switch lower(ext)
            case {'.mhd', '.mha'}
                importMetaImage(this, fileName);
            case '.dcm'
                importDicomImage(this, fileName);
            case '.hdr'
                importAnalyzeImage(this, fileName);
            case '.vm'
                importVoxelMatrix(this, fileName);
            otherwise
                readImageStack(this, fileName);
        end

    end
    
    function readImageStack(this, fileName)
        
        img = readstack(fileName);
        
        % determine image name
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];
        
        setupImageData(this, img, imgName);
        
        this.lastPath = pathName;        
    end
    
    function importMetaImage(this, fileName)
        % Load a metaImage file
        
        % determine image name
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];

        info = metaImageInfo(fileName);

        % update display
        setupImageData(this, metaImageRead(info), imgName);

        % setup spatial calibration
        if isfield(info, 'ElementSize')
            this.voxelSize = info.('ElementSize');
        else
            isfield(info, 'ElementSpacing')
            this.voxelSize = info.('ElementSpacing');
        end
        if isfield(info, 'Offset')
            this.voxelOrigin = info.('Offset');
        end
        if isfield(info, 'ElementOrigin')
            this.voxelOrigin = info.('ElementOrigin');
        end
        
        this.lastPath = pathName;
        this.imageInfo = info;
    end
    
    function importDicomImage(this, fileName)
        
        % read image data
        info = dicominfo(fileName);
        [img map] = dicomread(info);
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
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        setupImageData(this, img, imgName);
        
        this.lastPath = pathName;
        this.imageInfo = info;
    end
    
    function importAnalyzeImage(this, fileName)
        
        % determine image name
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];

        info = analyze75info(fileName);
        
        % update display
        setupImageData(this, analyze75read(info), imgName);
        
        % setup calibration
        if isfield(info, 'PixelDimensions')
            this.voxelSize = info.('PixelDimensions');
        end
        if isfield(info, 'VoxelUnits')
            this.voxelSizeUnit = info.('VoxelUnits');
        end
        
        this.lastPath = pathName;
        this.imageInfo = info;
    end
    
    function importInterfileImage(this, fileName)
        
        % determine image name
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        info = interfileinfo(fileName);
        setupImageData(this, interfileread(info), imgName);

        this.lastPath = pathName;
        this.imageInfo = info;
    end
    
    
    function importRawDataImage(this, fileName)
        
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
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];
        
        Slicer(img, 'name', imgName);
        
        % setup file infos
        this.lastPath = pathName;
    end
    
    function importVoxelMatrix(this, fileName)
        
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
            [path name] = fileparts(fileName); %#ok<ASGLU>
            errordlg(['Could not import voxel Matrix File ' name], ...
                'File Error', 'modal');
            return;
        end
        
        % determine image name
        [pathName baseName ext] = fileparts(fileName);
        imgName = [baseName ext];

        % update display
        setupImageData(this, data, imgName);
       
        this.lastPath = pathName;

    end 
end
    
%% Some methods for image manipulation
methods
    function [mini maxi] = computeGrayScaleExtent(this)
        % compute grayscale extent of this inner image
        
        if isempty(this.imageData)
            mini = 0; 
            maxi = 1;
            return;
        end
        
        % check image data type
        if strcmp(this.imageType, 'binary') || islogical(this.imageData)
            % for binary images, the grayscale extent is defined by the type
            mini = 0;
            maxi = 1;
            
        elseif strcmp(this.imageType, 'grayscale') && isa(this.imageData, 'uint8')
            % use min-max values depending on image type
            mini = 0;
            maxi = 255;
            
        elseif strcmp(this.imageType, 'vector')
            % case of vector image: compute max of norm
            
            dim = size(this.imageData);
            
            norm = zeros(dim([1 2 4]));
            
            for i = 1:dim(3);
                norm = norm + squeeze(this.imageData(:,:,i,:)) .^ 2;
            end
            
            mini = 0;
            maxi = sqrt(max(norm(:)));
            
        elseif strcmp(this.imageType, 'label')
            mini = 0;
            maxi = max(this.imageData(:));
            
        else
            % for float images, display 99 percents of dynamic
            [mini maxi] = computeGrayscaleAdjustement(this, .01);            
        end
    end
    
    function [mini maxi] = computeGrayscaleAdjustement(this, alpha)
        % compute grayscale range that maximize vizualisation
        
        if isempty(this.imageData)
            mini = 0; 
            maxi = 1;
            return;
        end
        
        % use default value for alpha if not specified
        if nargin == 1
            alpha = .01;
        end
        
        % sort values that are valid (avoid NaN's and Inf's)
        values = sort(this.imageData(isfinite(this.imageData)));
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
    
    function rotateImage(this, axis, n)
        % Rotate the inner 3D image and the associated meta-information
        % axis is given between 1 and 3, in XYZ convention
        % n is the number of rotations (typically 1, 2, 3 or -1)
        
        if isempty(this.imageData)
            return;
        end
        
        % convert to ijk ordering
        indices = [2 1 3];
        axis = indices(axis);
        
        % performs image rotation, and get axis permutation parameters
        [this.imageData inds] = rotateStack90(this.imageData, axis, n);
        
        % permute meta info
        this.imageSize   = this.imageSize(inds);
        this.voxelSize   = this.voxelSize(inds);
        this.voxelOrigin = this.voxelOrigin(inds);
        
        % for rotation that imply z axis, need to change zslice
        if axis ~= 3
            % update limits of zslider
            set(this.handles.zSlider, 'min', 1);
            set(this.handles.zSlider, 'max', this.imageSize(3));
        
            % setup current slice in the middle of the stack
            newIndex = ceil(this.imageSize(3) / 2);
            updateSliceIndex(this, newIndex);
        end
        
        % update and display the new slice
        updateSlice(this);
        displayNewImage(this);
        updateTitle(this);
    end
    
    
    function displayNewImage(this)
        % Refresh image display of the current slice
        
        if isempty(this.imageData)
            return;
        end
        
        api = iptgetapi(this.handles.scrollPanel);
        api.replaceImage(this.slice);
        
        % extract calibration data
        spacing = this.voxelSize(1:2);
        origin  = this.voxelOrigin(1:2);
        
        % set up spatial calibration
        dim     = this.imageSize;
        xdata   = ([0 dim(1)-1] * spacing(1) + origin(1));
        ydata   = ([0 dim(2)-1] * spacing(2) + origin(2));
        
        set(this.handles.image, 'XData', xdata);
        set(this.handles.image, 'YData', ydata);
        
        % compute image extent
        p0 = ([0 0]    - .5) .* spacing + origin;
        p1 = (dim(1:2) - .5) .* spacing + origin;
        
        % setup axis extent
        set(this.handles.imageAxis, 'XLim', [p0(1) p1(1)]);
        set(this.handles.imageAxis, 'YLim', [p0(2) p1(2)]);
        
        % for grayscale and vector images, adjust displayrange and LUT
        if ~strcmp(this.imageType, 'color')
            set(this.handles.imageAxis, 'CLim', this.displayRange);
            if  ~isempty(this.colorMap)
                colormap(this.handles.imageAxis, this.colorMap);
            end
        end
        
        % adjust zoom to view the full image
        api = iptgetapi(this.handles.scrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
    end
    
end



%% Callbacks for File Menu
methods
    function onOpenImage(this, hObject, eventdata)
        showOpenImageDialog(this);
    end
    
    function onOpenDemoImage(this, hObject, eventdata) %#ok<MANU>
        
        demoName = get(hObject, 'UserData');
        switch demoName
            case 'brainMRI'
                metadata = analyze75info('brainMRI.hdr');
                img = analyze75read(metadata);
                Slicer(img, ...
                    'spacing', [1 1 2.5], ...
                    'name', 'Brain', ...
                    'displayRange', [0 90]);
                
            case 'unitBall'
                lx = linspace(-1, 1, 101);
                [x y z] = meshgrid(lx, lx, lx);
                dist = sqrt(max(1 - (x.^2 + y.^2 + z.^2), 0));
                Slicer(dist, ...
                    'origin', [-1 -1 -1], ...
                    'spacing', [.02 .02 .02], ...
                    'name', 'Unit Ball');
                
            otherwise
                error(['Unknown demo image: ' demoName]);
        end
    end
    
    function onImportRawData(this, hObject, eventdata)
        [fileName, pathName] = uigetfile( ...
       {'*.raw', 'Raw data file(*.raw)'; ...
        '*.*',   'All Files (*.*)'}, ...
        'Import Raw Data', ...
        this.lastPath);
        
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end
        
        importRawDataImage(this, fileName);
    end
    
    function showOpenImageDialog(this, hObject, eventdata)
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
            this.lastPath);
        
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end

        % open a new Slicer with the specified file
        Slicer(fullfile(pathName, fileName));
        
    end
    
    function onImportFromWorkspace(this, hObject, eventdata) %#ok<MANU>
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
        
        if ndims(data) < 3
            errordlg('Input Image must have at least 3 dimensions');
            return;
        end
        
        Slicer(data, 'name', answer{1});
    end
    
    
    function onSaveImage(this, hObject, eventdata)
        % Display the dialog, determines image type, and save image 
        % accordingly

        if isempty(this.imageData)
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
            this.lastPath);
        
        % if user cancel, quit dialog
        if isequal(fileName,0) || isequal(pathName,0)
            return;
        end

        % if no extension is specified, put another one
        [path baseName ext] = fileparts(fileName); %#ok<ASGLU>
        if isempty(ext)
            filterExtensions = {'.mhd', '.tif', '.dcm', '.mhd'};
            fileName = [fileName filterExtensions{filterIndex}];
        end

        % create full file name
        fullName = fullfile(pathName, fileName);
        
        % save image data
        [path baseName ext] = fileparts(fileName); %#ok<ASGLU>
        switch (ext)
            case {'.mha', '.mhd'}
                metaImageWrite(this.imageData, fullName);
                
            case {'.tif', '.tiff'}
                savestack(this.imageData, fullName);
                
            case '.dcm'
                dicomwrite(this.imageData, fullName);
    
            otherwise
                error(['Non supported File Format: ' ext]);
        end
    end

    function onExportToWorkspace(this, hObject, eventdata)
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
        
        assignin('base', answer{1}, this.imageData);
    end
 
end


%% Callbacks for menu Image
methods
    function onChangeResolution(this, varargin)
        
        if isempty(this.imageData)
            return;
        end
        
        % configure dialog
        spacing = this.voxelSize;
        prompt = {...
            'Voxel size in X direction:', ...
            'Voxel size in Y direction:', ...
            'Voxel size in Z direction:', ...
            'Unit name:'};
        title = 'Image resolution';
        defaultValues = [cellstr(num2str(spacing'))' {this.voxelSizeUnit}];
        
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
        this.voxelSize = spacing;
        this.voxelSizeUnit = answer{4};
        
        updateCalibrationFlag(this);
        
        % re-display the image
        this.displayNewImage();
        this.updateTitle();
    end
    
    function onChangeImageOrigin(this, varargin)
        
        if isempty(this.imageData)
            return;
        end
        
        % configure dialog
        origin = this.voxelOrigin;
        prompt = {...
            'Image origin in X direction:', ...
            'Image origin in Y direction:', ...
            'Image origin in Z direction:'};
        title = 'Change Image origin';
        defaultValues = [cellstr(num2str(origin'))' {this.voxelSizeUnit}];
        
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
        this.voxelOrigin = origin;
        updateCalibrationFlag(this);
        
        % re-display the image
        this.displayNewImage();
        this.updateTitle();
    end
    
    function updateCalibrationFlag(this)
        this.calibrated = ...
            sum(this.voxelSize ~= 1) > 0 || ...
            sum(this.voxelOrigin ~= 1) > 0 || ...
            ~isempty(this.voxelSizeUnit);
    end
    
    function onConvertColorToGray(this, hObject, eventData)
        % convert RGB image to grayscale
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is color
        if ~strcmp(this.imageType, 'color')
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
            coefs(1), this.imageData(:,:,1,:), ...
            coefs(2), this.imageData(:,:,2,:), ...
            coefs(3), this.imageData(:,:,3,:)));
        createNewSlicer(this, newData, this.imageName);
    end
    
    function onConvertIntensityToColor(this, hObject, eventData)
        % convert grayscale to RGB using current colormap
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~ismember(this.imageType, {'grayscale', 'intensity'})
            return;
        end
        
        % choose the colormap
        cmap = this.colorMap;
        if isempty(cmap)
            cmap = gray(max(this.imageData(:)));
        end
        
        % convert inner image data
        newData = uint8(double2rgb(this.imageData, ...
            cmap, this.displayRange, this.bgColor) * 255);
        createNewSlicer(this, newData, this.imageName);
    end
    
    function onConvertLabelsToColor(this, hObject, eventData)
        % convert grayscale to RGB using current colormap
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is label
        if ~ismember(this.imageType, {'label', 'binary'})
            return;
        end
        
        % choose the colormap
        cmap = this.colorMap;
        if isempty(cmap)
            cmap = jet(256);
        end
        
        % colormap has 256 entries, we need only a subset
        nLabels = max(this.imageData(:));
        inds = round(linspace(1, 256, nLabels));
        cmap = cmap(inds, :);
        
        % convert inner image data
        newData = label2rgb3d(this.imageData, cmap, this.bgColor, 'shuffle');
        createNewSlicer(this, newData, this.imageName);
    end

    function onChangeImageType(this, hObject, eventData)
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~ismember(this.imageType, {'grayscale', 'binary', 'label', 'intensity'})
            return;
        end

        % convert inner data array
        newType = get(hObject, 'UserData');
        switch newType
            case 'binary'
                this.imageData = this.imageData > 0;
            case 'grayscale'
                this.imageData = uint8(this.imageData);
            case 'intensity'
                this.imageData = double(this.imageData);
            case 'label'
                maxValue = max(this.imageData(:));
                if maxValue <= 255
                    this.imageData = uint8(this.imageData);
                elseif maxValue < 2^16
                    this.imageData = uint16(this.imageData);
                end
        end
        
        % update image type
        this.imageType = newType;
        
        % update display range
        [mini maxi] = computeGrayScaleExtent(this);
        this.displayRange  = [mini maxi];

        % update display
        setupMenuBar(this);
        updateSlice(this);
        displayNewImage(this);
        updateColorMap(this);
        updateTitle(this);
    end

    function onChangeDataType(this, hObject, eventData)
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(this.imageType, 'grayscale')
            return;
        end

        % convert inner data array
        newType = get(hObject, 'UserData');
        switch newType
            case 'binary'
                this.imageData = this.imageData > 0;
            case 'gray8'
                this.imageData = uint8(this.imageData);
            case 'gray16'
                this.imageData = uint16(this.imageData);
            case 'double'
                this.imageData = double(this.imageData);
        end
        
        % update display range
        [mini maxi] = computeGrayScaleExtent(this);
        this.displayRange  = [mini maxi];

        % update display
        updateSlice(this);
        displayNewImage(this);
        updateTitle(this);
    end
    
    function onSplitRGB(this, hObject, eventdata) 
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(this.imageType, 'color')
            return;
        end
        
        createNewSlicer(this, squeeze(this.imageData(:,:,1,:)), ...
            [this.imageName '-red']);
        createNewSlicer(this, squeeze(this.imageData(:,:,2,:)), ...
            [this.imageName '-green']);
        createNewSlicer(this, squeeze(this.imageData(:,:,3,:)), ...
            [this.imageName '-blue']);
    end
    
    
    function onFlipImage(this, hObject, eventdata)
        
        if isempty(this.imageData)
            return;
        end
        
        dim = get(hObject, 'UserData');
        this.imageData = flipdim(this.imageData, dim);
        this.updateSlice;
        this.displayNewImage;
    end
        
    function onRotateImage(this, hObject, eventdata)
        % Rotate an image by 90 degrees along x, y or z axis.
        % Axis ID and number of 90 degrees rotations are given by user data
        % of the calling menu
        
        if isempty(this.imageData)
            return;
        end
                
        data = get(hObject, 'UserData');
        this.rotateImage(data(1), data(2));
    end

    function onCropImage(this, hObject, eventdata)
        % Crop the 3D image.
        % Opens a dialog, that choose options, then create new slicer
        % object with cropped image.

        if isempty(this.imageData)
            return;
        end
         
        CropStackDialog(this);
    end
    
    
    function onDisplayImageInfo(this, varargin)
        % hObject    handle to itemDisplayImageInfo (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        if isempty(this.imageData)
            errordlg('No image loaded', 'Image Error', 'modal');
            return;
        end
        
        info = this.imageInfo;
        if isempty(info)
            errordlg('No meta-information defined for this image', ...
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
        if isempty(this.imageName)
            name = 'Image Metadata';
        else
            name = sprintf('MetaData for image <%s>', this.imageName);
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
    
    function onDisplayHistogram(this, varargin)

        if isempty(this.imageData)
            return;
        end
        
        % in the case of vector image, compute histogram of image norm
        img = this.imageData;
        if strcmp(this.imageType, 'vector')
            img = sqrt(sum(double(img) .^ 2, 3));
        end
        
        
        useBackground = ~strcmp(this.imageType, 'label');
        hd = SlicerHistogramDialog(img, 'useBackground', useBackground);
            
%         if strcmp(this.imageType, 'label')
%             % process label images -> do not count the zero
%             nLabels = max(this.imageData(:));
%             x = 1:nLabels;
%             hist(double(img(img > 0)), double(x));
%             xlim([0 nLabels+1]);        
%             colormap jet;
%             
%         elseif strcmp(this.imageType, 'color')
%             % process 8-bits RGB 3D image
%             
%             % compute histogram of each channel
%             h = zeros(256, 3);
%             for i = 1:3
%                 im = img(:,:,i,:);
%                 h(:, i) = hist(double(im(:)), 0:255);
%             end
%             
%             % display each color histogram as stairs, to see the 3 curves
%             hh = stairs(0:255, h);
%             set(hh(1), 'color', [1 0 0]); % red
%             set(hh(2), 'color', [0 1 0]); % green
%             set(hh(3), 'color', [0 0 1]); % blue
%             
%             xlim([0 255]);
%         
%         else
%             % Process gray-scale or vector image
%             [minimg maximg] = this.computeGrayScaleExtent();
%             x = linspace(double(minimg), double(maximg), 256);
%             hist(double(img(:)), x);
%             xlim([minimg-.5 maximg+.5]);        
%             colormap jet;
%         end
%         
%         fprintf('done\n');
        
        this.handles.subFigures = [this.handles.subFigures, hd.handles.histoFigure];
    end
    
end    

%% Callbacks for View menu
methods
    function onSetImageDisplayExtent(this, hObject, eventdata)
        % compute grayscale extent from data in image

        if isempty(this.imageData)
            return;
        end
        
        if ~ismember(this.imageType, {'grayscale', 'intensity'})
            return;
        end
        
        % extreme values in image
        minValue = min(this.imageData(isfinite(this.imageData)));
        maxValue = max(this.imageData(isfinite(this.imageData)));
        
        % avoid special degenerate cases
        if abs(maxValue - minValue) < 1e-12
            minValue = 0;
            maxValue = 1;
        end
        
        % set up range
        this.displayRange = [minValue maxValue];
        set(this.handles.imageAxis, 'CLim', this.displayRange);
    end
    
    function onSetDatatypeDisplayExtent(this, hObject, eventdata)
        % compute grayscale extent from image datatype

        if isempty(this.imageData)
            return;
        end
        
        if ~ismember(this.imageType, {'grayscale', 'intensity'})
            return;
        end
        
        mini = 0; maxi = 1;
        if isinteger(this.imageData)
            type = class(this.imageData);
            mini = intmin(type);
            maxi = intmax(type);
        end

        this.displayRange = [mini maxi];
        set(this.handles.imageAxis, 'CLim', this.displayRange);
    end
    
    function onSetManualDisplayExtent(this, hObject, eventdata)
        if isempty(this.imageData)
            return;
        end
        
        if ~ismember(this.imageType, {'grayscale', 'intensity'})
            return;
        end
        
        % get extreme values for grayscale in image
        minimg = min(this.imageData(:));
        maximg = max(this.imageData(:));
        
        % get actual value for grayscale range
        clim = get(this.handles.imageAxis, 'CLim');
        
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
        
        this.displayRange = [mini maxi];
        
        % setup appropriate grayscale for image
        set(this.handles.imageAxis, 'CLim', [mini maxi]);
        
    end
    
    function onSelectLUT(this, hObject, eventdata)
        % Change the LUT of the grayscale image, and refresh the display
        % colorMap name is specified by 'UserData' field of hObject
        
        if isempty(this.imageData)
            return;
        end
        
        cmapName = get(hObject, 'UserData');
        disp(['Change LUT to: ' cmapName]);
        
        nGrays = 256;
        if strcmp(this.imageType, 'label')
            nGrays = double(max(this.imageData(:)));
        end
        
        if strmatch(cmapName, 'gray')
            % for gray-scale, use an empty LUT
            this.colorMap = [];
            this.colorMap = gray(nGrays);
            
        elseif strmatch(cmapName, 'inverted')
            grayMax = nGrays - 1;
            this.colorMap = repmat((grayMax:-1:0)', 1, 3) / grayMax;
            
        elseif strmatch(cmapName, 'blue-gray-red')
            this.colorMap = gray(nGrays);
            this.colorMap(1,:) = [0 0 1];
            this.colorMap(end,:) = [1 0 0];
            
        elseif strmatch(cmapName, 'colorcube')
            nLabels = round(double(max(this.imageData(:))));
            map = colorcube(nLabels+2);
            % remove black and white colors
            isValidColor = sum(map==0, 2) ~= 3 & sum(map==1, 2) ~= 3;
            this.colorMap = [0 0 0; map(isValidColor, :)];
            
        elseif strmatch(cmapName, 'redLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, 2:3) = 0;
            
        elseif strmatch(cmapName, 'greenLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, [1 3]) = 0;
            
        elseif strmatch(cmapName, 'blueLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, 1:2) = 0;
            
        elseif strmatch(cmapName, 'yellowLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, 3) = 0;
            
        elseif strmatch(cmapName, 'cyanLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, 1) = 0;
            
        elseif strmatch(cmapName, 'magentaLUT')
            this.colorMap = gray(nGrays);
            this.colorMap(:, 2) = 0;
            
        else
            this.colorMap = feval(cmapName, nGrays);
        end

        updateColorMap(this);
    end
    
    function updateColorMap(this)
        % refresh the color map of current display
        
        % get current color map, or create a new one
        cmap = this.colorMap;
        if isempty(cmap)
            cmap = jet(256);
        end

        % adapt color map for label or binary images
        if strcmp(this.imageType, 'label')
            cmap = [this.bgColor; cmap(2:end,:)];
        elseif strcmp(this.imageType, 'binary')
            cmap = cmap([1 end], :);
        end
        
        colormap(this.handles.imageAxis, cmap);
        
    end
    
    function onSelectBackgroundColor(this, varargin)
        
        colorNames = {'White', 'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
        colors = [1 1 1; 0 0 0; 1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0];
        
        [ind, ok] = listdlg(...
            'PromptString', 'Background Color:',...
            'SelectionMode', 'Single',...
            'ListString', colorNames);
        if ~ok 
            return;
        end
        
        this.bgColor = colors(ind, :);
        updateColorMap(this);
    end
    
    
    function onShowOrthoPlanes(this, varargin)
        
        if isempty(this.imageData)
            return;
        end
        
        % compute display settings
        pos = ceil(this.imageSize / 2);
        spacing = this.voxelSize;
        
        % determine the LUT to use (default is empty)
        ortholut = [];
        if ~isColorStack(this.imageData) && ~isempty(this.colorMap)
            ortholut = this.colorMap;
        end
        
        % create figure with 3 orthogonal slices
        figure();
        orthoSlices(this.imageData, pos, spacing, ...
            'displayRange', this.displayRange, 'LUT', ortholut);
    end
    
    function onShowOrthoSlices3d(this, varargin)
        % Open a dialog to choose options, then display 3D orthoslices
        if isempty(this.imageData)
            return;
        end
        OrthoSlicer3dOptionsDialog(this);
    end

    function onShowLabelIsosurfaces(this, varargin)
        % Open a dialog to choose options, then display label isosurfaces
        if isempty(this.imageData)
            return;
        end
        if ~ismember(this.imageType, {'label', 'binary'})
            return;
        end
        LabelIsosurfacesOptionsDialog(this);
    end
    
    function rgb = createRGBImage(this)
        % compute a RGB stack that can be easily displayed
        
        if isempty(this.imageData)
            return;
        end
        
        if strcmp(this.imageType, 'color')
            rgb = this.imageData;
            return;
        end
        
        if ismember(this.imageType, {'grayscale', 'label', 'binary'})
            data = double(this.imageData);
            
        elseif strcmp(this.imageType, 'vector')
            data = zeros(this.imageSize);
            for i = 1:size(this.imageData, 3)
                data = data + squeeze(this.imageData(:,:,i,:)) .^ 2;
            end
            data = sqrt(data);
        end
        
        % convert to uint8, using current display range
        range = this.displayRange;
        data = uint8(255 * (data - range(1)) / (range(2) - range(1)));
        
        % eventually apply a LUT
        if ~isempty(this.colorMap)
            lutMax = max(this.colorMap(:));
            dim = this.imageSize;
            rgb = zeros([dim(2) dim(1) 3 dim(3)], 'uint8');
            
            % compute each channel
            for c = 1 : size(this.colorMap, 2)
                res = zeros(size(data));
                for i = 0:size(this.colorMap, 1)-1
                    res(data == i) = this.colorMap(i+1, c);
                end
                rgb(:,:,c,:) = uint8(res * 255 / lutMax);
            end
            
        else
            rgb = repmat(permute(data, [1 2 4 3]), [1 1 3 1]);
        end

    end
    
    function onZoomIn(this, varargin)
        if isempty(this.imageData)
            return;
        end
        
        api = iptgetapi(this.handles.scrollPanel);
        mag = api.getMagnification();
        api.setMagnification(mag * 2);
        this.updateTitle();
    end
    
    function onZoomOut(this, varargin)
        if isempty(this.imageData)
            return;
        end
        
        api = iptgetapi(this.handles.scrollPanel);
        mag = api.getMagnification();
        api.setMagnification(mag / 2);
        this.updateTitle();
    end
    
    function onZoomOne(this, varargin)
        if isempty(this.imageData)
            return;
        end
        
        api = iptgetapi(this.handles.scrollPanel);
        api.setMagnification(1);
        this.updateTitle();
    end
    
    function onZoomBest(this, varargin)
        if isempty(this.imageData)
            return;
        end
        
        api = iptgetapi(this.handles.scrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
        this.updateTitle();
    end

    function onZoomValue(this, hObject, eventData)
        % zoom to a given scale, stored in user data of calling object.
        % zoom value is given as binary power:
        % v positive ->  zoom = 2^v:1
        % v = 0      ->  zoom =   1:1
        % v negative ->  zoom = 1:2^v
        if isempty(this.imageData)
            return;
        end

        % get magnification
        mag = get(hObject, 'Userdata');
            
        % setup magnification of current view
        api = iptgetapi(this.handles.scrollPanel);
        api.setMagnification(mag);
        this.updateTitle();
    end
    
end

%% Callbacks for Help menu
methods
    function onAbout(this, varargin) %#ok<MANU>
        title = 'About Slicer';
        info = dir(which('Slicer.m'));
        message = {...
            '       3D Slicer for Matlab', ...
            ['         v ' datestr(info.datenum, 1)], ...
            '', ...
            '     Author: David Legland', ...
            ' david.legland@grignon.inra.fr ', ...
            '         (c) INRA - Cepia', ...
            '', ...
            };
        msgbox(message, title);
    end
    
end


%% GUI Items callback
methods
    function onSliceSliderChanged(this, hObject, eventdata) %#ok<*INUSD>
        if isempty(this.imageData)
            return;
        end
        
        zslice = round(get(hObject, 'Value'));
        zslice = max(get(hObject, 'Min'), min(get(hObject, 'Max'), zslice));

        updateSliceIndex(this, zslice);
    end
        
    function onSliceEditTextChanged(this, varargin)
        
        if isempty(this.imageData)
            return;
        end
        
        % get entered value for z-slice
        zslice = str2double(get(this.handles.zEdit, 'String'));
        
        % in case of wrong edit, set the string to current value of zslice
        if isnan(zslice)
            zslice = this.sliceIndex;
        end
        
        % compute slice number, inside of image bounds
        zslice = min(max(1, round(zslice)), this.imageSize(3));
        updateSliceIndex(this, zslice);
    end
    
    function updateSliceIndex(this, newIndex)
        if isempty(this.imageData)
            return;
        end
        
        this.sliceIndex = newIndex;
        
        this.updateSlice();
        
        set(this.handles.image, 'CData', this.slice);
        
        % update gui information for slider and textbox
        set(this.handles.zSlider, 'Value', newIndex);
        set(this.handles.zEdit, 'String', num2str(newIndex));

    end
    
    function updateSlice(this)
        if isempty(this.imageData)
            return;
        end
        
        index = this.sliceIndex;
        if strcmp(this.imageType, 'vector')
            % vector image
            dim = size(this.imageData);
            this.slice = zeros([dim(1) dim(2)]);
            for i = 1:dim(3)
                this.slice = this.slice + this.imageData(:,:,i,index) .^ 2;
            end
            this.slice = sqrt(this.slice);
            
%         elseif strcmp(this.imageType, 'label')
%             % label image
%             
%             % choose the colormap
%             cmap = this.colorMap;
%             if isempty(cmap)
%                 cmap = jet(256);
%             end
%             
%             % colormap has 256 entries, we need only a subset
%             nLabels = max(this.imageData(:));
%             inds = round(linspace(1, 256, nLabels));
%             cmap = cmap(inds, :);
%             
%             % extract slice of labels
%             labelSlice = stackSlice(this.imageData, 3, index);
%             rgb = label2rgb(labelSlice, cmap, this.bgColor);
%             this.slice = rgb;
            
        else
            % graycale or color image
            this.slice = stackSlice(this.imageData, 3, index);
            
        end
        
    end
    
    function updateTitle(this)
        % set up title of the figure, containing name of figure and current zoom
        
        % small checkup, because function can be called before figure was
        % initialised
        if ~isfield(this.handles, 'figure')
            return;
        end
        
        if isempty(this.imageData)
            set(this.handles.figure, 'Name', 'Slicer - No image');
            return;
        end
        
        % setup name
        if isempty(this.imageName)
            imgName = 'Unknown Image';
        else
            imgName = this.imageName;
        end
        
        % determine the type to display:
        % * data type for intensity / grayscale image
        % * type of image otherwise
        switch this.imageType
            case 'grayscale'
                type = class(this.imageData);
            otherwise
                type = this.imageType;
        end
        
        % compute image zoom
        api = iptgetapi(this.handles.scrollPanel);
        zoom = api.getMagnification();
        
        % compute new title string 
        titlePattern = 'Slicer - %s [%d x %d x %d %s] - %g:%g';
        titleString = sprintf(titlePattern, imgName, ...
            this.imageSize, type, max(1, zoom), max(1, 1/zoom));

        % display new title
        set(this.handles.figure, 'Name', titleString);
    end
end

%% Mouse management
methods
    function mouseButtonPressed(this, hObject, eventdata)
        if isempty(this.imageData)
            return;
        end
        
        point = get(this.handles.imageAxis, 'CurrentPoint');
        displayPixelCoords(this, point);
    end
    
    function mouseDragged(this, hObject, eventdata)
        if isempty(this.imageData)
            return;
        end
        point = get(this.handles.imageAxis, 'CurrentPoint');
        displayPixelCoords(this, point);
    end
    
    function mouseWheelScrolled(this, hObject, eventdata) %#ok<INUSL>
        if isempty(this.imageData)
            return;
        end
        newIndex = this.sliceIndex - eventdata.VerticalScrollCount;
        newIndex = min(max(newIndex, 1), this.imageSize(3));
        updateSliceIndex(this, newIndex);
    end
    
    function displayPixelCoords(this, point)
        if isempty(this.imageData)
            return;
        end
        
        point = point(1, 1:2);
        coord = round(pointToIndex(this, point));
        
        % control on bounds of image
        if sum(coord < 1) > 0 || sum(coord > this.imageSize(1:2)) > 0
            set(this.handles.infoPanel, 'string', '');
            return;
        end
        
        % Display coordinates of clicked point
        if this.calibrated
            % Display pixel + physical position
            locString = sprintf('(x,y) = (%d,%d) px = (%5.2f,%5.2f) %s', ...
                coord(1), coord(2), point(1), point(2), this.voxelSizeUnit);
        else
            % Display only pixel position
            locString = sprintf('(x,y) = (%d,%d) px', coord(1), coord(2));
        end
        
        % Display value of selected pixel
        if strcmp(this.imageType, 'color')
            % case of color pixel: values are red, green and blue
            rgb = this.imageData(coord(2), coord(1), :, this.sliceIndex);
            valueString = sprintf('  RGB = (%d %d %d)', ...
                rgb(1), rgb(2), rgb(3));
            
        elseif strcmp(this.imageType, 'vector')
            % case of vector image: compute norm of the pixel
            values  = this.imageData(coord(2), coord(1), :, this.sliceIndex);
            norm    = sqrt(sum(double(values(:)) .^ 2));
            valueString = sprintf('  value = %g', norm);
            
        else
            % case of a gray-scale pixel
            value = this.imageData(coord(2), coord(1), this.sliceIndex);
            if ~isfloat(value)
                valueString = sprintf('  value = %3d', value);
            else
                valueString = sprintf('  value = %g', value);
            end
        end
        
        set(this.handles.infoPanel, 'string', [locString '  ' valueString]);
    end

    function index = pointToIndex(this, point)
        % Converts coordinates of a point in physical dimension to image index
        % First element is column index, second element is row index, both are
        % given in floating point and no rounding is performed.
        spacing = this.voxelSize(1:2);
        origin  = this.voxelOrigin(1:2);
        index   = (point - origin) ./ spacing + 1;
    end

end

%% Figure Callbacks
methods
    function close(this, hObject, eventdata)
        % close the main figure, and all sub figures
        close(this.handles.figure);
    end
            
    function onScrollPanelResized(this, varargin)
        % function called when the Scroll panel has been resized
        
        if isempty(this.imageData)
            return;
        end
        
        scrollPanel = this.handles.scrollPanel;
        api = iptgetapi(scrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
        updateTitle(this);
    end
    
end % general methods

%% GUI Utilities
methods
    function setupMenuBar(this)
        % Refresh the menu bar of application main figure.
        % Some menu items may be valid or invalide depending on the current
        % image class or size
        
        hf = this.handles.figure;
        
        % remove menuitems that could already exist
        % (this is the case when the image type is changed, for example)
        children = get(hf, 'children');
        delete(children(strcmp(get(children, 'Type'), 'uimenu')));
        
        % setup some flags that will able/disable some menu items
        if ~isempty(this.imageData)
            imageFlag = 'on';
        else
            imageFlag = 'off';
        end
        if strcmp(this.imageType, 'color')
            colorFlag = 'on';
        else
            colorFlag = 'off';
        end
        if ismember(this.imageType, {'label', 'binary'})
            labelFlag = 'on';
        else
            labelFlag = 'off';
        end
        if ismember(this.imageType, {'grayscale', 'label', 'binary'})
            grayscaleFlag = 'on';
        else
            grayscaleFlag = 'off';
        end
        if ismember(this.imageType, {'grayscale', 'label', 'binary', 'intensity'})
            scalarFlag = 'on';
        else
            scalarFlag = 'off';
        end
        
        % files
        menuFiles = uimenu(hf, 'Label', '&Files');
        
        uimenu(menuFiles, ...
            'Label', '&Open...', ...
            'Accelerator', 'O', ...
            'Callback', @this.onOpenImage);
        uimenu(menuFiles, ...
            'Label', 'Import &Raw Data...', ...
            'Callback', @this.onImportRawData);
        uimenu(menuFiles, ...
            'Label', '&Import From Workspace...', ...
            'Callback', @this.onImportFromWorkspace);
        menuDemo = uimenu(menuFiles, ...
            'Label', 'Demo Images');
        uimenu(menuDemo, ...
            'Label', 'Brain MRI', ...
            'UserData', 'brainMRI', ...
            'Callback', @this.onOpenDemoImage);
        uimenu(menuDemo, ...
            'Label', 'Unit Ball', ...
            'UserData', 'unitBall', ...
            'Callback', @this.onOpenDemoImage);

        uimenu(menuFiles, ...
            'Label', '&Save Image...', ...
            'Separator', 'On', ...
            'Enable', imageFlag, ...
            'Accelerator', 'S', ...
            'Callback', @this.onSaveImage);
        uimenu(menuFiles, ...
            'Label', '&Export To Workspace...', ...
            'Enable', imageFlag, ...
            'Callback', @this.onExportToWorkspace);
        uimenu(menuFiles, ...
            'Label', '&Close', ...
            'Separator', 'On', ...
            'Accelerator', 'W', ...
            'Callback', @this.close);
        
        % Image
        menuImage = uimenu(hf, 'Label', '&Image', ...
            'Enable', imageFlag);
        
        uimenu(menuImage, ...
            'Label', 'Image &Info...', ...
            'Enable', imageFlag, ...
            'Accelerator', 'I', ...
            'Callback', @this.onDisplayImageInfo);
        uimenu(menuImage, ...
            'Label', 'Spatial &Resolution...', ...
            'Enable', imageFlag, ...
            'Callback', @this.onChangeResolution);
        uimenu(menuImage, ...
            'Label', 'Image &Origin...', ...
            'Enable', imageFlag, ...
            'Callback', @this.onChangeImageOrigin);
        
        menuChangeImageType = uimenu(menuImage, ...
            'Label', 'Change Image Type', ...
            'Enable', scalarFlag, ...
            'Separator', 'On');
        uimenu(menuChangeImageType, ...
            'Label', 'Binary', ...
            'UserData', 'binary', ...
            'Callback', @this.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Gray scale', ...
            'UserData', 'grayscale', ...
            'Callback', @this.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Intensity', ...
            'UserData', 'intensity', ...
            'Callback', @this.onChangeImageType);
        uimenu(menuChangeImageType, ...
            'Label', 'Label', ...
            'UserData', 'label', ...
            'Callback', @this.onChangeImageType);

        menuChangeGrayLevels = uimenu(menuImage, ...
            'Label', 'Change Gray levels', ...
            'Enable', grayscaleFlag);
        uimenu(menuChangeGrayLevels, ...
            'Label', '2 levels (Binary)', ...
            'UserData', 'binary', ...
            'Callback', @this.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', '8 levels (uint8)', ...
            'UserData', 'gray8', ...
            'Callback', @this.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', '16 levels (uint16)', ...
            'UserData', 'gray16', ...
            'Callback', @this.onChangeDataType);
        uimenu(menuChangeGrayLevels, ...
            'Label', 'intensity (double)', ...
            'UserData', 'double', ...
            'Callback', @this.onChangeDataType);
        
        uimenu(menuImage, ...
            'Label', 'Convert Intensity to Color', ...
            'Enable', grayscaleFlag, ...
            'Callback', @this.onConvertIntensityToColor);
        
        uimenu(menuImage, ...
            'Label', 'Convert Labels to Color', ...
            'Enable', labelFlag, ...
            'Callback', @this.onConvertLabelsToColor);
        
        uimenu(menuImage, ...
            'Label', 'RGB to Gray', ...
            'Enable', colorFlag, ...
            'Callback', @this.onConvertColorToGray);
        
        uimenu(menuImage, ...
            'Label', 'Split RGB', ...
            'Enable', colorFlag, ...
            'Callback', @this.onSplitRGB);
        
        
        % View
        menuView = uimenu(hf, 'Label', '&View', ...
            'Enable', imageFlag);
        
        % Display range menu
        displayRangeMenu = uimenu(menuView, ...
            'Label', '&Display Range', ...
            'Enable', grayscaleFlag);
        uimenu(displayRangeMenu, ...
            'Label', '&Image', ...
            'Callback', @this.onSetImageDisplayExtent);
        uimenu(displayRangeMenu, ...
            'Label', '&Data Type', ...
            'Callback', @this.onSetDatatypeDisplayExtent);
        uimenu(displayRangeMenu, ...
            'Label', '&Manual', ...
            'Callback', @this.onSetManualDisplayExtent);
        
        % LUTs menu
        menuLut = uimenu(menuView, ...
            'Label', '&Look-Up Table', ...
            'Enable', grayscaleFlag);
        uimenu(menuLut, ...
            'Label', 'Gray', ...
            'UserData', 'gray', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Inverted', ...
            'UserData', 'inverted', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Gray with Blue and Red', ...
            'UserData', 'blue-gray-red', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Jet', ...
            'UserData', 'jet', ...
            'Separator', 'On', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'HSV', ...
            'UserData', 'hsv', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Color Cube', ...
            'UserData', 'colorcube', ...
            'Callback', @this.onSelectLUT);
        uimenu(menuLut, ...
            'Label', 'Prism', ...
            'UserData', 'prism', ...
            'Callback', @this.onSelectLUT);
        
        % Matlab LUT's
        matlabLutsMenu = uimenu(menuLut, ...
            'Label', 'Matlab''s LUT', ...
            'Separator', 'On');
        uimenu(matlabLutsMenu, ...
            'Label', 'Hot', ...
            'UserData', 'hot', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Cool', ...
            'UserData', 'cool', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Spring', ...
            'UserData', 'spring', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Summer', ...
            'UserData', 'summer', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Autumn', ...
            'UserData', 'autumn', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Winter', ...
            'UserData', 'winter', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Bone', ...
            'UserData', 'bone', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Copper', ...
            'UserData', 'copper', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Pink', ...
            'UserData', 'pink', ...
            'Callback', @this.onSelectLUT);
        uimenu(matlabLutsMenu, ...
            'Label', 'Lines', ...
            'UserData', 'lines', ...
            'Callback', @this.onSelectLUT);
        
        colorLutsMenu = uimenu(menuLut, ...
            'Label', 'Simple Colors');
        uimenu(colorLutsMenu, ...
            'Label', 'Red', ...
            'UserData', 'redLUT', ...
            'Callback', @this.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Green', ...
            'UserData', 'greenLUT', ...
            'Callback', @this.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Blue', ...
            'UserData', 'blueLUT', ...
            'Callback', @this.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Yellow', ...
            'UserData', 'yellowLUT', ...
            'Callback', @this.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Cyan', ...
            'UserData', 'cyanLUT', ...
            'Callback', @this.onSelectLUT);
        uimenu(colorLutsMenu, ...
            'Label', 'Magenta', ...
            'UserData', 'magentaLUT', ...
            'Callback', @this.onSelectLUT);
        
        uimenu(menuLut, ...
            'Label', 'Background Color...', ...
            'Separator', 'On', ...
            'Callback', @this.onSelectBackgroundColor);

        
        uimenu(menuView, ...
            'Label', 'Show Ortho Slices', ...
            'Separator', 'On', ...
            'Enable', imageFlag, ...
            'Callback', @this.onShowOrthoPlanes);
        uimenu(menuView, ...
            'Label', 'Show 3D Ortho Slices', ...
            'Enable', imageFlag, ...
            'Callback', @this.onShowOrthoSlices3d);
        uimenu(menuView, ...
            'Label', 'Surface rendering', ...
            'Enable', labelFlag, ...
            'Callback', @this.onShowLabelIsosurfaces);
        
        % Zoom menu items
        uimenu(menuView, ...
            'Label', 'Zoom &In', ...
            'Separator', 'On', ...
            'Callback', @this.onZoomIn);
        uimenu(menuView, ...
            'Label', 'Zoom &Out', ...
            'Callback', @this.onZoomOut);
        uimenu(menuView, ...
            'Label', 'Zoom 1:1', ...
            'Callback', @this.onZoomOne);
        menuZoom = uimenu(menuView, ...
            'Label', 'Choose value');
        uimenu(menuView, ...
            'Label', 'Zoom &Best', ...
            'Accelerator', 'B', ...
            'Callback', @this.onZoomBest);
        uimenu(menuZoom, ...
            'Label', '10:1', ...
            'UserData', 10, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '4:1', ...
            'UserData', 4, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '2:1', ...
            'UserData', 2, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:1', ...
            'UserData', 1, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:2', ...
            'UserData', 1/2, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:4', ...
            'UserData', 1/4, ...
            'Callback', @this.onZoomValue);
        uimenu(menuZoom, ...
            'Label', '1:10', ...
            'UserData', 1/10, ...
            'Callback', @this.onZoomValue);
        
        
        % Process menu
        menuProcess = uimenu(hf, ...
            'Label', '&Process', ...
            'Enable', imageFlag);
        
        menuTransform = uimenu(menuProcess, ...
            'Label', 'Geometric &Transforms');
        uimenu(menuTransform, ...
            'Label', '&Horizontal Flip', ...
            'UserData', 2, ...
            'Callback', @this.onFlipImage);
        uimenu(menuTransform, ...
            'Label', '&Vertical Flip', ...
            'UserData', 1, ...
            'Callback', @this.onFlipImage);
        uimenu(menuTransform, ...
            'Label', 'Flip &Z', ...
            'UserData', 3, ...
            'Callback', @this.onFlipImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate &Left', ...
            'Separator', 'On', ...
            'UserData', [3 -1], ...
            'Accelerator', 'L', ...
            'Callback', @this.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate &Right', ...
            'UserData', [3 1], ...
            'Callback', @this.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate X Up', ...
            'UserData', [1 -1], ...
            'Accelerator', 'R', ...
            'Callback', @this.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate X Down', ...
            'UserData', [1 1], ...
            'Callback', @this.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate Y Left', ...
            'UserData', [2 1], ...
            'Callback', @this.onRotateImage);
        uimenu(menuTransform, ...
            'Label', 'Rotate Y Right', ...
            'UserData', [2 -1], ...
            'Callback', @this.onRotateImage);
        
        uimenu(menuProcess, ...
            'Label', 'Crop Image', ...
            'Callback', @this.onCropImage);

        uimenu(menuProcess, ...
            'Label', 'View &Histogram', ...
            'Separator', 'On', ...
            'Accelerator', 'H', ...
            'Callback', @this.onDisplayHistogram);
        
        
        % Help
        menuHelp = uimenu(hf, 'Label', '&Help');
        uimenu(menuHelp, ...
            'Label', '&About...', ...
            'Accelerator', 'A', ...
            'Callback', @this.onAbout);
    end
    
end

%% Methods for text display
methods
    function display(this)
        % display a resume of the slicer structure
       
        % determines whether empty lines should be printed or not
        if strcmp(get(0, 'FormatSpacing'), 'loose')
            emptyLine = '\n';
        else
            emptyLine = '';
        end
        
        % eventually add space
        fprintf(emptyLine);
        
        % get name to display
        objectname = inputname(1);
        if isempty(objectname)
            objectname = 'ans';
        end
        
        % display object name
        fprintf('%s = \n', objectname);
        
        fprintf(emptyLine);
        
        if isempty(this.imageData)
            fprintf('Slicer object, with no image.\n')
        else
            fprintf('Slicer object, containing a %d x %d x %d %s image.\n', ...
                this.imageSize, this.imageType);
        end
        
        % calibration information for image
        if this.calibrated
            fprintf('  Voxel spacing = [ %g %g %g ] %s\n', ...
                this.voxelSize, this.voxelSizeUnit');
            fprintf('  Image origin  = [ %g %g %g ] %s\n', ...
                this.voxelOrigin, this.voxelSizeUnit');
        end

        fprintf(emptyLine);
        
    end
end

end

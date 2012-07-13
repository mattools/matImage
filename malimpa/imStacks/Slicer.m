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
    
    % type of image. Can be one of {'grayscale', 'color', 'vector', 'none'}
    imageType;
    
    % physical size of the reference image (1-by-3 row vector)
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
    
    % Look-up table for display of uint8 images
    colorMap;
    
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
        
        this.handles = struct();
        
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
        
        % create main figure menu
        setupMenuBar(this);
        
        setupLayout(fig);
        
        this.displayNewImage();
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

        % setup calibration
        if isfield(info, 'ElementSize')
            this.voxelSize = info.('ElementSize');
        else
            isfield(info, 'ElementSpacing')
            this.voxelSize = info.('ElementSpacing');
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
        if isa(this.imageData, 'uint8')
            % use min-max values depending on image type
            mini = 0;
            maxi = 255;
            
        elseif islogical(this.imageData)
            % for binary images, the grayscale extent is defined by the type
            mini = 0;
            maxi = 1;
            
        elseif strcmp(this.imageType, 'vector')
            % case of vector image: compute max of norm
            
            dim = size(this.imageData);
            
            norm = zeros(dim([1 2 4]));
            
            for i = 1:dim(3);
                norm = norm + squeeze(this.imageData(:,:,i,:)) .^ 2;
            end
            
            mini = 0;
            maxi = sqrt(max(norm(:)));
            
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
            {'*.gif;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.hdr;*.dcm;*.mhd', ...
            'All Image Files (*.tif, *.hdr, *.dcm, *.mhd, *.bmp, *.jpg)'; ...
            '*.tif;*.tiff',             'TIF Files (*.tif, *.tiff)'; ...
            '*.bmp',                    'BMP Files (*.bmp)'; ...
            '*.hdr',                    'Mayo Analyze Files (*.hdr)'; ...
            '*.dcm',                    'DICOM Files (*.dcm)'; ...
            '*.mhd;*.mha',              'MetaImage data files (*.mha, *.mhd)'; ...
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
    
    function onConvertToGray(this, hObject, eventData)
        % convert RGB image to grayscale
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(this.imageType, 'color')
            return;
        end
        
        % compute conversion coefficients
        mat = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
        coefs = mat(1, :);

        % convert inner image data
        newData = squeeze(imlincomb(...
            coefs(1), this.imageData(:,:,1,:), ...
            coefs(2), this.imageData(:,:,2,:), ...
            coefs(3), this.imageData(:,:,3,:)));
        createNewSlicer(this, newData, this.imageName);
    end
    
    function onConvertToColor(this, hObject, eventData)
        % convert grayscale to RGB using current colormap
        
        if isempty(this.imageData)
            return;
        end
        
        % check that image is grayscale
        if ~strcmp(this.imageType, 'grayscale')
            return;
        end
        
        % convert inner image data
        newData = uint8(double2rgb(this.imageData, ...
            this.colorMap, this.displayRange, [1 1 1]) * 255);
        createNewSlicer(this, newData, this.imageName);
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
        data = get(hObject, 'UserData');
        this.rotateImage(data(1), data(2));
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
        
        h = figure;
        fprintf('Computing histogram...');
        
        % in the case of vector image, compute histogram of image norm
        img = this.imageData;
        if strcmp(this.imageType, 'vector')
            img = sqrt(sum(double(img) .^ 2, 3));
        end
        
        if ~strcmp(this.imageType, 'color')
            % Process gray-scale or vector image
            [minimg maximg] = this.computeGrayScaleExtent();
            x = linspace(double(minimg), double(maximg), 256);
            hist(double(img(:)), x);
            colormap jet;
            
        else
            % process 8-bits RGB 3D image
            
            % compute histogram of each channel
            h = zeros(256, 3);
            for i = 1:3
                im = img(:,:,i,:);
                h(:, i) = hist(double(im(:)), 0:255);
            end
            
            % display each color histogram as stairs, to see the 3 curves
            hh = stairs(0:255, h);
            set(hh(1), 'color', [1 0 0]); % red
            set(hh(2), 'color', [0 1 0]); % green
            set(hh(3), 'color', [0 0 1]); % blue
            
            minimg = 0;
            maximg = 255;
        end
        
        xlim([minimg maximg]);        
        fprintf('done\n');
        
        this.handles.subFigures = [this.handles.subFigures, h];
    end
    
end    

%% Callbacks for View menu
methods
    function onSetImageDisplayExtent(this, hObject, eventdata)
        % compute grayscale extent from data in image

        if isempty(this.imageData)
            return;
        end
        
        if ~strcmp(this.imageType, 'grayscale')
            return;
        end
        
        % extreme values in image
        minValue = min(this.imageData(isfinite(this.imageData)));
        maxValue = max(this.imageData(isfinite(this.imageData)));
        if abs(maxValue - minValue) < 1e-12
            minValue = 0;
            maxValue = 1;
        end
        this.displayRange = [minValue maxValue];
        set(this.handles.imageAxis, 'CLim', this.displayRange);
    end
    
    function onSetDatatypeDisplayExtent(this, hObject, eventdata)
        % compute grayscale extent from image datatype

        if isempty(this.imageData)
            return;
        end
        
        if ~strcmp(this.imageType, 'grayscale')
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
        
        if ~strcmp(this.imageType, 'grayscale')
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
        if strmatch(cmapName, 'gray')
            % for gray-scale, use an empty LUT
            this.colorMap = [];
            
        elseif strmatch(cmapName, 'inverted')
            this.colorMap = repmat((255:-1:0)', 1, 3) / 255;
            
        elseif strmatch(cmapName, 'blue-gray-red')
            this.colorMap = gray(nGrays);
            this.colorMap(1,:) = [0 0 1];
            this.colorMap(end,:) = [1 0 0];
            
        elseif strmatch(cmapName, 'colorcube')
            nLabels = round(max(this.imageData(:)));
            map = colorcube(double(nLabels)+2);
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
        
        colormap(this.handles.imageAxis, this.colorMap);
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
        
        if isempty(this.imageData)
            return;
        end
        
        % compute display settings
        pos = ceil(this.imageSize / 2);
        spacing = this.voxelSize;
        origin  = this.voxelOrigin;
        
        % determine the color map to use (default is empty)
        cmap = [];
        if ~isColorStack(this.imageData) && ~isempty(this.colorMap)
            cmap = this.colorMap;
        end
        
        % create figure with 3 orthogonal slices in 3D
        figure();
        OrthoSlicer3d(this.imageData, 'Position', pos, ...
            'Origin', origin, 'Spacing', spacing, ...
            'DisplayRange', this.displayRange, 'ColorMap', cmap);
        
        % compute display extent (add a 0.5 limit around each voxel)
        extent = stackExtent(this.imageSize, spacing, origin);
        
        % setup display
        axis equal;
        axis(extent);
        view(3);
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
        
        if strcmp(this.imageType, 'grayscale')
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

end

%% Callbacks for Help menu
methods
    function onAbout(this, varargin) %#ok<MANU>
        title = 'About Slicer';
        info = dir(which('Slicer.m'));
        message = {...
            '       3D Slicer for Matlab', ...
            ['         v ' datestr(info.datenum, 1) ' beta'], ...
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
        if ~strcmp(this.imageType, 'vector')
            % graycale or color image
            this.slice = stackSlice(this.imageData, 3, index);
            
        else
            % vector image
            dim = size(this.imageData);
            this.slice = zeros([dim(1) dim(2)]);
            for i = 1:dim(3)
                this.slice = this.slice + this.imageData(:,:,i,index) .^ 2;
            end
            this.slice = sqrt(this.slice);
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
            case 'color'
                type = 'color';
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
        if strcmp(this.imageType, 'grayscale')
            grayscaleFlag = 'on';
        else
            grayscaleFlag = 'off';
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
        
        menuChangeGrayLevels = uimenu(menuImage, ...
            'Label', 'Change Gray levels', ...
            'Enable', grayscaleFlag, ...
            'Separator', 'On');
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
            'Label', 'Color image from LUT', ...
            'Enable', grayscaleFlag, ...
            'Callback', @this.onConvertToColor);
        
        uimenu(menuImage, ...
            'Label', 'RGB to Gray', ...
            'Enable', colorFlag, ...
            'Callback', @this.onConvertToGray);
        
        uimenu(menuImage, ...
            'Label', 'Split RGB', ...
            'Enable', colorFlag, ...
            'Callback', @this.onSplitRGB);
        
        menuTransform = uimenu(menuImage, ...
            'Label', 'Geometric &Transforms', ...
            'Enable', imageFlag, ...
            'Separator', 'On', ...
            'Enable', 'On');
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
        
        uimenu(menuImage, ...
            'Label', 'View &Histogram', ...
            'Separator', 'On', ...
            'Accelerator', 'H', ...
            'Callback', @this.onDisplayHistogram);
        
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
        
        uimenu(menuView, ...
            'Label', 'Show Ortho Slices', ...
            'Callback', @this.onShowOrthoPlanes);
        uimenu(menuView, ...
            'Label', 'Show 3D Ortho Slices', ...
            'Callback', @this.onShowOrthoSlices3d);
        
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
        uimenu(menuView, ...
            'Label', 'Zoom &Best', ...
            'Accelerator', 'B', ...
            'Callback', @this.onZoomBest);
        
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
        
        fprintf('Slicer object, containing a %d x %d x %d %s image.\n', ...
            this.imageSize, this.imageType);
        
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

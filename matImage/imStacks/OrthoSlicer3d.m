classdef OrthoSlicer3d < handle
%ORTHOSLICER3D Display 3D interactive orthoslicer
%
%   OrthoSlicer3d(IMG)
%   Displays an interactive 3D orthoslicer of a 3D image. 
%
%   OrthoSlicer3d(..., NAME, VALUE)
%   Specifies one or more display options as name-value parameter pairs.
%   Available parameter names are:
%   'position'      the position of the slices intersection point, given in
%           pixels as a 1-by-3 row vector.
%   'spacing'       specifies the size of voxel elements. VALUE is a 1-by-3
%           row vector containing spacing in x, y and z direction.
%   'origin'        specifies coordinate of first voxel in user space
%   'displayRange'  the values of min and max gray values to display. The
%           default behaviour is to use [0 255] for uint8 images, or to
%           compute bounds such as 95% of the voxels are converted to visible
%           gray levels for other image types.
%   'colormap'      the name of the colormap used for displaying grayscale
%           values. Available values are 'jet', 'hsv', 'gray'...
%
%   Example
%   % Explore human brain MRI
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     OrthoSlicer3d(I);
%  
%   % add some setup
%     figure;
%     OrthoSlicer3d(I, 'Position', [60 40 5], 'spacing', [1 1 2.5], ...
%           'displayRange', [0 90]);
%
%   See also
%     Slicer
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

properties
    % reference image
    ImageData;
    
    % type of image. Can be one of {'grayscale', 'color', 'vector'}
    ImageType;
    
    % physical size of the reference image (1-by-3 row vector, in xyz order) 
    ImageSize;
    
    % extra info for image, such as the result of imfinfo
    ImageInfo;

    % the position of the intersection point of the three slices, as index
    % in xyz ordering
    Position;
    
    % extra info for image, such as the result of imfinfo
    ImageName;

    % used to adjust constrast of the slice
    DisplayRange;
    
    % Look-up table for display of uint8 images (default is empty)
    Lut             = '';
    
    % calibraton information for image
    VoxelOrigin     = [0 0 0];
    VoxelSize       = [1 1 1];
    VoxelSizeUnit   = '';
    
    % shortcut for avoiding many tests. Should be set to true when either
    % voxelOrigin, voxelsize or voxelSizeUnit is different from its default
    % value.
    Calibrated = false;
    
    % list of handles to the widgets
    Handles;
    
    % for managing slice dragging
    StartRay;
    StartIndex;
   
    DraggedSlice;
    SliceIndex;
end


%% Constructors
methods
    function obj = OrthoSlicer3d(img, varargin)
        
        % call parent constructor
        obj = obj@handle();
        
        obj.Handles = struct();

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
        end
        
        % convert to use dim(1)=x, dim(2)=y, dim(3)=z
        dim = dim([2 1 3]);
        obj.ImageSize = dim;
        
        % eventually compute grayscale extent
        if ~strcmp(obj.ImageType, 'color')
            [mini, maxi] = computeGrayScaleExtent(obj);
            obj.DisplayRange  = [mini maxi];
        end
        
        % default slice index is in the middle of the stack
        pos                 = ceil(dim / 2);
        obj.Position        = pos;

        
        parsesInputArguments();
        

        % handle to current figure;
        hFig = gcf();
        obj.Handles.Figure = hFig;
        
        % figure settings
        hold on;

        % display three orthogonal slices
        pos = obj.Position;
        obj.Handles.SliceYZ = createSlice3d(obj, 1, pos(1));
        obj.Handles.SliceXZ = createSlice3d(obj, 2, pos(2));
        obj.Handles.SliceXY = createSlice3d(obj, 3, pos(3));

        % set up mouse listener
        set(obj.Handles.SliceYZ, 'ButtonDownFcn', @obj.startDragging);
        set(obj.Handles.SliceXZ, 'ButtonDownFcn', @obj.startDragging);
        set(obj.Handles.SliceXY, 'ButtonDownFcn', @obj.startDragging);
        
        
        % extract spatial calibration
        spacing = obj.VoxelSize;
        origin = obj.VoxelOrigin;
        box = stackExtent(obj.ImageData, spacing, origin);
        
        % position of orthoslice center
        xPos = (pos(1) - 1) * spacing(1) + origin(1);
        yPos = (pos(2) - 1) * spacing(2) + origin(2);
        zPos = (pos(3) - 1) * spacing(3) + origin(3);
        
        % show orthogonal lines
        obj.Handles.LineX = line(...
            box(1:2), [yPos yPos], [zPos zPos], ...
            'color', 'r');
        obj.Handles.LineY = line(...
            [xPos xPos], box(3:4), [zPos zPos], ...
            'color', 'g');
        obj.Handles.LineZ = line(...
            [xPos xPos], [yPos yPos], box(5:6), ...
            'color', 'b');

        % show frames around each slice
        xmin = box(1);
        xmax = box(2);
        ymin = box(3);
        ymax = box(4);
        zmin = box(5);
        zmax = box(6);
        obj.Handles.FrameXY = line(...
            [xmin xmin xmax xmax xmin], ...
            [ymin ymax ymax ymin ymin], ...
            [zPos zPos zPos zPos zPos], ...
            'color', 'k');
        obj.Handles.FrameXZ = line(...
            [xmin xmin xmax xmax xmin], ...
            [yPos yPos yPos yPos yPos], ...
            [zmin zmax zmax zmin zmin], ...
            'color', 'k');
        obj.Handles.FrameYZ = line(...
            [xPos xPos xPos xPos xPos], ...
            [ymin ymin ymax ymax ymin], ...
            [zmin zmax zmax zmin zmin], ...
            'color', 'k');
        
        % setup display
        view([-20 30]);
        axis equal;
 
        function parsesInputArguments()
            % iterate over couples of input arguments to setup display
            while length(varargin) > 1
                param = varargin{1};
                switch lower(param)
                    case 'slice'
                        % setup initial slice
                        pos = varargin{2};
                        obj.SliceIndex = pos(1);
                        
                    case 'position'
                        % setup position of the intersection point (pixels)
                        obj.Position = varargin{2};
                        
                    % setup of image calibration    
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
                        
                    % setup display calibration
                    case 'displayrange'
                        obj.DisplayRange = varargin{2};
                    case {'colormap', 'lut'}
                        obj.Lut = varargin{2};
                        
                    otherwise
                        error(['Unknown parameter name: ' param]);
                end
                varargin(1:2) = [];
            end
        end % function parseInputArguments

    end
end


%% member functions
methods

    function hs = createSlice3d(obj, dim, index, varargin)
        %CREATESLICE3D Show a moving 3D slice of an image


        % extract the slice
        slice = stackSlice(obj.ImageData, dim, obj.Position(dim));
        
        % compute equivalent RGB image
        slice = computeSliceRGB(slice, obj.DisplayRange, obj.Lut);

        % size of the image
        siz = obj.ImageSize;

        % extract slice coordinates
        switch dim
            case 1
                % X Slice

                % compute coords of u and v
                vy = ((0:siz(2)) - .5);
                vz = ((0:siz(3)) - .5);
                [ydata, zdata] = meshgrid(vy, vz);

                % coord of slice supporting plane
                lx = 0:siz(1);
                xdata = ones(size(ydata)) * lx(index);

            case 2
                % Y Slice

                % compute coords of u and v
                vx = ((0:siz(1)) - .5);
                vz = ((0:siz(3)) - .5);
                [zdata, xdata] = meshgrid(vz, vx);

                % coord of slice supporting plane
                ly = 0:siz(2);
                ydata = ones(size(xdata)) * ly(index);

            case 3
                % Z Slice

                % compute coords of u and v
                vx = ((0:siz(1)) - .5);
                vy = ((0:siz(2)) - .5);
                [xdata, ydata] = meshgrid(vx, vy);

                % coord of slice supporting plane
                lz = 0:siz(3);
                zdata = ones(size(xdata)) * lz(index);

            otherwise
                error('Unknown stack direction');
        end
        
        % initialize transform matrix from index coords to physical coords
        dcm = diag([obj.VoxelSize 1]);
        %dcm(4, 1:3) = obj.VoxelOrigin;
        
        % transform coordinates from image reference to spatial reference
        hdata = ones(1, numel(xdata));
        trans = dcm(1:3, :) * [xdata(:)'; ydata(:)'; zdata(:)'; hdata];
        xdata(:) = trans(1,:) + obj.VoxelOrigin(1);
        ydata(:) = trans(2,:) + obj.VoxelOrigin(2);
        zdata(:) = trans(3,:) + obj.VoxelOrigin(3);


        % global parameters for surface display
        params = [{'facecolor', 'texturemap', 'edgecolor', 'none'}, varargin];

        % display voxel values in appropriate reference space
        hs = surface(xdata, ydata, zdata, slice, params{:});

        % setup user data of the slice
        data.Dim = dim;
        data.Index = index;
        set(hs, 'UserData', data);

    end

    function updateLinesPosition(obj)
        
        dim = obj.ImageSize;
        spacing = obj.VoxelSize;
        origin = obj.VoxelOrigin;
        
        xdata = (0:dim(1)) * spacing(1) + origin(1);
        ydata = (0:dim(2)) * spacing(2) + origin(2);
        zdata = (0:dim(3)) * spacing(3) + origin(3);
        
        pos = obj.Position;
        xPos = xdata(pos(1));
        yPos = ydata(pos(2));
        zPos = zdata(pos(3));
        
        % show orthogonal lines
        set(obj.Handles.LineX, 'ydata', [yPos yPos]);
        set(obj.Handles.LineX, 'zdata', [zPos zPos]);
        set(obj.Handles.LineY, 'xdata', [xPos xPos]);
        set(obj.Handles.LineY, 'zdata', [zPos zPos]);
        set(obj.Handles.LineZ, 'xdata', [xPos xPos]);
        set(obj.Handles.LineZ, 'ydata', [yPos yPos]);
    end

    function updateFramesPosition(obj)
        dim = obj.ImageSize;
        spacing = obj.VoxelSize;
        origin = obj.VoxelOrigin;
        
        xdata = (0:dim(1)) * spacing(1) + origin(1);
        ydata = (0:dim(2)) * spacing(2) + origin(2);
        zdata = (0:dim(3)) * spacing(3) + origin(3);
        
        pos = obj.Position;
        xPos = xdata(pos(1));
        yPos = ydata(pos(2));
        zPos = zdata(pos(3));

        set(obj.Handles.FrameXY, 'zdata', repmat(zPos, 1, 5));
        set(obj.Handles.FrameXZ, 'ydata', repmat(yPos, 1, 5));
        set(obj.Handles.FrameYZ, 'xdata', repmat(xPos, 1, 5));

    end
    
    function startDragging(obj, src, event) %#ok<INUSD>
        %STARTDRAGGING  One-line description here, please.
        %
    
        
        % store data for creating ray
        obj.StartRay   = get(gca, 'CurrentPoint');
        
        % find current index
        data = get(src, 'UserData');
        dim = data.Dim;
        obj.StartIndex = obj.Position(dim);
                
        obj.DraggedSlice = src;

        % set up listeners for figure object
        hFig = gcbf();
        set(hFig, 'WindowButtonMotionFcn', @obj.dragSlice);
        set(hFig, 'WindowButtonUpFcn', @obj.stopDragging);
    end

    function stopDragging(obj, src, event) %#ok<INUSD>
        %STOPDRAGGING  One-line description here, please.
        %

        % remove figure listeners
        hFig = gcbf();
        set(hFig, 'WindowButtonUpFcn', '');
        set(hFig, 'WindowButtonMotionFcn', '');

        % reset slice data
        obj.StartRay = [];
        obj.DraggedSlice = [];
        
        % update display
        drawnow;
    end


    function dragSlice(obj, src, event) %#ok<INUSD>
        %DRAGSLICE  One-line description here, please.
        %
        
        % Extract slice data
        hs      = obj.DraggedSlice;
        data    = get(hs, 'UserData');

        % basic checkup
        if isempty(obj.StartRay)
            return;
        end

        % dimension in xyz
        dim = data.Dim;

        
        % initialize transform matrix from index coords to physical coords
        dcm = diag([obj.VoxelSize 1]);
        
        % compute the ray corresponding to current slice normal
        center = (obj.Position .* obj.VoxelSize) + obj.VoxelOrigin;
        sliceNormal = [center; center+dcm(1:3, dim)'];

        % Project start ray on slice-axis
        alphastart = posProjRayOnRay(obj, obj.StartRay, sliceNormal);

        % Project current ray on slice-axis
        currentRay = get(gca, 'CurrentPoint');
        alphanow = posProjRayOnRay(obj, currentRay, sliceNormal);

        % compute difference in positions
        slicediff = alphanow - alphastart;

        index = obj.StartIndex + round(slicediff);
        index = min(max(1, index), stackSize(obj.ImageData, data.Dim));
        obj.SliceIndex = index;
        
        obj.Position(data.Dim) = index;


        % extract slice corresponding to current index
        slice = stackSlice(obj.ImageData, data.Dim, obj.SliceIndex);

        % convert to renderable RGB
        slice = computeSliceRGB(slice, obj.DisplayRange, obj.Lut);

        % setup display data
        set(hs, 'CData', slice);


        % the mesh used to render image has one element more, to enclose all pixels
        meshSize = [size(slice, 1) size(slice, 2)] + 1;

        spacing = obj.VoxelSize;
        origin = obj.VoxelOrigin;

        switch data.Dim
            case 1
                xpos = (obj.SliceIndex - 1) * spacing(1) + origin(1);
                xdata = ones(meshSize) * xpos;
                set(hs, 'xdata', xdata);
                
            case 2
                ypos = (obj.SliceIndex - 1) * spacing(2) + origin(2);
                ydata = ones(meshSize) * ypos;
                set(hs, 'ydata', ydata);
                
            case 3
                zpos = (obj.SliceIndex - 1) * spacing(3) + origin(3);
                zdata = ones(meshSize) * zpos;
                set(hs, 'zdata', zdata);
                
            otherwise
                error('Unknown stack direction');
        end

        % update display
        updateLinesPosition(obj);
        updateFramesPosition(obj);
        drawnow;
    end


    function alphabeta = computeAlphaBeta(obj, a, b, s)  %#ok<INUSL>
        dab = b - a;
        alphabeta = pinv([s'*s -s'*dab ; dab'*s -dab'*dab]) * [s'*a dab'*a]';
    end

    function pos = posProjRayOnRay(obj, ray1, ray2)  %#ok<INUSL>
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
    end
end

methods
    %% Some methods for image manipulation (should be factorized)
    function [mini, maxi] = computeGrayScaleExtent(obj)
        % compute grayscale extent of obj inner image
        
        if isempty(obj.ImageData)
            mini = 0; 
            maxi = 1;
            return;
        end
        
        % check image data type
        if isa(obj.ImageData, 'uint8')
            % use min-max values depending on image type
            mini = 0;
            maxi = 255;
            
        elseif islogical(obj.ImageData)
            % for binary images, the grayscale extent is defined by the type
            mini = 0;
            maxi = 1;
            
        elseif strcmp(obj.ImageType, 'vector')
            % case of vector image: compute max of norm
            
            dim = size(obj.ImageData);
            
            norm = zeros(dim([1 2 4]));
            
            for i = 1:dim(3)
                norm = norm + squeeze(obj.ImageData(:,:,i,:)) .^ 2;
            end
            
            mini = 0;
            maxi = sqrt(max(norm(:)));
            
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
    
end % end of image methods

%% Methods for text display
methods
    function disp(obj)
        % display a resume of the slicer structure.
       
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
        
        fprintf('OrthoSlicer3d object, containing a %d x %d x %d %s image.\n', ...
            obj.ImageSize, obj.ImageType);
        
        % calibration information for image
        if obj.Calibrated
            fprintf('  Voxel spacing = [ %g %g %g ] %s\n', ...
                obj.VoxelSize, obj.VoxelSizeUnit');
            fprintf('  Image origin  = [ %g %g %g ] %s\n', ...
                obj.VoxelOrigin, obj.VoxelSizeUnit');
        end

        fprintf(emptyLine);
        
    end
end

end
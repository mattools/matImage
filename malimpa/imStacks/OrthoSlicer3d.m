classdef OrthoSlicer3d < handle
%ORTHOSLICER3D Display 3D interactive orthoslicer
%
%   output = OrthoSlicer3d(input)
%
%   Example
%   OrthoSlicer3d
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

properties
    % reference image
    imageData;
    
    % type of image. Can be one of {'grayscale', 'color', 'vector'}
    imageType;
    
    % physical size of the reference image (1-by-3 row vector)
    imageSize;
    
    % extra info for image, such as the result of imfinfo
    imageInfo;

    % the position of the interesction point of the three slices
    position;
    
    % extra info for image, such as the result of imfinfo
    imageName;

    % used to adjust constrast of the slice
    displayRange;
    
    % Look-up table for display of uint8 images (default is empty)
    lut             = '';
    
    % calibraton information for image
    voxelOrigin     = [0 0 0];
    voxelSize       = [1 1 1];
    voxelSizeUnit   = '';
    
    % shortcut for avoiding many tests. Should be set to true when either
    % voxelOrigin, voxelsize or voxelSizeUnit is different from its default
    % value.
    calibrated = false;
    
    % list of handles to the widgets
    handles;
    
    % for managing slice dragging
    startRay;
    startIndex;
   
    draggedSlice;
    sliceIndex;
end


%% Constructors
methods
    function this = OrthoSlicer3d(img, varargin)
        
        % call parent constructor
        this = this@handle();
        
        this.handles = struct();

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
        end
        
        % convert to use dim(1)=x, dim(2)=y, dim(3)=z
        dim = dim([2 1 3]);
        this.imageSize = dim;
        
        % eventually compute grayscale extent
        if ~strcmp(this.imageType, 'color')
            [mini maxi] = computeGrayScaleExtent(this);
            this.displayRange  = [mini maxi];
        end
        
        % default slice index is in the middle of the stack
        pos                 = ceil(dim / 2);
        this.position       = pos;

        
        parsesInputArguments();
        
        

        % handle to current figure;
        hFig = gcf();
        this.handles.figure = hFig;
        
        % figure settings
        hold on;

        % display three orthogonal slices
        
        this.handles.sliceYZ = createSlice3d(this, 1, pos(1));
        this.handles.sliceXZ = createSlice3d(this, 2, pos(2));
        this.handles.sliceXY = createSlice3d(this, 3, pos(3));

        % set up mouse listener
        set(this.handles.sliceYZ, 'ButtonDownFcn', @this.startDragging);
        set(this.handles.sliceXZ, 'ButtonDownFcn', @this.startDragging);
        set(this.handles.sliceXY, 'ButtonDownFcn', @this.startDragging);
        
        
        
        % extract spatial calibration
        spacing = this.voxelSize;
        origin = this.voxelOrigin;
        box = stackExtent(this.imageData, spacing, origin);
        
        % position of orthoslice center
        xPos = (pos(1) - 1) * spacing(1) + origin(1);
        yPos = (pos(2) - 1) * spacing(2) + origin(2);
        zPos = (pos(3) - 1) * spacing(3) + origin(3);
        
        % show orthogonal lines
        this.handles.lineX = line(...
            box(1:2), [yPos yPos], [zPos zPos], ...
            'color', 'r');
        this.handles.lineY = line(...
            [xPos xPos], box(3:4), [zPos zPos], ...
            'color', 'r');
        this.handles.lineZ = line(...
            [xPos xPos], [yPos yPos], box(5:6), ...
            'color', 'r');

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
                        this.sliceIndex = pos(1);
                        
                    case 'spacing'
                        this.voxelSize = varargin{2};
                    case 'origin'
                        this.voxelOrigin = varargin{2};
                    case 'displayrange'
                        this.displayRange = varargin{2};
                    case {'colormap', 'lut'}
                        this.lut = varargin{2};
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

    function hs = createSlice3d(this, dim, index, varargin)
        %CREATESLICE3D Show a moving 3D slice of an image


        % extract the slice
        slice = stackSlice(this.imageData, dim, this.position(dim));
        
        % compute equivalent RGB image
        slice = computeSliceRGB(slice, this.displayRange, this.lut);

        % size of the image
        siz = this.imageSize;

        % extract slice coordinates
        switch dim
            case 1
                % X Slice

                % compute coords of u and v
                vy = ((0:siz(2)) - .5);
                vz = ((0:siz(3)) - .5);
                [ydata zdata] = meshgrid(vy, vz);

                % coord of slice supporting plane
                lx = 0:siz(1);
                xdata = ones(size(ydata)) * lx(index);

            case 2
                % Y Slice

                % compute coords of u and v
                vx = ((0:siz(1)) - .5);
                vz = ((0:siz(3)) - .5);
                [zdata xdata] = meshgrid(vz, vx);

                % coord of slice supporting plane
                ly = 0:siz(2);
                ydata = ones(size(xdata)) * ly(index);

            case 3
                % Z Slice

                % compute coords of u and v
                vx = ((0:siz(1)) - .5);
                vy = ((0:siz(2)) - .5);
                [xdata ydata] = meshgrid(vx, vy);

                % coord of slice supporting plane
                lz = 0:siz(3);
                zdata = ones(size(xdata)) * lz(index);

            otherwise
                error('Unknown stack direction');
        end
        
        % initialize transform matrix from index coords to physical coords
        dcm = diag([this.voxelSize 1]);
        dcm(1:3, 4) = this.voxelOrigin;
        
        % transform coordinates from image reference to spatial reference
        hdata = ones(1, numel(xdata));
        trans = dcm(1:3, :) * [xdata(:)'; ydata(:)'; zdata(:)'; hdata];
        xdata(:) = trans(1,:);
        ydata(:) = trans(2,:);
        zdata(:) = trans(3,:);


        % global parameters for surface display
        params = [{'facecolor', 'texturemap', 'edgecolor', 'none'}, varargin];

        % display voxel values in appropriate reference space
        hs = surface(xdata, ydata, zdata, slice, params{:});

        % setup user data of the slice
        data.dim = dim;
        data.index = index;
        set(hs, 'UserData', data);

    end

    function updateLinesPosition(this)
        
        dim = this.imageSize;
        spacing = this.voxelSize;
        origin = this.voxelOrigin;
        
        xdata = 0:dim(1) * spacing(1) + origin(1);
        ydata = 0:dim(2) * spacing(2) + origin(2);
        zdata = 0:dim(3) * spacing(3) + origin(3);
        
        pos = this.position;
        xPos = xdata(pos(1));
        yPos = ydata(pos(2));
        zPos = zdata(pos(3));
        
        % show orthogonal lines
        set(this.handles.lineX, 'ydata', [yPos yPos])
        set(this.handles.lineX, 'zdata', [zPos zPos]);
        set(this.handles.lineY, 'xdata', [xPos xPos])
        set(this.handles.lineY, 'zdata', [zPos zPos]);
        set(this.handles.lineZ, 'xdata', [xPos xPos])
        set(this.handles.lineZ, 'ydata', [yPos yPos])
    end

    function startDragging(this, src, event) %#ok<INUSD>
        %STARTDRAGGING  One-line description here, please.
        %
    
        
        % store data for creating ray
        this.startRay   = get(gca, 'CurrentPoint');
        
        % find current index
        data = get(src, 'UserData');
        dim = data.dim;
        this.startIndex = this.position(dim);
                
        this.draggedSlice = src;

        % set up listeners for figure object
        hFig = gcbf();
        set(hFig, 'WindowButtonMotionFcn', @this.dragSlice);
        set(hFig, 'WindowButtonUpFcn', @this.stopDragging);
    end

    function stopDragging(this, src, event) %#ok<INUSD>
        %STOPDRAGGING  One-line description here, please.
        %

        % remove figure listeners
        hFig = gcbf();
        set(hFig, 'WindowButtonUpFcn', '');
        set(hFig, 'WindowButtonMotionFcn', '');

        % reset slice data
        this.startRay = [];
        this.draggedSlice = [];
        
        % update display
        drawnow;
    end


    function dragSlice(this, src, event) %#ok<INUSD>
        %DRAGSLICE  One-line description here, please.
        %
        
        % Extract slice data
        hs      = this.draggedSlice;
        data    = get(hs, 'UserData');

        % basic checkup
        if isempty(this.startRay)
            return;
        end

        % dimension in xyz
        dim = data.dim;

        % initialize transform matrix from index coords to physical coords
        dcm = diag([this.voxelSize 1]);
        dcm(1:3, 4) = this.voxelOrigin;
        

        s = dcm(1:3, dim);

        % Project start ray on slice-axis
        a = this.startRay(1, :)';
        b = this.startRay(2, :)';

        alphabeta = computeAlphaBeta(this, a, b, s);
        alphastart = alphabeta(1);

        % Project current ray on slice-axis
        currentRay = get(gca, 'CurrentPoint');
        a = currentRay(1, :)';
        b = currentRay(2, :)';
        alphabeta = computeAlphaBeta(this, a, b, s);
        alphanow = alphabeta(1);

        % compute difference in positions
        slicediff = alphanow - alphastart;

        index = this.startIndex + round(slicediff);
        index = min(max(1, index), stackSize(this.imageData, data.dim));
        this.sliceIndex = index;
        
        this.position(data.dim) = index;


        % extract slice corresponding to current index
        slice = stackSlice(this.imageData, data.dim, this.sliceIndex);

        % convert to renderable RGB
        slice = computeSliceRGB(slice, this.displayRange, this.lut);

        % setup display data
        set(hs, 'CData', slice);


        % the mesh used to render image has one element more, to enclose all pixels
        meshSize = [size(slice, 1) size(slice, 2)] + 1;

        spacing = this.voxelSize;
        origin = this.voxelOrigin;

        switch data.dim
            case 1
                xpos = (this.sliceIndex - 1) * spacing(1) + origin(1);
                xdata = ones(meshSize) * xpos;
                set(hs, 'xdata', xdata);
                
            case 2
                ypos = (this.sliceIndex - 1) * spacing(2) + origin(2);
                ydata = ones(meshSize) * ypos;
                set(hs, 'ydata', ydata);
                
            case 3
                zpos = (this.sliceIndex - 1) * spacing(3) + origin(3);
                zdata = ones(meshSize) * zpos;
                set(hs, 'zdata', zdata);
                
            otherwise
                error('Unknown stack direction');
        end

        % update display
        updateLinesPosition(this);
        drawnow;
    end


    function alphabeta = computeAlphaBeta(this, a, b, s) %#ok<MANU>
        dab = b - a;
        alphabeta = pinv([s'*s -s'*dab ; dab'*s -dab'*dab]) * [s'*a dab'*a]';
    end

end


methods
    %% Some methods for image manipulation (should be factorized)
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
    
end % end of image methods

end
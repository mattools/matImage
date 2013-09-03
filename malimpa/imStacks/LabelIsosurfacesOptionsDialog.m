classdef LabelIsosurfacesOptionsDialog < handle
%LABELISOSURFACESOPTIONSDIALOG Open a dialog for 3D label isosurfaces
%
%   Class LabelIsosurfacesOptionsDialog
%
%   Example
%   LabelIsosurfacesOptionsDialog
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-04-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


%% Properties
properties
    parent;
    
    handles;
end % end properties


%% Constructor
methods
    function this = LabelIsosurfacesOptionsDialog(parent, varargin)
    % Constructor for LabelIsosurfacesOptionsDialog class
        
         % call parent constructor to initialize members
        this = this@handle();
        this.parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'Label Isosurfaces Options', ...
            'CloseRequestFcn', @this.close);
        this.handles.figure = fig;
            
        setupLayout(fig);
        
        function setupLayout(hf)
            % Setup layout of figure widgets
       
            pos = get(hf, 'Position');
            pos(3:4) = [200 180];
            set(hf, 'Position', pos);
            set(hf, 'Units', 'normalized');
            
            mainPanel = uiextras.VBox('Parent', hf);

            % control panel: use vertical layout
            optionsPanel = uiextras.VButtonBox('Parent', mainPanel, ...
                'ButtonSize', [150 30], ...
                'VerticalAlignment', 'Top', ...
                'HorizontalAlignment', 'Center', ...
                'Spacing', 5, 'Padding', 5);

            this.handles.rotateOx = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Rotate around X-axis', ...
                'Value', 1, ...
                'HorizontalAlignment', 'Left');

            this.handles.smooth = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Smooth', ...
                'Value', 1, ...
                'HorizontalAlignment', 'Left');
            
            this.handles.showAxisLabel = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Show axes label', ...
                'Value', 0, ...
                'HorizontalAlignment', 'Left');
            
            buttonsPanel = uiextras.HButtonBox('Parent', mainPanel, ...
                'ButtonSize', [70 30], ...
                'VerticalAlignment', 'Top', ...
                'Spacing', 5, 'Padding', 5, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            this.handles.applyButton = uicontrol('Style', 'PushButton', ...
                'Parent', buttonsPanel, ...
                'String', 'Compute', ...
                'Enable', 'on', ...
                'Callback', @this.onApplyButtonClicked);
            this.handles.closeButton = uicontrol('Style', 'PushButton', ...
                'Parent', buttonsPanel, ...
                'String', 'Close', ...
                'Callback', @this.close);
            
            mainPanel.Sizes = [-1 40];

        end
    end

end % end constructors


%% Methods
methods
    function onApplyButtonClicked(this, hObject, eventdata) %#ok<INUSD>
        
        % extract options from widgets
        rotateXAxis = get(this.handles.rotateOx, 'Value');
        smooth = get(this.handles.smooth, 'Value');
        showAxesLabel = get(this.handles.showAxisLabel, 'Value');
        
        % get image data stored in parent Slicer
        imgData = this.parent.imageData;
        imgSize = this.parent.imageSize;
        
        % avoid the case of empty image
        if isempty(imgData)
            return;
        end
        
        % eventually rotate image around X-axis
        if rotateXAxis
            imgData = stackRotate90(imgData, 'x', 1);
            imgSize = imgSize([1 3 2]);
        end
        
        % compute display settings
        spacing = this.parent.voxelSize;
        origin  = this.parent.voxelOrigin;
        
        % compute grid positions
        lx = (0:imgSize(1)-1) * spacing(1) + origin(1);
        ly = (0:imgSize(2)-1) * spacing(2) + origin(2);
        lz = (0:imgSize(3)-1) * spacing(3) + origin(3);

        if rotateXAxis
            ly = ly(end:-1:1);
        end
        
        % number of different labels
        nLabels = double(max(imgData(:)));

        % determine the color map to use (default is empty)
        cmap = [];
        if ~isColorStack(imgData) && ~isempty(this.parent.colorMap)
            cmap = this.parent.colorMap;
        end
        if isempty(cmap)
            cmap = jet(256);
        end
        
        % if colormap has 256 entries, we need only a subset
        % otherwise, we assume colormap has as many rows as the number
        % of labels.
        if size(cmap, 1) == 256
            inds = round(linspace(2, 256, nLabels));
            cmap = cmap(inds, :);
        end
        
        % create figure 
        hf = figure(); hold on;
        set(hf, 'renderer', 'opengl');
        
        % compute an isosurface for each label
        for i = 1:nLabels
            im = imgData==i;
            if ~any(im)
                continue;
            end
            
            if smooth
                im = imGaussianFilter(double(im), [5 5 5], 2);
            end
            
            % display isosurface
            p = patch(isosurface(lx, ly, lz, im, .5));
            
            % set face color
            set(p, 'FaceColor', cmap(i,:), 'EdgeColor', 'none');
        end
        
        % compute display extent (add a 0.5 limit around each voxel)
        extent = stackExtent(imgSize, spacing, origin);
        
        % setup display
        axis equal;
        axis(extent);
        view(3);
        axis('vis3d');
        
        light;
         
        if rotateXAxis
            set(gca, 'zdir', 'reverse');
        end
        
        if showAxesLabel
            xlabel('X axis');
            if rotateXAxis
                ylabel('Z Axis');
                zlabel('Y Axis');
            else
                ylabel('Y Axis');
                zlabel('Z Axis');
            end
        end
    end
    
end % end methods

%% Figure management
methods
    function close(this, varargin)
        delete(this.handles.figure);
    end
    
end

end % end classdef


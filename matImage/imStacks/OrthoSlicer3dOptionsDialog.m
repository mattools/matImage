classdef OrthoSlicer3dOptionsDialog < handle
%ORTHOSLICER3DOPTIONSDIALOG Open a dialog for 3D orthoslices display
%
%   Class OrthoSlicer3dOptionsDialog
%
%   Example
%   OrthoSlicer3dOptionsDialog
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
    function this = OrthoSlicer3dOptionsDialog(parent, varargin)
    % Constructor for OrthoSlicer3dOptionsDialog class
        
         % call parent constructor to initialize members
        this = this@handle();
        this.parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'OrthoSlicer3D Options', ...
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
                'Value', 0, ...
                'HorizontalAlignment', 'Left');

            this.handles.convertToRGB = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Convert to RGB', ...
                'Value', 0, ...
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
        
        rotateXAxis = get(this.handles.rotateOx, 'Value');
        convertToRGB = get(this.handles.convertToRGB, 'Value');
        showAxesLabel = get(this.handles.showAxisLabel, 'Value');
        
        
        imgData = this.parent.imageData;
        if isempty(imgData)
            return;
        end
        
        imgSize = this.parent.imageSize;
        
        if convertToRGB
            % choose the colormap
            cmap = this.parent.colorMap;
            if isempty(cmap)
                cmap = jet(256);
            end
        
            % if colormap has 256 entries, we need only a subset
            % otherwise, we assume colormap has as manu rows as the number
            % of labels.
            nLabels = max(imgData(:));
            if size(cmap, 1) == 256
                inds = round(linspace(2, 256, nLabels));
                cmap = cmap(inds, :);
            end
            
            % convert inner image data
            imgData = label2rgb3d(imgData, cmap, this.parent.bgColor, 'shuffle');

        end
        
        % eventually rotate image around X-axis
        if rotateXAxis
            imgData = flipStack(stackRotate90(imgData, 'x', 1), 2);
            imgSize = imgSize([1 3 2]);
        end
        
        
        % compute display settings
        pos = ceil(imgSize / 2);
        spacing = this.parent.voxelSize;
        origin  = this.parent.voxelOrigin;
        
        % determine the color map to use (default is empty)
        cmap = [];
        if ~isColorStack(imgData) && ~isempty(this.parent.colorMap)
            cmap = this.parent.colorMap;
        end
        
        % create figure with 3 orthogonal slices in 3D
        figure();
        OrthoSlicer3d(imgData, 'Position', pos, ...
            'Origin', origin, 'Spacing', spacing, ...
            'DisplayRange', this.parent.displayRange, 'ColorMap', cmap);
        
        % compute display extent (add a 0.5 limit around each voxel)
        extent = stackExtent(imgSize, spacing, origin);
        
        % setup display
        axis equal;
        axis(extent);
        view(3);
        
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


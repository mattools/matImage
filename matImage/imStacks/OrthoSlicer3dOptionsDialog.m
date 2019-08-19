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

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-04-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


%% Properties
properties
    Parent;
    
    Handles;
end % end properties


%% Constructor
methods
    function obj = OrthoSlicer3dOptionsDialog(parent, varargin)
    % Constructor for OrthoSlicer3dOptionsDialog class
        
         % call parent constructor to initialize members
        obj = obj@handle();
        obj.Parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'OrthoSlicer3D Options', ...
            'CloseRequestFcn', @obj.close);
        obj.Handles.Figure = fig;
            
        setupLayout(fig);
        
        function setupLayout(hf)
            % Setup layout of figure widgets
       
            pos = get(hf, 'Position');
            pos(3:4) = [200 180];
            set(hf, 'Position', pos);
            set(hf, 'Units', 'normalized');
            
            if verLessThan('matlab', 'R2014b')
                mainPanel = uiextras.VBox('Parent', hf);
            else
                mainPanel = uix.VBox('Parent', hf);
            end
            

            % control panel: use vertical layout
            if verLessThan('matlab', 'R2014b')
                optionsPanel = uiextras.VButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [150 30], ...
                    'VerticalAlignment', 'top', ...
                    'HorizontalAlignment', 'center', ...
                    'Spacing', 5, 'Padding', 5);
            else
                optionsPanel = uix.VButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [150 30], ...
                    'VerticalAlignment', 'top', ...
                    'HorizontalAlignment', 'center', ...
                    'Spacing', 5, 'Padding', 5);
            end
            
            obj.Handles.RotateOx = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Rotate around X-axis', ...
                'Value', 0, ...
                'HorizontalAlignment', 'Left');

            obj.Handles.ConvertToRGB = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Convert to RGB', ...
                'Value', 0, ...
                'HorizontalAlignment', 'Left');
            
            obj.Handles.ShowAxisLabel = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Show axes label', ...
                'Value', 0, ...
                'HorizontalAlignment', 'Left');
            
            if verLessThan('matlab', 'R2014b')
                buttonsPanel = uiextras.HButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [70 30], ...
                    'VerticalAlignment', 'top', ...
                    'Spacing', 5, 'Padding', 5, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            else
                buttonsPanel = uix.HButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [70 30], ...
                    'VerticalAlignment', 'top', ...
                    'Spacing', 5, 'Padding', 5, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            end
            obj.Handles.ApplyButton = uicontrol('Style', 'PushButton', ...
                'Parent', buttonsPanel, ...
                'String', 'Compute', ...
                'Enable', 'on', ...
                'Callback', @obj.onApplyButtonClicked);
            obj.Handles.CloseButton = uicontrol('Style', 'PushButton', ...
                'Parent', buttonsPanel, ...
                'String', 'Close', ...
                'Callback', @obj.close);
            
            if verLessThan('matlab', 'R2014b')
                mainPanel.Sizes = [-1 40];
            else
                mainPanel.Heights = [-1 40];
            end

        end
    end

end % end constructors


%% Methods
methods
    function onApplyButtonClicked(obj, hObject, eventdata) %#ok<INUSD>
        
        rotateXAxis = get(obj.Handles.RotateOx, 'Value');
        convertToRGB = get(obj.Handles.ConvertToRGB, 'Value');
        showAxesLabel = get(obj.Handles.ShowAxisLabel, 'Value');
        
        
        imgData = obj.Parent.ImageData;
        if isempty(imgData)
            return;
        end
        
        imgSize = obj.Parent.ImageSize;
        
        if convertToRGB
            % choose the colormap
            cmap = obj.Parent.ColorMap;
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
            imgData = label2rgb3d(imgData, cmap, obj.Parent.BgColor, 'shuffle');

        end
        
        % eventually rotate image around X-axis
        if rotateXAxis
            imgData = flipStack(stackRotate90(imgData, 'x', 1), 2);
            imgSize = imgSize([1 3 2]);
        end
        
        
        % compute display settings
        pos = ceil(imgSize / 2);
        spacing = obj.Parent.VoxelSize;
        origin  = obj.Parent.VoxelOrigin;
        
        % determine the color map to use (default is empty)
        cmap = [];
        if ~isColorStack(imgData) && ~isempty(obj.Parent.ColorMap)
            cmap = obj.Parent.ColorMap;
        end
        
        % create figure with 3 orthogonal slices in 3D
        figure();
        OrthoSlicer3d(imgData, 'Position', pos, ...
            'Origin', origin, 'Spacing', spacing, ...
            'DisplayRange', obj.Parent.DisplayRange, 'ColorMap', cmap);
        
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
    function close(obj, varargin)
        delete(obj.Handles.Figure);
    end
    
end

end % end classdef


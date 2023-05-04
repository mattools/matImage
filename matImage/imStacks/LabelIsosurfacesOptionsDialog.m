classdef LabelIsosurfacesOptionsDialog < handle
%LABELISOSURFACESOPTIONSDIALOG Open a dialog for 3D label isosurfaces
%
%   Class LabelIsosurfacesOptionsDialog
%
%   Example
%   LabelIsosurfacesOptionsDialog
%
%   See also
%     IsosurfaceOptionsDialog
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
    function obj = LabelIsosurfacesOptionsDialog(parent, varargin)
    % Constructor for LabelIsosurfacesOptionsDialog class
        
         % call parent constructor to initialize members
        obj = obj@handle();
        obj.Parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'Label Isosurfaces Options', ...
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
            
            obj.Handles.ReverseZAxis = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Reverse Z-axis', ...
                'Value', 1, ...
                'HorizontalAlignment', 'Left');

            obj.Handles.RotateOx = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Rotate around X-axis', ...
                'Value', 1, ...
                'HorizontalAlignment', 'Left');

            obj.Handles.Smooth = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Smooth', ...
                'Value', 1, ...
                'HorizontalAlignment', 'Left');
            
            obj.Handles.ShowAxisLabel = uicontrol(...
                'Style', 'checkbox', 'Parent', optionsPanel, ...
                'String', 'Show axes label', ...
                'Value', 0, ...
                'HorizontalAlignment', 'Left');
            
            % add control panel with "Compute" and "Close" buttons
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
        
        % first, disable "compute" button to avoid multiple calls
        set(obj.Handles.ApplyButton, 'enable', 'off');
        hDlg = msgbox({'Computing isosurfaces,', 'Please wait...'}, ...
            'Isosurface computing');
        
        % extract options from widgets
        reverseZAxis = get(obj.Handles.ReverseZAxis, 'Value');
        rotateXAxis = get(obj.Handles.RotateOx, 'Value');
        smooth = get(obj.Handles.Smooth, 'Value');
        showAxesLabel = get(obj.Handles.ShowAxisLabel, 'Value');
        
        % get image data stored in parent Slicer
        imgData = obj.Parent.ImageData;
        imgSize = obj.Parent.ImageSize;
        
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
        spacing = obj.Parent.VoxelSize;
        origin  = obj.Parent.VoxelOrigin;
        
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
        if ~isColorStack(imgData) && ~isempty(obj.Parent.ColorMap)
            cmap = obj.Parent.ColorMap;
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
        
        % for binary images, colormap has two entries, so we need to keep
        % the last one
        if strcmp(obj.Parent.ImageType, 'binary') && size(cmap, 1) > 1
            cmap = cmap(2,:);
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
         
        if rotateXAxis || reverseZAxis
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
        
        % re-enable "apply" button
        set(obj.Handles.ApplyButton, 'enable', 'on');
        if ishandle(hDlg)
            close(hDlg);
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


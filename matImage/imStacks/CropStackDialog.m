classdef CropStackDialog < handle
%CROPSTACKDIALOG Open a dialog for cropping 3D stacks
%
%   Class CropStackDialog
%
%   Example
%   CropStackDialog
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-07-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


%% Properties
properties
    parent;
    
    handles;
end % end properties


%% Constructor
methods
    function this = CropStackDialog(parent, varargin)
    % Constructor for CropStackDialog class
        
         % call parent constructor to initialize members
        this = this@handle();
        this.parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'Crop 3D Stack', ...
            'CloseRequestFcn', @this.close);
        this.handles.figure = fig;
            
        setupLayout(fig);
        
        function setupLayout(hf)
            % Setup layout of figure widgets
       
            pos = get(hf, 'Position');
            pos(3:4) = [200 180];
            set(hf, 'Position', pos);
            set(hf, 'Units', 'normalized');
       
            % compute background color of most widgets
            bgColor = get(0, 'defaultUicontrolBackgroundColor');
            if ispc
                bgColor = 'White';
            end
            
            
            mainPanel = uiextras.VBox('Parent', hf);

            dim = this.parent.imageSize;
            
            % Add two text boxes for bounds in X direction
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'X Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            this.handles.xminTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            this.handles.xmaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(1)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 40 40]);

            
            % Add two text boxes for bounds in y direction
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Y Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            this.handles.yminTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            this.handles.ymaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(2)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 40 40]);

            % Add two text boxes for bounds in Z direction
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Z Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            this.handles.zminTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            this.handles.zmaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(3)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 40 40]);

            mainPanel.Sizes = [40 40 40];

                                    
            controlPanel = uiextras.HButtonBox('Parent', mainPanel, ...
                'ButtonSize', [70 40], ...
                'VerticalAlignment', 'Top', ...
                'Spacing', 5, 'Padding', 5, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            this.handles.applyButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'OK', ...
                'Callback', @this.onApplyButtonClicked);

            this.handles.closeButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Close', ...
                'Callback', @this.onCloseButtonClicked);

        end
    end

end % end constructors


%% Methods
methods
    function onApplyButtonClicked(this, hObject, eventdata) %#ok<INUSD>
     
        % first check that parent application is still alive
        if ~ishandle(this.parent.handles.figure)
            errordlg('Slicer figure was closed', 'Crop Stack error', 'modal');
            close(this);
            return;
        end
        
        % extract the crop values
        xmin = str2double(get(this.handles.xminTextBox, 'String'));
        xmax = str2double(get(this.handles.xmaxTextBox, 'String'));
        ymin = str2double(get(this.handles.yminTextBox, 'String'));
        ymax = str2double(get(this.handles.ymaxTextBox, 'String'));
        zmin = str2double(get(this.handles.zminTextBox, 'String'));
        zmax = str2double(get(this.handles.zmaxTextBox, 'String'));
        
        % check values are valid numbers, otherwise retry
        if isnan(xmin) || isnan(xmax) || isnan(ymin) || isnan(ymax) || isnan(zmin) || isnan(zmax)
            errordlg('Problem in interpreting values', 'Crop Stack error', 'modal');
            return;
        end

        % ensure bounds are within image range
        dim = this.parent.imageSize;
        xmin = max(xmin, 1);
        xmax = min(xmax, dim(1));
        ymin = max(ymin, 1);
        ymax = min(ymax, dim(2));
        zmin = max(zmin, 1);
        zmax = min(zmax, dim(3));
        
        % crop the image
        box = [xmin xmax ymin ymax zmin zmax];
        img2 = cropStack(this.parent.imageData, box);
        
        % create new Slicer instance with the new image);
        if ~isempty(this.parent.imageName)
            name = [this.parent.imageName '-crop'];
        else
            name = 'cropped';
        end
        Slicer(img2, ...
            'imageType', this.parent.imageType, ...
            'name', name);
        
        close(this);
        return;
    end
    
    function onCloseButtonClicked(this, hObject, eventdata) %#ok<INUSD>
        close(this.handles.figure);
    end
end % end methods

%% Figure management
methods
    function close(this, varargin)
        delete(this.handles.figure);
    end
    
end

end % end classdef


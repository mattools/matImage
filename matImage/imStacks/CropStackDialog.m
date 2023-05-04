classdef CropStackDialog < handle
%CROPSTACKDIALOG Open a dialog for cropping 3D stacks.
%
%   Class CropStackDialog
%
%   Example
%   CropStackDialog
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-07-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


%% Properties
properties
    Parent;
    
    Handles;
end % end properties


%% Constructor
methods
    function obj = CropStackDialog(parent, varargin)
    % Constructor for CropStackDialog class
        
         % call parent constructor to initialize members
        obj = obj@handle();
        obj.Parent = parent;

        % create default figure
        fig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'On', ...
            'Name', 'Crop 3D Stack', ...
            'CloseRequestFcn', @obj.close);
        obj.Handles.Figure = fig;
            
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
            
            
            mainPanel = uix.VBox('Parent', hf);

            dim = obj.Parent.ImageSize;
            
            % Add two text boxes for bounds in X direction
            % First the line container
            hLine = uix.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'X Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            obj.Handles.XMinTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            obj.Handles.XMaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(1)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Widths', [-1 40 40]);

            
            % Add two text boxes for bounds in y direction
            % First the line container
            hLine = uix.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Y Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            obj.Handles.YMinTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            obj.Handles.YMaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(2)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Widths', [-1 40 40]);

            % Add two text boxes for bounds in Z direction
            % First the line container
            hLine = uix.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Z Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            obj.Handles.ZMinTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', '1', ...
                'BackgroundColor', bgColor);
            obj.Handles.ZMaxTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(dim(3)), ...
                'BackgroundColor', bgColor);
            % setup sizes in horizontal direction
            set(hLine, 'Widths', [-1 40 40]);

            % add control panel with two buttons
            controlPanel = uix.HButtonBox('Parent', mainPanel, ...
                'ButtonSize', [70 40], ...
                'VerticalAlignment', 'top', ...
                'Spacing', 5, 'Padding', 5, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            obj.Handles.applyButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'OK', ...
                'Callback', @obj.onApplyButtonClicked);
            obj.Handles.closeButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Close', ...
                'Callback', @obj.onCloseButtonClicked);

            set(mainPanel, 'Heights', [40 40 40 -1]);
        end
    end

end % end constructors


%% Methods
methods
    function onApplyButtonClicked(obj, hObject, eventdata) %#ok<INUSD>
     
        % first check that parent application is still alive
        if ~ishandle(obj.Parent.Handles.Figure)
            errordlg('Slicer figure was closed', 'Crop Stack error', 'modal');
            close(obj);
            return;
        end
        
        % extract the crop values
        xmin = str2double(get(obj.Handles.XMinTextBox, 'String'));
        xmax = str2double(get(obj.Handles.XMaxTextBox, 'String'));
        ymin = str2double(get(obj.Handles.YMinTextBox, 'String'));
        ymax = str2double(get(obj.Handles.YMaxTextBox, 'String'));
        zmin = str2double(get(obj.Handles.ZMinTextBox, 'String'));
        zmax = str2double(get(obj.Handles.ZMaxTextBox, 'String'));
        
        % check values are valid numbers, otherwise retry
        if isnan(xmin) || isnan(xmax) || isnan(ymin) || isnan(ymax) || isnan(zmin) || isnan(zmax)
            errordlg('Problem in interpreting values', 'Crop Stack error', 'modal');
            return;
        end

        % ensure bounds are within image range
        dim = obj.Parent.ImageSize;
        xmin = max(xmin, 1);
        xmax = min(xmax, dim(1));
        ymin = max(ymin, 1);
        ymax = min(ymax, dim(2));
        zmin = max(zmin, 1);
        zmax = min(zmax, dim(3));
        
        % crop the image
        box = [xmin xmax ymin ymax zmin zmax];
        img2 = cropStack(obj.Parent.ImageData, box);
        
        % create new Slicer instance with the new image);
        if ~isempty(obj.Parent.ImageName)
            name = [obj.Parent.ImageName '-crop'];
        else
            name = 'cropped';
        end
        Slicer(img2, ...
            'parent', obj.Parent, ...
            'name', name);
        
        close(obj);
        return;
    end
    
    function onCloseButtonClicked(obj, hObject, eventdata) %#ok<INUSD>
        close(obj.Handles.Figure);
    end
end % end methods

%% Figure management
methods
    function close(obj, varargin)
        delete(obj.Handles.Figure);
    end
    
end

end % end classdef


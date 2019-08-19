classdef SlicerHistogramDialog < handle
%SLICERHISTOGRAMDIALOG Open a dialog to setup image histogram display options
%
%   usage:
%   SlicerHistogramDialog
%   This opens a dialog with several widgets, as well as a figure that
%   displays image histogram with current settings.
%
%   Example
%     img = Image.read('cameraman.tif');
%     SlicerHistogramDialog(img)
%
%   See also
%     imHistogram, imhist
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-12-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


%% Properties
properties
    Image;
    
    % a 1-by-2 row vector 
    DataExtent = [0 255];
    
    % flag for automatically computing bin numbers
    AutoBinNumber = true;

    % number of bins to use with histogram
    BinNumber = 256;
    
    % position of histogram bins
    HistoBins = [];
    
    % the value of histogram for each bin. Either a N-by-1 or N-by-3 array.
    HistoValues = [];
    
    UseBackground = true;
    
    LogHistogram = false;
    
    DisplayType = 'bars';
    DisplayTypeList = {'bars', 'stems', 'stairs'};
    
    AutoUpdate = true;
    
    % a structure containing handles to graphical objects
    % List of items:
    % * HistoFigure
    % * HistoAxis
    % * BoundsTypeCombo
    % * MinBoundTextBox
    % * MaxBoundTextBox
    % * AutoBinNumberCheckBox
    % * BinNumberTextBox
    % * DisplayTypeCombo
    % * CountBackgroundCheckBox
    % * AutoUpdateCheckBox
    % * ApplyButton
    % * CloseButton
    Handles;
    
end % end properties


%% Constructor
methods
    function obj = SlicerHistogramDialog(img, varargin)
    % Constructor for SlicerHistogramDialog class
        
        % initialize inner variables
        obj.Image = img;
        if isa(img, 'Image')
            obj.Image = permute(img.Data, [2 1 4 3]);
        end

        if isfloat(obj.Image)
            obj.DataExtent(1, 1) = min(obj.Image(:));
            obj.DataExtent(1, 2) = max(obj.Image(:));
            obj.BinNumber = 100;
        end
        
        % parse input arguments
        while length(varargin) > 1
            
            if ~ischar(varargin{1})
                error('Requires parameter name-value pairs');
            end
            
            switch lower(varargin{1})
                case 'usebackground'
                    obj.UseBackground = varargin{2} > 0;
                otherwise
                    error(['Unknown parameter name: ' varargin{1}]);
            end
            
            varargin(1:2) = [];
        end
        
        if ~obj.UseBackground && isinteger(obj.Image)
            obj.DataExtent(1, 1) = 1;
            obj.BinNumber = obj.DataExtent(1, 2) - obj.DataExtent(1, 1) + 1;
        end
        
        % setup histogram figure
        hFig = figure(...
            'Name', 'Image Histogram', ...
            'NumberTitle', 'off');
        obj.Handles.HistoFigure = hFig;
        obj.Handles.HistoAxis = gca;

        % setup option dialog
        hDlg = figure(...
            'Name', 'Histogram Options', ...
            'unit', 'Pixels', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none');
        obj.Handles.OptionsDialog = hDlg;
        pos = get(hDlg, 'Position');
        pos(3:4) = [250 260];
        set(hDlg, 'Position', pos);
        setupDialogLayout(hDlg);

        % refresh current histogram display
        updateHistogram(obj);
        
        % put option dialog as current figure
        figure(hDlg);

       
        function setupDialogLayout(hf)
            
            % compute background color of most widgets
            bgColor = get(0, 'defaultUicontrolBackgroundColor');
            if ispc
                bgColor = 'White';
            end
           
            % control panel: use vertical layout
            if verLessThan('matlab', 'R2014b')
                mainPanel = uiextras.VButtonBox('Parent', hf, ...
                    'ButtonSize', [200 30], ...
                    'VerticalAlignment', 'top', ...
                    'Spacing', 5, 'Padding', 5, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            else
                mainPanel = uix.VButtonBox('Parent', hf, ...
                    'ButtonSize', [200 30], ...
                    'VerticalAlignment', 'top', ...
                    'Spacing', 5, 'Padding', 5, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
            end
            
            % Add a combo box for the type of histogram bounds
            % First the line container
            if verLessThan('matlab', 'R2014b')
                hLine = uiextras.HBox('Parent', mainPanel, ...
                    'Spacing', 5, 'Padding', 5);
            else                
                hLine = uix.HBox('Parent', mainPanel, ...
                    'Spacing', 5, 'Padding', 5);
            end
            
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'left');
            % Finally the control
            obj.Handles.boundsTypeCombo = uicontrol(...
                'Style', 'popupmenu', ...
                'Parent', hLine, ...
                'String', {'Auto', 'Image bounds', 'Manual'}, ...
                'Value', 1, ...
                'BackgroundColor', bgColor, ...
                'Callback',@obj.onBoundsTypeChanged);
            
            % setup sizes in horizontal direction
            if verLessThan('matlab', 'R2014b')
                set(hLine, 'Sizes', [-1 60]);
            else
                set(hLine, 'Widths', [-1 60]);
            end

            
            % Add two text boxes for manual bounds
            % First the line container
            if verLessThan('matlab', 'R2014b')
                hLine = uiextras.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            else
                hLine = uix.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            end
            
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'left');
            % Finally the controls
            obj.Handles.MinBoundTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(obj.DataExtent(1,1)), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@obj.onMinBoundChanged);
            obj.Handles.MaxBoundTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(obj.DataExtent(1,2)), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@obj.onMaxBoundChanged);
            % setup sizes in horizontal direction
            if verLessThan('matlab', 'R2014b')
                set(hLine, 'Sizes', [-1 50 50]);
            else
                set(hLine, 'Widths', [-1 50 50]);
            end
        
            % Add a check box for automatically computing the number of bins
            obj.Handles.AutoBinNumberCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Auto Bin Number', ...
                'Value', true, ...
                'Callback', @obj.onAutoBinNumberChanged);
            

            % Add a text box for the number of histogram bins
            % First the line container
            if verLessThan('matlab', 'R2014b')
                hLine = uiextras.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            else
                hLine = uix.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            end
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bin Number:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'left');
            % Finally the control
            obj.Handles.BinNumberTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(obj.BinNumber), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@obj.onBinNumberChanged);
            % setup sizes in horizontal direction
            if verLessThan('matlab', 'R2014b')
                set(hLine, 'Sizes', [-1 40]);
            else
                set(hLine, 'Widths', [-1 40]);
            end
        
            % Add a combo box for the histogram type
            % First the line container
            if verLessThan('matlab', 'R2014b')
                hLine = uiextras.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            else
                hLine = uix.HBox('Parent', mainPanel, 'Spacing', 5, 'Padding', 5);
            end
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Display Type:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'left');
            % Finally the control
            obj.Handles.DisplayTypeCombo = uicontrol(...
                'Style', 'popupmenu', ...
                'Parent', hLine, ...
                'String', obj.DisplayTypeList, ...
                'Value', 1, ...
                'BackgroundColor', bgColor, ...
                'Callback',@obj.onDisplayTypeChanged);
            % setup sizes in horizontal direction
            if verLessThan('matlab', 'R2014b')
                set(hLine, 'Sizes', [-1 60]);
            else
                set(hLine, 'Widths', [-1 60]);
            end
        
        
            % Add a check box for taking into account or not the background
            obj.Handles.countBackgroundCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Count Background', ...
                'Value', obj.UseBackground, ...
                'Callback',@obj.onCountBackgroundChanged);
            
            % Add a check box for log representation of histogram
            obj.Handles.LogHistogramCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Log Histogram', ...
                'Value', obj.LogHistogram, ...
                'Callback',@obj.onLogHistogramChanged);
            
            
            % Add an "auto update" check box
            obj.Handles.AutoUpdateCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Auto update', ...
                'Value', true, ...
                'Callback',@obj.onAutoUpdateChanged);

            % add control panel with "Apply" and "Close" buttons
            if verLessThan('matlab', 'R2014b')
                controlPanel = uiextras.HButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [70 60], ...
                    'VerticalAlignment', 'bottom', ...
                    'Spacing', 5, 'Padding', 5);
            else
                controlPanel = uix.HButtonBox('Parent', mainPanel, ...
                    'ButtonSize', [70 60], ...
                    'VerticalAlignment', 'bottom', ...
                    'Spacing', 5, 'Padding', 5);
            end
            obj.Handles.ApplyButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Apply', ...
                'Enable', 'off', ...
                'Callback', @obj.onApplyButtonClicked);

            obj.Handles.CloseButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Close', ...
                'Callback', @obj.onCloseButtonClicked);

        end % end of setup layout function
        
        
    end % end of main constructor function

end % end constructors

%% Controller methods
methods
    
    function onBoundsTypeChanged(obj, hObject, eventdata) %#ok<INUSD>
        index = get(hObject, 'Value');
        switch index
            case 1
                % automatic bounds
                if isa(obj.Image, 'uint8')
                    if obj.UseBackground
                        vmin = 0;
                    else
                        vmin = 1;
                    end
                    vmax = 255;
                else
                    vmin = min(obj.Image(:));
                    vmax = max(obj.Image(:));
                end
                obj.DataExtent(1, 1) = vmin;
                obj.DataExtent(1, 2) = vmax;
                set(obj.Handles.MinBoundTextBox, 'String', num2str(vmin));
                set(obj.Handles.MaxBoundTextBox, 'String', num2str(vmax));
                set(obj.Handles.MinBoundTextBox, 'Enable', 'off');
                set(obj.Handles.MaxBoundTextBox, 'Enable', 'off');
                
            case 2
                % image bounds
                vmin = min(obj.Image(:));
                vmax = max(obj.Image(:));
                obj.DataExtent(1, 1) = vmin;
                obj.DataExtent(1, 2) = vmax;
                set(obj.Handles.MinBoundTextBox, 'String', num2str(vmin));
                set(obj.Handles.MaxBoundTextBox, 'String', num2str(vmax));
                set(obj.Handles.MinBoundTextBox, 'Enable', 'off');
                set(obj.Handles.MaxBoundTextBox, 'Enable', 'off');
                
            case 3
                % manual bounds
                vmin = str2double(get(obj.Handles.MinBoundTextBox, 'String'));
                vmax = str2double(get(obj.Handles.MaxBoundTextBox, 'String'));
                if isnan(vmin) || isnan(vmax)
                    return;
                end
                
                obj.DataExtent(1, 1) = vmin;
                obj.DataExtent(1, 2) = vmax;
                set(obj.Handles.MinBoundTextBox, 'Enable', 'on');
                set(obj.Handles.MaxBoundTextBox, 'Enable', 'on');
                
            otherwise
        end
        
        if obj.AutoBinNumber
            recomputeBinNumber(obj);
        end
        
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onMinBoundChanged(obj, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        obj.DataExtent(1, 1) = value;
        
        if obj.AutoBinNumber
            recomputeBinNumber(obj);
        end
        
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onMaxBoundChanged(obj, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        obj.DataExtent(1, 2) = value;
        
        if obj.AutoBinNumber
            recomputeBinNumber(obj);
        end
        
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onAutoBinNumberChanged(obj, hObject, eventdata) %#ok<INUSD>
        
        obj.AutoBinNumber = get(obj.Handles.AutoBinNumberCheckBox, 'Value') > 0;
        
        if obj.AutoBinNumber
            set(obj.Handles.BinNumberTextBox, 'Enable', 'off');
            recomputeBinNumber(obj);
        else
            set(obj.Handles.BinNumberTextBox, 'Enable', 'on');
        end
        
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function recomputeBinNumber(obj)
        % recomputes the number of bins and update widgets
        if isinteger(obj.Image)
            nBins = obj.DataExtent(1, 2) - obj.DataExtent(1, 1) + 1;
        else
            nBins = 100;
        end
        obj.BinNumber = nBins;
        set(obj.Handles.BinNumberTextBox, 'String', num2str(nBins));
    end
    
    function onBinNumberChanged(obj, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        obj.BinNumber = round(value);
        
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onDisplayTypeChanged(obj, hObject, eventdata) %#ok<INUSD>
        index = get(hObject, 'Value');
        type = obj.DisplayTypeList{index};
        obj.DisplayType = type;
        
        refreshHistogramDisplay(obj);
    end
    
    function onCountBackgroundChanged(obj, hObject, eventdata) %#ok<INUSD>
        obj.UseBackground = get(hObject, 'Value');
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onLogHistogramChanged(obj, hObject, eventdata) %#ok<INUSD>
        obj.LogHistogram = get(hObject, 'Value');
        if obj.AutoUpdate
            updateHistogram(obj);
        end
    end
    
    function onAutoUpdateChanged(obj, hObject, eventdata) %#ok<INUSD>
        obj.AutoUpdate = get(hObject, 'Value');
        
        if obj.AutoUpdate
            set(obj.Handles.ApplyButton, 'Enable', 'off');
            updateHistogram(obj);
        else
            set(obj.Handles.ApplyButton, 'Enable', 'on');
        end
    end

    function onApplyButtonClicked(obj, hObject, eventdata) %#ok<INUSD>
        set(obj.Handles.ApplyButton, 'Enable', 'off');
        updateHistogram(obj);
        set(obj.Handles.ApplyButton, 'Enable', 'on');
    end
    
    function onCloseButtonClicked(obj, hObject, eventdata) %#ok<INUSD>
        close(obj.Handles.OptionsDialog);
    end
    
end

%% Methods
methods
    function updateHistogram(obj, varargin)
        % Recompute and display the histogram
                
        % recompute histogram
        [h, x] = computeHistogram(obj);
        obj.HistoBins = x;
        obj.HistoValues = h;

        % display histogram
        refreshHistogramDisplay(obj);
    end

    function refreshHistogramDisplay(obj, varargin)
        % Refresh the figure showing histogram
        
        % check that the figure still exist
        if ~ishandle(obj.Handles.HistoFigure)
            % re-create histogram figure
            hFig = figure(...
                'Name', 'Image Histogram', ...
                'NumberTitle', 'off');
            obj.Handles.HistoFigure = hFig;
            obj.Handles.HistoAxis = gca;
        end
        
        % clear figure
        figure(obj.Handles.HistoFigure);
        cla(obj.Handles.HistoAxis);
        
        if size(obj.HistoValues, 2) == 1
            displayGrayscaleHistogram(obj);
        else
            displayColorHistogram(obj);
        end
        
        % update display options
        xlim(obj.DataExtent(1,1:2) + [-.5 +.5]);
        
        % return to dialog
        figure(obj.Handles.OptionsDialog);
        
    end

    
    function displayGrayscaleHistogram(obj)
        % Display the given histogram with a style depending on local type
        
        % axis to display in
        ax = obj.Handles.HistoAxis;
        x = obj.HistoBins; 
        h = obj.HistoValues;

        % display histogram
        switch obj.DisplayType
            case 'bars'
                bar(ax, x, h, 'hist');
            case 'stems'
                stem(ax, x, h);
            case 'stairs'
                stairs(ax, x, h);
            otherwise
                error(['Could not understand display type: ' obj.DisplayType]);
        end
        
        colormap(ax, jet);
    end
    
    function displayColorHistogram(obj)
        % Display the given histogram with a style depending on local type
        
        % axis to display in
        ax = obj.Handles.HistoAxis;
        x = obj.HistoBins; 
        h = obj.HistoValues;
        
        % display histogram
        switch obj.DisplayType
            case 'bars'
                hh = bar(ax, x, h, 5, 'hist');
                % setup colors
                set(hh(1), 'EdgeColor', 'none', 'FaceColor', [1 0 0]); % red
                set(hh(2), 'EdgeColor', 'none', 'FaceColor', [0 1 0]); % green
                set(hh(3), 'EdgeColor', 'none', 'FaceColor', [0 0 1 ]); % blue
                
            case 'stems'
                hh = stem(ax, x, h);
                % setup colors
                set(hh(1), 'color', [1 0 0]); % red
                set(hh(2), 'color', [0 1 0]); % green
                set(hh(3), 'color', [0 0 1]); % blue
                
            case 'stairs'
                hh = stairs(ax, x, h);
                % setup colors
                set(hh(1), 'color', [1 0 0]); % red
                set(hh(2), 'color', [0 1 0]); % green
                set(hh(3), 'color', [0 0 1]); % blue
                
            otherwise
                error(['Could not understand display type: ' obj.DisplayType]);
        end
        
        
    end
    
    function [h, x] = computeHistogram(obj)
        
        % compute bin pos
        extent = obj.DataExtent;
        nBins = obj.BinNumber;
        x = linspace(extent(1,1), extent(1,2), nBins);
        
        % default values
        img = obj.Image;
        colorImage = false;
        
        % check special cases: color and vector
        if ndims(obj.Image) > 2 %#ok<ISMAT>
            if size(obj.Image, 3) == 3
                colorImage = true;
            else
                if ndims(obj.Image) > 3
                    % transform vector image into grayscale
                    img = sqrt(sum(double(img) .^ 2, 3));
                end
            end
        end
        
        % check ROI
        roi = [];
        if ~obj.UseBackground
            roi = img ~= 0;
            if colorImage
                roi = roi(:,:,1,:) | roi(:,:,2,:) | roi(:,:,3,:);
            end
        end
        
        % compute image histogram
        if ~colorImage
            % process 2D or 3D grayscale or vector image
            h = calcHistogram(img, x, roi)';
            
        else
            % process color image: compute histogram of each channel
            h = zeros(length(x), 3);
            if ndims(obj.Image) == 3
                % process 2D color image
                for i = 1:3
                    h(:, i) = calcHistogram(img(:,:,i), x, roi);
                end
            else
                % process 3D color image
                for i = 1:3
                    h(:, i) = calcHistogram(img(:,:,i,:), x, roi);
                end
            end
        end
        
        % eventually converts to log histogram
        if obj.LogHistogram
            h = log(h + 1);
        end
            
        function h = calcHistogram(img, x, roi)
            
            % convert bin centers to bin edges
            dx = x(2) - x(1);
            binEdges = [x - dx/2, x(end)+dx/2];

            if isempty(roi)
                % histogram of whole image
                h = histcounts(double(img(:)), binEdges);
%                 h = hist(double(img(:)), x);
            else
                % histogram constrained to ROI
                h = histcounts(double(img(roi)), binEdges);
%                 h = hist(double(img(roi)), x);
            end
        end
    end
    
end % end methods


%% Methods
methods
    function disp(varargin)
        disp('Image Histogram Dialog Object');
    end
end % end methods


end % end classdef


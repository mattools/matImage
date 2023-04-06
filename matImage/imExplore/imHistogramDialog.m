classdef imHistogramDialog < handle
%IMHISTOGRAMDIALOG Open a dialog to setup image histogram display options
%
%   usage:
%   imHistogramDialog
%   This opens a dialog with several widgets, as well as a figure that
%   displays image histogram with current settings.
%
%   Example
%     img = Image.read('cameraman.tif');
%     imHistogramDialog(img)
%
%   See also
%     imHistogram, imhist
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-12-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


%% Properties
properties
    image;
    
    % a 1-by-2 row vector 
    dataExtent = [0 255];
    
    % flag for automatically computing bin numbers
    autoBinNumber = true;

    % number of bins to use with histogram
    binNumber = 256;
    
    % position of histogram bins
    histoBins = [];
    
    % the value of histogram for each bin. Either a N-by-1 or N-by-3 array.
    histoValues = [];
    
    useBackground = true;
    
    displayType = 'bars';
    displayTypeList = {'bars', 'stems', 'stairs'};
    
    autoUpdate = true;
    
    % a structure containing handles to graphical objects
    % List of items:
    % * histoFigure
    % * histoAxis
    % * boundsTypeCombo
    % * minBoundTextBox
    % * maxBoundTextBox
    % * autoBinNumberCheckBox
    % * binNumberTextBox
    % * displayTypeCombo
    % * countBackgroundCheckBox
    % * autoUpdateCheckBox
    % * applyButton
    % * closeButton
    handles;
    
end % end properties


%% Constructor
methods
    function this = imHistogramDialog(img, varargin)
    % Constructor for imHistogramDialog class
        
        % initialize inner variables
        this.image = img;
        if isa(img, 'Image')
            this.image = permute(img.data, [2 1 4 3]);
        end

        if isfloat(this.image)
            this.dataExtent(1, 1) = min(this.image(:));
            this.dataExtent(1, 2) = max(this.image(:));
            this.binNumber = 100;
        end
        
        % parse input arguments
        while length(varargin) > 1
            
            if ~ischar(varargin{1})
                error('Requires parameter name-value pairs');
            end
            
            switch lower(varargin{1})
                case 'usebackground'
                    this.useBackground = varargin{2} > 0;
                otherwise
                    error(['Unknown parameter name: ' varargin{1}]);
            end
            
            varargin(1:2) = [];
        end
        
        if ~this.useBackground && isinteger(this.image)
            this.dataExtent(1, 1) = 1;
            this.binNumber = this.dataExtent(1, 2) - this.dataExtent(1, 1) + 1;
        end
        
        % setup histogram figure
        hFig = figure(...
            'Name', 'Image Histogram', ...
            'NumberTitle', 'off');
        this.handles.histoFigure = hFig;
        this.handles.histoAxis = gca;

        % setup option dialog
        hDlg = figure(...
            'Name', 'Histogram Options', ...
            'unit', 'Pixels', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none');
        this.handles.optionsDialog = hDlg;
        pos = get(hDlg, 'Position');
        pos(3:4) = [200 250];
        set(hDlg, 'Position', pos);
        setupDialogLayout(hDlg);

        % refresh current histogram display
        updateHistogram(this);
        
        % put option dialog as current figure
        figure(hDlg);

       
        function setupDialogLayout(hf)
            
            % compute background color of most widgets
            bgColor = get(0, 'defaultUicontrolBackgroundColor');
            if ispc
                bgColor = 'White';
            end
           
            % control panel: use vertical layout
            mainPanel = uiextras.VButtonBox('Parent', hf, ...
                'ButtonSize', [150 30], ...
                'VerticalAlignment', 'Top', ...
                'Spacing', 5, 'Padding', 5, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
                    
            % Add a combo box for the type of histogram bounds 
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the control
            this.handles.boundsTypeCombo = uicontrol(...
                'Style', 'popupmenu', ...
                'Parent', hLine, ...
                'String', {'Auto', 'Image bounds', 'Manual'}, ...
                'Value', 1, ...
                'BackgroundColor', bgColor, ...
                'Callback',@this.onBoundsTypeChanged);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 60]);

            
            % Add two text boxes for manual bounds
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bounds:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the controls
            this.handles.minBoundTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(this.dataExtent(1,1)), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@this.onMinBoundChanged);
            this.handles.maxBoundTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(this.dataExtent(1,2)), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@this.onMaxBoundChanged);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 40 40]);
        
            % Add a check box for automatically computing the number of bins
            this.handles.autoBinNumberCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Auto Bin Number', ...
                'Value', true, ...
                'Callback',@this.onAutoBinNumberChanged);
            

            % Add a text box for the number of histogram bins
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Bin Number:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the control
            this.handles.binNumberTextBox = uicontrol(...
                'Style', 'Edit', ...
                'Parent', hLine, ...
                'String', num2str(this.binNumber), ...
                'BackgroundColor', bgColor, ...
                'Enable', 'off', ...
                'Callback',@this.onBinNumberChanged);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 40]);
        
            % Add a combo box for the histogram type
            % First the line container
            hLine = uiextras.HBox('Parent', mainPanel, ...
                'Spacing', 5, 'Padding', 5);
            % Then the label
            uicontrol('Style', 'Text', ...
                'Parent', hLine, ...
                'String', 'Display Type:', ...
                'FontWeight', 'Normal', ...
                'HorizontalAlignment', 'Left');
            % Finally the control
            this.handles.displayTypeCombo = uicontrol(...
                'Style', 'popupmenu', ...
                'Parent', hLine, ...
                'String', this.displayTypeList, ...
                'Value', 1, ...
                'BackgroundColor', bgColor, ...
                'Callback',@this.onDisplayTypeChanged);
            % setup sizes in horizontal direction
            set(hLine, 'Sizes', [-1 60]);
        
        
            % Add a check box for taking into account or not the background
            this.handles.countBackgroundCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Count Background', ...
                'Value', this.useBackground, ...
                'Callback',@this.onCountBackgroundChanged);
            
            
            % Add an "auto update" check box
            this.handles.autoUpdateCheckBox = uicontrol('Style', 'CheckBox', ...
                'Parent', mainPanel, ...
                'String', 'Auto update', ...
                'Value', true, ...
                'Callback',@this.onAutoUpdateChanged);
            
                        
            controlPanel = uiextras.HButtonBox('Parent', mainPanel, ...
                'ButtonSize', [70 60], ...
                'VerticalAlignment', 'Top', ...
                'Spacing', 5, 'Padding', 5, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            this.handles.applyButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Apply', ...
                'Enable', 'off', ...
                'Callback', @this.onApplyButtonClicked);

            this.handles.closeButton = uicontrol('Style', 'PushButton', ...
                'Parent', controlPanel, ...
                'String', 'Close', ...
                'Callback', @this.onCloseButtonClicked);

        end % end of setup layout function
        
        
    end % end of main constructor function

end % end constructors

%% Controller methods
methods
    
    function onBoundsTypeChanged(this, hObject, eventdata) %#ok<INUSD>
        index = get(hObject, 'Value');
        switch index
            case 1
                % automatic bounds
                if isa(this.image, 'uint8')
                    if this.useBackground
                        vmin = 0;
                    else
                        vmin = 1;
                    end
                    vmax = 255;
                else
                    vmin = min(this.image(:));
                    vmax = max(this.image(:));
                end
                this.dataExtent(1, 1) = vmin;
                this.dataExtent(1, 2) = vmax;
                set(this.handles.minBoundTextBox, 'String', num2str(vmin));
                set(this.handles.maxBoundTextBox, 'String', num2str(vmax));
                set(this.handles.minBoundTextBox, 'Enable', 'off');
                set(this.handles.maxBoundTextBox, 'Enable', 'off');
                
            case 2
                % image bounds
                vmin = min(this.image(:));
                vmax = max(this.image(:));
                this.dataExtent(1, 1) = vmin;
                this.dataExtent(1, 2) = vmax;
                set(this.handles.minBoundTextBox, 'String', num2str(vmin));
                set(this.handles.maxBoundTextBox, 'String', num2str(vmax));
                set(this.handles.minBoundTextBox, 'Enable', 'off');
                set(this.handles.maxBoundTextBox, 'Enable', 'off');
                
            case 3
                % manual bounds
                vmin = str2double(get(this.handles.minBoundTextBox, 'String'));
                vmax = str2double(get(this.handles.maxBoundTextBox, 'String'));
                if isnan(vmin) || isnan(vmax)
                    return;
                end
                
                this.dataExtent(1, 1) = vmin;
                this.dataExtent(1, 2) = vmax;
                set(this.handles.minBoundTextBox, 'Enable', 'on');
                set(this.handles.maxBoundTextBox, 'Enable', 'on');
                
            otherwise
        end
        
        if this.autoBinNumber
            recomputeBinNumber(this);
        end
        
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function onMinBoundChanged(this, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        this.dataExtent(1, 1) = value;
        
        if this.autoBinNumber
            recomputeBinNumber(this);
        end
        
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function onMaxBoundChanged(this, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        this.dataExtent(1, 2) = value;
        
        if this.autoBinNumber
            recomputeBinNumber(this);
        end
        
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function onAutoBinNumberChanged(this, hObject, eventdata) %#ok<INUSD>
        
        this.autoBinNumber = get(this.handles.autoBinNumberCheckBox, 'Value') > 0;
        
        if this.autoBinNumber
            set(this.handles.binNumberTextBox, 'Enable', 'off');
            recomputeBinNumber(this);
        else
            set(this.handles.binNumberTextBox, 'Enable', 'on');
        end
        
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function recomputeBinNumber(this)
        % recomputes the number of bins and update widgets
        if isinteger(this.image)
            nBins = this.dataExtent(1, 2) - this.dataExtent(1, 1) + 1;
        else
            nBins = 100;
        end
        this.binNumber = nBins;
        set(this.handles.binNumberTextBox, 'String', num2str(nBins));
    end
    
    function onBinNumberChanged(this, hObject, eventdata) %#ok<INUSD>
        value = round(str2double(get(hObject, 'String')));
        if isnan(value)
            return;
        end
        
        this.binNumber = round(value);
        
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function onDisplayTypeChanged(this, hObject, eventdata) %#ok<INUSD>
        index = get(hObject, 'Value');
        type = this.displayTypeList{index};
        this.displayType = type;
        
        refreshHistogramDisplay(this);
    end
    
    function onCountBackgroundChanged(this, hObject, eventdata) %#ok<INUSD>
        this.useBackground = get(hObject, 'Value');
        if this.autoUpdate
            updateHistogram(this);
        end
    end
    
    function onAutoUpdateChanged(this, hObject, eventdata) %#ok<INUSD>
        this.autoUpdate = get(hObject, 'Value');
        
        if this.autoUpdate
            set(this.handles.applyButton, 'Enable', 'off');
            updateHistogram(this);
        else
            set(this.handles.applyButton, 'Enable', 'on');
        end
    end

    function onApplyButtonClicked(this, hObject, eventdata) %#ok<INUSD>
        set(this.handles.applyButton, 'Enable', 'off');
        updateHistogram(this);
        set(this.handles.applyButton, 'Enable', 'on');
    end
    
    function onCloseButtonClicked(this, hObject, eventdata) %#ok<INUSD>
        close(this.handles.optionsDialog);
    end
    
end

%% Methods
methods
    function updateHistogram(this, varargin)
        % Recompute and display the histogram
                
        % recompute histogram
        [h, x] = computeHistogram(this);
        this.histoBins = x;
        this.histoValues = h;

        % display histogram
        refreshHistogramDisplay(this);
    end

    function refreshHistogramDisplay(this, varargin)
        % Refresh the figure showing histogram
        
        % check that the figure still exist
        if ~ishandle(this.handles.histoFigure)
            % re-create histogram figure
            hFig = figure(...
                'Name', 'Image Histogram', ...
                'NumberTitle', 'off');
            this.handles.histoFigure = hFig;
            this.handles.histoAxis = gca;
        end
        
        % clear figure
        figure(this.handles.histoFigure);
        cla(this.handles.histoAxis);
        
        if size(this.histoValues, 2) == 1
            displayGrayscaleHistogram(this);
        else
            displayColorHistogram(this);
        end
        
        % update display options
        xlim(this.dataExtent(1,1:2) + [-.5 +.5]);
        
        % return to dialog
        figure(this.handles.optionsDialog);
        
    end

    
    function displayGrayscaleHistogram(this)
        % Display the given histogram with a style depending on local type
        
        % axis to display in
        ax = this.handles.histoAxis;
        x = this.histoBins; 
        h = this.histoValues;

        % display histogram
        switch this.displayType
            case 'bars'
                bar(ax, x, h, 'histc');
            case 'stems'
                stem(ax, x, h);
            case 'stairs'
                stairs(ax, x, h);
            otherwise
                error(['Could not understand display type: ' this.displayType]);
        end
        
        colormap(ax, jet);
    end
    
    function displayColorHistogram(this)
        % Display the given histogram with a style depending on local type
        
        % axis to display in
        ax = this.handles.histoAxis;
        x = this.histoBins; 
        h = this.histoValues;
        
        % display histogram
        switch this.displayType
            case 'bars'
                hh = bar(ax, x, h, 5, 'histc');
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
                error(['Could not understand display type: ' this.displayType]);
        end
        
        
    end
    
    function [h, x] = computeHistogram(this)
        
        % compute bin pos
        extent = this.dataExtent;
        nBins = this.binNumber;
        x = linspace(extent(1,1), extent(1,2), nBins);
        
        % default values
        img = this.image;
        colorImage = false;
        
        % check special cases: color and vector
        if ndims(this.image) > 2 %#ok<ISMAT>
            if size(this.image, 3) == 3
                colorImage = true;
            else
                if ndims(this.image) > 3
                    % transform vector image into grayscale
                    img = sqrt(sum(double(img) .^ 2, 3));
                end
            end
        end
        
        % check ROI
        roi = [];
        if ~this.useBackground
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
            if ndims(this.image) == 3
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
        
                
        function h = calcHistogram(img, x, roi)
            if isempty(roi)
                % histogram of whole image
                h = hist(double(img(:)), x);
            else
                % histogram constrained to ROI
                h = hist(double(img(roi)), x);
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


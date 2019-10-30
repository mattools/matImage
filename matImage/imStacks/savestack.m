function savestack(img, fname, varargin)
% Save a 3D image into a file or a series of files.
%
%   savestack(IMG, FNAME)
%   Saves the 3D image given in IMG into the file(s) given by FNAME.
%   IMG should be either a 3D array of grayscale or intensity values, or a
%   4D array of color values (coded as uint8).
%   FNAME is either a single file name, or a file name pattern that is used
%   to save the stack into a file series.
%
%   If file name contains '??', '##' or '%0xd' (x being an integer), then
%   the image is saved into a series of files, with increasing indices.
%
%   savestack(IMG, MAP, FNAME)
%   Saves a grayscale image together with a colormap. IMG should be a uint8
%   or uint16 image, and MAP should be a valid Matlab colormap (N-by-3
%   array coded as double, between 0 and 1)
%
%   savestack(..., FNAME, INDICES)
%   Also specifies number associated with each slice. Can be useful when
%   exporting a portion of a 3D stack, after a crop or a downsampling in Z
%   direction.
%
%   savestack(..., OPTIONS)
%   Uses options to write each slice. See imwrite to details.
%
%   savestack(..., VERBOSITY)
%   Also specifies verbosity. VERBOSITY can be either 'verbose' or 'quiet'.
%
%
%   Examples:
%     savestack(img, 'imgBundle.tif');        % save as stack
%     savestack(img, 'imgBundle???.tif');     % save as image series
%     savestack(img, 'imgBundle###.tif');     % save as image series
%     savestack(img, 'imgBundle%03d.tif');    % save as image series
%   
%
%   See also:
%     readstack, imwrite
%

%   ---------
%   author: David Legland, david.legland@inra.fr
%   INRA - Cepia Software Platform
%   created the 10/09/2003.
%   http://www.pfl-cepia.inra.fr/index.php?page=slicer

%   HISTORY
%   17/02/2004 change indices of slices, to start at -00 and not at -01
%   18/10/2004 adapt to save in other formats than tif, and keeping
%       possibility to specify options
%   02/01/2005 correct bug: if save a bundle TIF on existing file,
%       remove previous file.
%   01/06/2006 allow wildcard '###', ensure more portability with
%       windows, add verbosity options
%   28/11/2008 update doc, remove unused variable 'slice'
%   30/10/2019 uses TIFF lib to accelerate write time

%% Default values

% default verbosity is true
verbose = true;


%% Process input arguments

% check number of input arguments: at least two, at most five
if nargin < 1 || nargin > 5
    error('savestack requires at least two arguments, and at most 5');
end

% image size
dim = size(img);

% check if colormap is specified
map = [];
if isnumeric(fname)
    map = fname;
    if nargin < 3 
        error('Should specify file name as third input');
    end
    fname = varargin{1};
    varargin(1) = [];
end

% check for verbosity options 
if ~isempty(varargin)
    var = varargin{end};
    if ischar(var)
       if strcmp(var, 'quiet') || strcmp(var, 'silent')
            verbose = false;
            varargin = varargin{1:end-1};
       end
    end
end

% check image number of dimensions
nd = length(dim);
if nd == 3
    isGrayscale = true;
    sliceIndices = 0:dim(3)-1;
    
elseif nd == 4
    if ~isempty(map)
        error('Can not save a 4D image array with map');
    end
    isGrayscale = false;
    sliceIndices = 0:dim(4)-1;
end

% determine optional slice indices (default: 0 -> dim(3))
if ~isempty(varargin) && isnumeric(varargin{1})
    disp('use specified slice indices');
    sliceIndices = varargin{1};
    varargin(1) = [];
end



%% Compute file name pattern

% replace wildcard '??' or '???' by wildcard '%02d' or '%03d'
pos = strfind(fname, '?');
npos = length(pos);
if npos > 0
    fname = strrep(fname, repmat('?', [1 npos]), ['%0' num2str(npos) 'd']);
end

% replace wildcard '##' or '###' by wildcard '%02d' or '%03d'
pos = strfind(fname, '#');
npos = length(pos);
if npos > 0
    fname = strrep(fname, repmat('#', [1 npos]), ['%0' num2str(npos) 'd']);
end

% binary flag indicating if the stack shouldbe save as a single file, or as
% a collection of 2D slices.
saveAsStack = ~contains(fname, '%0');


%% Save image file(s)

if saveAsStack
    % save one file containing all slices of image
    if verbose
        disp('save a stack');
    end
    
    % setup TIFF tags shared by all images
    tagStruct.ImageWidth = size(img, 2);
    tagStruct.ImageLength = size(img, 1);
    if isa(img, 'uint8')
        tagStruct.BitsPerSample = 8;
    elseif isa(img, 'uint16')
        tagStruct.BitsPerSample = 16;
    else
        error(['Can not manage data with class: ' class(img)]);
    end
    if isGrayscale
        tagStruct.SamplesPerPixel = 1;
        tagStruct.Photometric = Tiff.Photometric.MinIsBlack;

        % eventually update Tag structure to understand color map
        if ~isempty(map)
            tagStruct.Photometric = Tiff.Photometric.Palette;
            tagStruct.ColorMap = map;
        end
    else
        tagStruct.SamplesPerPixel = 3;
        tagStruct.Photometric = Tiff.Photometric.RGB;
    end
    tagStruct.Compression = Tiff.Compression.PackBits;
    tagStruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagStruct.Software = 'MATLAB_MatImage';
    
    % create a TIFF file, and setup necessary tags
    t = Tiff(fname, 'w');
    setTag(t, tagStruct);
    
    if isGrayscale
        % save a grayscale stack

        % write first slice
        write(t, img(:,:,1));
        
        % append other slices
        for i = 2:dim(3)
            writeDirectory(t);
            setTag(t, tagStruct);
            write(t, img(:,:,i));
        end
        
    else
        % save a color stack

        % write first slice
        write(t, img(:,:,:,1));
        
        % append other slices
        for i = 2:dim(4)
            writeDirectory(t);
            setTag(t, tagStruct);
            write(t, img(:,:,:,i));
        end
    end
    
    close(t);
            
else
    % save a series of file, one file per slice of images
    if verbose
        disp('save slices');
    end
    
    % indentify the position of output file name that will contain indices
    pos = strfind(fname, '%0');
    pos = pos(end);
    
    % extract different parts of the file name
    basename = fname(1:pos-1);
    endname = fname(pos+4:end);
    
    % string format to compute image name
    % -> basename + indSlice + endName
    format = ['%s%0' fname(pos+2) 'd%s'];
    
    % save each slice of the image (gray-scale->3D or color->4D)
    if isGrayscale
        if isempty(map)
            % save grayscale slice images
            for i = 1:dim(3)
                index = sliceIndices(i);
                fileName = sprintf(format, basename, index, endname);
                imwrite(img(:,:,i), fileName, ...
                    'WriteMode', 'overwrite', varargin{:});
            end
        
        else
            % save grayscale slice images with colormap
            for i = 1:dim(3)
                index = sliceIndices(i);
                fileName = sprintf(format, basename, index, endname);
                imwrite(img(:,:,i), map, fileName, ...
                    'WriteMode', 'overwrite', varargin{:});
            end
        
        end
    else
        % save color slice images
        for i = 1:dim(4)
            index = sliceIndices(i);
            fileName = sprintf(format, basename, index, endname);
            imwrite(img(:,:,:,i), fileName, ...
                'WriteMode', 'overwrite', varargin{:});
        end
    end
end
    

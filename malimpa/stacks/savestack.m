function savestack(img, fname, varargin)
%SAVESTACK Save an image stack to a file or a serie of files
%
%   If file name contains '??', '##' or '%0xd' (x being an integer), then
%   the image is saved into a series of files, with increasing index.
%
%   Example :
%   savestack(img, 'imgBundle.tif');        % save as stack
%   savestack(img, 'imgBundle???.tif');     % save as image series
%   savestack(img, 'imgBundle###.tif');     % save as image series
%   savestack(img, 'imgBundle%03d.tif');    % save as image series
%   
%   savestack(..., OPTIONS)
%   use options to write each slice. See imwrite to details.
%
%   savestack(..., VERBOSITY)
%   also specify verbosity. VERBOSITY can be either 'verbose' or 'quiet'.
%
%
%   See also:
%   readstack, imwrite
%
%   ---------
%   author: David Legland, david.legland(at)grignon.inra.fr
%   INRA - Cepia Software Platform
%   created the 10/09/2003.
%   http://www.pfl-cepia.inra.fr/index.php?page=slicer
%   Licensed under the terms of the new BSD license, see file license.txt

%   HISTORY
%   17/02/2004 change indices of slices, to start at -00 and not at -01
%   18/10/2004 adapt to save in other formats than tif, and keeping
%       possibility to specify options
%   02/01/2005 correct bug: if save a bundle TIF on existing file,
%       remove previous file.
%   01/06/2006 allow wildcard '###', ensure more portability with
%       windows, add verbosity options
%   28/11/2008 update doc, remove unused variable 'slice'

% check input number
error(nargchk(1, 4, nargin));

% image size
dim = size(img);

% default verbosity is true
verbose = true;

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

pos = strfind(fname, '%0');
if ~isempty(pos)
    % save a series of file, one file per slice of images
    if verbose
        disp('save slices');
    end
    
    % keep only the last '%0xd'
    pos = pos(end);
    
    % extract different parts of the file name
    basename = fname(1:pos-1);
    endname = fname(pos+4:end);
    
    % string format to compute image name
    % -> basename + indSlice + endName
    format = ['%s%0' fname(pos+2) 'd%s'];
    
    % save each slice of the image (gray-scale->3D or color->4D)
    if length(dim) == 3
        % save grayscale slice
        for i = 1:dim(3)
            fileName = sprintf(format, basename, i-1, endname);
            imwrite(img(:,:,i), fileName, ...
                'WriteMode', 'overwrite', varargin{:});
        end
        
    else
        % save color slice
        for i = 1:dim(4)
            fileName = sprintf(format, basename, i-1, endname);
            imwrite(img(:,:,:,i), fileName, ...
                'WriteMode', 'overwrite', varargin{:});
        end
    end
    
else
    % save one file containing all slices of image
    if verbose
        disp('save a stack');
    end
    
    if length(dim) == 3
        % overwrite existing file
        imwrite(img(:,:,1), fname, varargin{:}, 'WriteMode', 'overwrite');
        
        % append other slices
        for i = 2:dim(3)
            imwrite(img(:,:,i), fname, varargin{:}, ...
                'WriteMode', 'append');
        end
    else
        % overwrite existing file
        imwrite(img(:,:,:,1), fname, varargin{:}, 'WriteMode', 'overwrite');

        % append other slices
        for i = 2:dim(4)
            imwrite(img(:,:,:,i), fname, varargin{:}, ...
                'WriteMode', 'append');
        end
    end
end
    

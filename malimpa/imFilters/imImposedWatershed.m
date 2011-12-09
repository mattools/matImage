function [wat emin] = imImposedWatershed(img, h, varargin)
%IMIMPOSEDWATERSHED Compute watershed after imposition of extended minima
%
%   RES = imImposedWatershed(IMG, H)
%   IMG is an image, and H is a threshold. The extended minima are
%   computed, superimposed on the original image, and the resulting image
%   is returned.
%
%   RES = imImposedWatershed(IMG, H, CONN)
%   Specifies the connectivity to use for each step (default is 4 for 2D
%   images, and 6 for 3D images).
%
%   RES = imImposedWatershed(..., 'verbose', true);
%   Also displays information on processing.
%
%   Example
%   imImposedWatershed
%
%   See also
%   watershed, imextendedmin, imimposemin
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-04-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% HISTORY
% 2010-09-11 fix bug in connectivity, add verbosity option


%% Default options

% determines the default connectivity, depending on image dimension
c = 4;
if ndims(img)>2
    c = 6;
end

% verbose is false by default
verbose = false;


%% Process input arguments

% check if connectivity is provided
if ~isempty(varargin)
    if isnumeric(varargin)
        c = varargin{1};
        varargin(1) = [];
    end    
end

% process optional arguments
while length(varargin)>1
    varName = varargin{1};
    if ~ischar(varName)
        error('Optional argument must be provided as param-value pairs');
    end
    if strcmpi(varName, 'verbose')
        verbose = varargin{2};
    else
        error(['Unknown option: ' varName]);
    end
    varargin(1:2) = [];
end


%% Main processing

% detection of extended minima
if verbose
    disp('Compute extended minima');
end
emin = imextendedmin(img, h, c);

% imposition of minima on the image
if verbose
    disp('Impose minima on images');
end
img = imimposemin(img, emin, c);

% computation of watershed
if verbose
    disp('Compute Watershed');
end
wat = watershed(img, c);


function [wat, emin] = imImposedWatershed(img, emin, varargin)
%IMIMPOSEDWATERSHED Compute watershed after imposition of extended minima
%
%   RES = imImposedWatershed(IMG, MARKERS)
%   IMG is an image, and MARKERS is a binary image the same size as IMG.
%   The marker image is superimposed on the original image, the watershed
%   computed, and the resulting label matrix is returned.
%
%   RES = imImposedWatershed(IMG, H)
%   Specifies the marker as a level of dynamic between minima and watershed
%   crests. The extended minima are computed using the parameter H, the
%   result is superimposed on the original image, the watershed computed,
%   and the resulting label matrix is returned.
%
%   RES = imImposedWatershed(..., CONN)
%   Specifies the connectivity to use for each step (default is 4 for 2D
%   images, and 6 for 3D images).
%
%   RES = imImposedWatershed(..., 'verbose', true);
%   Also displays information on processing.
%
%   Example
%     % Computes watershed on gradient of rice image
%     img = imread('rice.png');
%     grad = imGradient(img);
%     wat = imImposedWatershed(grad, 10, 4);
%     ovr = imOverlay(img, wat==0);
%     imshow(ovr)
%
%   See also
%   watershed, imextendedmin, imimposemin, imSeparateParticles
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-04-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% HISTORY
% 2010-09-11 fix bug in connectivity, add verbosity option
% 2012-07-24 add possibility to specify directly the markers, add doc


%% Default options

% determines the default connectivity, depending on image dimension
c = 4;
if ndims(img) > 2 %#ok<ISMAT>
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
if isscalar(emin)
    if verbose
        disp('Compute extended minima');
    end
    emin = imextendedmin(img, emin, c);
end

% imposition of minima on the image
if verbose
    disp('Impose minima on image');
end
img = imimposemin(img, emin, c);

% computation of watershed
if verbose
    disp('Compute Watershed');
end
wat = watershed(img, c);


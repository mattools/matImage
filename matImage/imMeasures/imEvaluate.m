function val = imEvaluate(img, varargin)
%IMEVALUATE  Evaluate image value at given position(s)
%
%   VAL = imEvaluate(IMG, X, Y)
%   VAL = imEvaluate(IMG, X, Y, Z)
%   Evaluates the value within the image grayscale or a color IMG at the
%   position(s) given by X, Y, and eventually Z. 
%   IMG is an array containing the image
%
%   VAL = imEvaluate(IMG, POS)
%   Specifies the position as a N-by-2 or N-by-3 array of coordinates. The
%   result VAL is a N-by-1 array of values in the case of a grayscale image
%   or a N-by-3 array in the case of a color image.
%
%   VAL = imEvaluate(..., METHOD)
%   Specifies the interpolation method to use. The same options as for the
%   'interp2' or 'interp3' functions are available: 'nearest', {'linear'},
%   'spline', 'cubic', or 'makima'. Default is 'linear'.
%
%   VAL = imEvaluate(..., METHOD, EXTRAPVAL)
%   Also specifies the value for pixels outside of the image domain.
%
%   Example
%     % plot profile of a grayscale image
%     img = imread('cameraman.tif');
%     xi = 1:200;
%     yi = 200*ones(1, 200);
%     imshow(img); hold on; plot(xi, yi, '-b');
%     vals = imEvaluate(img, [xi' yi']);
%     figure; plot(vals)
%   
%
%   See also
%   imLineProfile, interp2, interp3, improfile
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Default values

% use linear interpolation as default
method = 'linear';

% fill background with black
fillValue = 0;


%% Process input arguments

% parse coordinates
nd = ndims(img);
if isColorImage(img)
    nd = nd - 1;
end
[point, dim, varargin] = mergeCoordinates(varargin{:});

% parse interpolation method
if ~isempty(varargin) && ischar(varargin{1})
    method = varargin{1};
    varargin(1) = [];
end

% use fast interpolation, because images are monotonic
if ischar(method) && method(1) ~= '*'
    method = ['*' method];
end

% parse background value
if ~isempty(varargin)
    fillValue = varargin{1};
end
    

%% Initialisations

% number of values to interpolate
nv = size(point, 1);

% number of image channels
nc = 1;
if isColorImage(img)
    nc = size(img, 3);
    
    if isscalar(fillValue)
        fillValue = repmat(fillValue, 3, 1);
    end
end

% allocate memory for result
val = zeros(nv, nc, class(img));



%% Compute interpolation

if nd == 2
    % planar case
    x = 1:size(img, 2);
    y = 1:size(img, 1);
    
    if nc == 1
        % planar grayscale
        val = interp2(x, y, double(img), ...
            point(:, 1), point(:, 2), method, fillValue);
    else
        % planar color
        for i = 1:nc
            val(:, i) = interp2(x, y, double(img(:, :, i)), ...
                point(:, 1), point(:, 2), method, fillValue(i));
        end
    end
    
elseif nd == 3
    % 3D Case
    x = 1:size(img, 2);
    y = 1:size(img, 1);
    
    if nc == 1
        % 3D grayscale
        z = 1:size(img, 3);
        val = interp3(x, y, z, double(img), ...
            point(:, 1), point(:, 2), point(:, 3), method, fillValue);
    else
        % 3D color
        z = 1:size(img, 4);
        for i = 1:nc
            val(:, i) = interp2(x, y, z, double(squeeze(img(:,:,i,:))), ...
                point(:, 1), point(:, 2), point(:, 3), method, fillValue(i));
        end
    end
    
end  

% keep same size for result, but add one dimension for channels
if dim(end) == 1
    dim(end) = nc;
else
    dim = [dim nc];
end

% reshape result to have the same dimension as original point input
val = reshape(val, dim);


function [coords, dim, varargin] = mergeCoordinates(varargin)
%MERGECOORDINATES Merge all coordinates into a single N-by-ND array
%
% [coords dim] = mergeCoordinates(X, Y)
% [coords dim] = mergeCoordinates(X, Y, Z)
%

% case of coordinates already grouped: use default results
coords = varargin{1};
dim = [size(coords,1) 1];
nbCoord = 1;

% Count the number of input arguments the same size as point
coordSize = size(coords);
for i = 2:length(varargin)
    % extract next input and compute its size
    var = varargin{i};
    varSize = size(var);
    
    % continue only if input is numeric has the same size
    if ~isnumeric(var)
        break;
    end
    if length(varSize) ~= length(coordSize)
        break;
    end
    if sum(varSize ~= coordSize) > 0
        break;
    end
    
    nbCoord = i;
end

% if other variables were found, we need to concatenate them
if nbCoord > 1
    % create new point array, and store input dimension
    dim = size(coords);
    coords = zeros(numel(coords), length(dim));
    
    % iterate over dimensions
    for i = 1:nbCoord
        var = varargin{i};
        coords(:, i) = var(:);
    end
end

varargin(1:nbCoord) = [];

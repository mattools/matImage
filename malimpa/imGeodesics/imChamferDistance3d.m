function dist = imChamferDistance3d(img, varargin)
%IMCHAMFERDISTANCE3D Compute chamfer distance in 3D images
%
%   RES = imChamferDistance3d(IMG, MARKERS);
%   where IMG and MARKERS are binary images, computes for each foreground
%   voxel the minimum distance to the marker, using a path that is
%   contained in the foreground. If the markers can not be reached from a
%   foreground voxel, the corresponding result is Inf.
%   The function propagates distances to neighor voxels, using appropriate
%   weights. The result RES is given in a double array the same size as
%   IMG. 
%
%   The function uses scanning algorithm. Each iteration consists in a
%   sequence of a forward and a backward scan. Iteration stops when
%   stability is reached.
%
%   RES = imChamferDistance3d(IMG);
%   Assumes the marker image is given by the complement of the image IMG.
%   In this case, the behaviour is similar to the functin bwdist.
%
%   RES = imChamferDistance3d(..., WEIGHTS);
%   Specifies different weights for computing distance between 2 pixels.
%   WEIGHTS is a 2 elements array, with WEIGHTS(1) corresponding to the
%   distance between two orthonal pixels, and WEIGHTS(2) corresponding to
%   the distance between two diagonal pixels.
%   Possible choices
%   WEIGHTS = [1 sqrt(2) sqrt(3)]   -> quasi-euclidean distance (default)
%   WEIGHTS = [1 Inf Inf]           -> "Manhattan" or "cityblock" distance
%   WEIGHTS = [1 1 1]               -> "Chessboard" distance
%   WEIGHTS = [3 4 5]               -> Svensson and Borgerfors' weights
%
%   Note: when specifying weights, the result has the same class/data type
%   than the array of weights. It is possible to balance between speed and
%   memory usage:
%   - if weights are double (the default), the memory usage is high, but
%       the result can be given in pixel units 
%   - if weights are integer (for Borgefors weights, for example), the
%       memory usage is reduced, but representation limit of datatype can
%       be easily reached. One needs to divide by the first weight to get
%       result comparabale with natural distances.
%       For uint8, using [3 4 5] weigths, the maximal computable distance
%       is around 255/3 = 85 pixels. Using 'int16'  seems to be a good
%       tradeoff, the maximal distance with [3 4 5] weights is around 11000
%       voxels.
%
%   RES = imChamferDistance3d(..., 'verbose', true);
%   Displays info on iterations.
%
%   Example
%   % computes distance function inside a torus
%     img = discreteTorus(1:100, 1:100, 1:100, [50 50 50 30 10  0 0]);
%     marker = false(size(img));
%     marker(50, 20, 50) = true;
%     dist = imChamferDistance3d(img, marker);
%     bounds = [0 max(dist(isfinite(dist)))];
%     rgb = double2rgb(dist, jet(256), bounds, [1 1 1]);
%     rgb8 = uint8(rgb * 255);
%     imshow(rgb8(:,:,50));
%
%
%   % uses the examples from bwdist with different distances
%     img = false(60, 60, 60);
%     img(6:55, 6:15, 6:15) = true;
%     img(46:55, 6:55, 6:15) = true;
%     img(6:55, 46:55, 6:15) = true;
%     img(6:15, 46:55, 6:55) = true;
%     img(6:55, 46:55, 46:55) = true;
%     img(46:55, 6:55, 46:55) = true;
%     img(6:55, 6:15, 46:55) = true;
%     marker = false(size(img));
%     marker(10, 10, 10) = true;
%     % distance between extremes
%     dist = imChamferDistance3d(img, marker);
%     dist(10, 10, 50)
%     ans = 
%         230.4880
%     % try with another metric
%     dist = imChamferDistance3d(img, marker, [3 4 5]);
%     dist(10, 10, 50) / 3
%     ans =
%         229.3333
%
%   See also
%   imGeodesics, bwdist, imGeodesicDistance
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-05-04,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.
% Licensed under the terms of the LGPL, see the file "license.txt"

%   HISTORY


%% Process input arguments


% extract markers if they are given as parameter
markers = [];
if ~isempty(varargin)
    var = varargin{1};
    if sum(size(var) ~= size(img))==0
        % use binarised markers
        markers = var > 0;
        varargin(1) = [];
    end
end

% if the markers are not given, assumes they correspond to the complement
% of the image
if isempty(markers)
    markers = img==0;
end


% default weights for orthogonal and diagonals
w1 = 1;
w2 = sqrt(2);
w3 = sqrt(3);

% extract user-specified weights
if ~isempty(varargin) && isnumeric(varargin{1})
    var = varargin{1};
    varargin(1) = [];
    w1 = var(1);
    w2 = var(2);
    w3 = var(3);
    % small check up to avoid degenerate cases
    if w2 == 0
        w2 = 2 * w1;
    end
    if w3 == 0
        w3 = 3 * w1;
    end
end


% extract verbosity option
verbose = false;
if length(varargin)>1
    varName = varargin{1};
    if ~ischar(varName)
        error('unknown option');
    end
    if strcmpi(varName, 'verbose')
        verbose = varargin{2};
    else
        error(['unknown option: ' varName]);
    end
end


%% Initialisations

% determines type of output from type of weights
outputType = class(w1);

% shifts in directions i j and k for forward iterations
di1 = [-1  0  1   -1  0  1   -1  0  1   -1  0   -1 -1];
dj1 = [-1 -1 -1    0  0  0    1  1  1   -1 -1    0  1];
dk1 = [-1 -1 -1   -1 -1 -1   -1 -1 -1    0  0    0  0];
% shifts in directions i j and k for backward iterations
di2 = [ 1  0 -1    1  0 -1    1  0 -1    1  0    1  1];
dj2 = [ 1  1  1    0  0  0   -1 -1 -1    1  1    0 -1];
dk2 = [ 1  1  1    1  1  1    1  1  1    0  0    0  0];

% propagation distances to neighbors (same order for backward and forward)
ws =  [w3 w2 w3   w2 w1 w2   w3 w2 w3   w2 w1   w1 w2];

% binarisation of mask image
mask = img > 0;

% allocate memory for result
dist = ones(size(mask), outputType);

% init result: either max value, or 0 for marker pixels
if isinteger(w1)
    dist(:) = intmax(outputType);
else
    dist(:) = inf;
end
dist(markers) = 0;

% size of image
[D1 D2 D3] = size(img);


%% Iterations until no more changes

% apply forward and backward iteration until no more changes are made
modif = true;
nIter = 1;
while modif
    modif = false;
    
    %% Forward iteration
    
    if verbose
        disp(sprintf('Forward iteration %d', nIter)); %#ok<DSPS>
    end
    
    
    % iteration on planes
    for k = 2:D3-1
        % iteration on lines
        for j = 2:D2-1
            % iteration on columns
            for i = 2:D1-1

                % computes only for pixel inside structure
                if ~mask(i, j, k)
                    continue;
                end
                
                % compute minimal propagated distance
                newVal = dist(i, j, k);
                for v = 1:length(ws)
                    val = dist(i+di1(v), j+dj1(v), k+dk1(v)) + ws(v);
                    newVal = min(newVal, val);
                end
                
                % if distance was changed, update result, and toggle flag
                if newVal ~= dist(i,j,k)
                    modif = true;
                    dist(i,j,k) = newVal;
                end
                
            end
        end
    end % iteration on planes

    % check end of iteration
    if modif == false && nIter ~= 1;
        break;
    end
    
    %% Backward iteration
    modif = false;
    
    if verbose
        disp(sprintf('Backward iteration %d', nIter)); %#ok<DSPS>
    end
    
      % iteration on planes
    for k = D3-1:-1:2
        % iteration on lines
        for j = D1-1:-1:2
            % iteration on columns
            for i = D1-1:-1:2

                % computes only for pixel inside structure
                if ~mask(i, j, k)
                    continue;
                end
                
                % compute minimal propagated distance
                newVal = dist(i, j, k);
                for v = 1:length(ws)
                    val = dist(i+di2(v), j+dj2(v), k+dk2(v)) + ws(v);
                    newVal = min(newVal, val);
                end
                
                % if distance was changed, update result, and toggle flag
                if newVal ~= dist(i,j,k)
                    modif = true;
                    dist(i,j,k) = newVal;
                end
                
            end
        end
    end % iteration on planes
    
    nIter = nIter + 1;
    
end % until no more modif

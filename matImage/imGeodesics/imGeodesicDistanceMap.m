function dist = imGeodesicDistanceMap(img, varargin)
%IMGEODESICDISTANCEMAP Geodesic distance transform for binary or label images
%
%   RES = imGeodesicDistanceMap(IMG, MARKERS);
%   where IMG and MARKERS are binary images, computes for each foreground
%   pixel the minimum distance to the marker, using a path that is
%   contained in the foreground. If the markers can not be reached from a
%   foreground pixel, the corresponding result is Inf.
%   The function propagates distances to orthogonal and diagonal pixels,
%   using weights equal to 1 for orthogonal pixels, and sqrt(2) for
%   diagonal markers. The result RES is given in a double array the same
%   size as IMG.
%
%   The function uses scanning algorithm. Each iteration consists in a
%   sequence of a forward and a backward scan. Iterations stop when
%   stability is reached.
%
%   RES = imGeodesicDistanceMap(IMG);
%   Assumes the marker image is given by the complement of the image IMG.
%   In this case, the behaviour is similar to the functin bwdist.
%
%   RES = imGeodesicDistanceMap(..., WEIGHTS);
%   Specifies different weights for computing distance between 2 pixels.
%   WEIGHTS is a 2 elements array, with WEIGHTS(1) corresponding to the
%   distance between two orthonal pixels, and WEIGHTS(2) corresponding to
%   the distance between two diagonal pixels.
%   Possible choices
%   WEIGHTS = [5 7 11]      -> best choice for 5x5 chamfer masks (default)
%   WEIGHTS = [1 sqrt(2)]   -> quasi-euclidean distance
%   WEIGHTS = [1 Inf]       -> "Manhattan" or "cityblock" distance
%   WEIGHTS = [1 1]         -> "Chessboard" distance
%   WEIGHTS = [3 4]         -> Borgerfors' weights
%   WEIGHTS = [5 7]         -> close approximation of sqrt(2)
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
%       For uint8, using [3 4] weigths, the maximal computable distance is
%       around 255/3 = 85 pixels. Using 'int16'  seems to be a good
%       tradeoff, the maximal distance with [3 4] weights is around 11000
%       pixels.
%
%   RES = imGeodesicDistanceMap(..., 'verbose', true);
%   Displays info on iterations.
%
%   Example
%   % computes distance function inside a complex particle
%     img = imread('circles.png');
%     marker = false(size(img));
%     marker(80, 80) = 1;
%     % compute using quasi-enclidean weights
%     dist = imGeodesicDistanceMap(img, marker);
%     figure; imshow(dist, []);
%     colormap(jet); title('Quasi-euclidean distance');
%     % compute using integer weights, giving integer results
%     dist34 = imGeodesicDistanceMap(img, marker, int16([3 4]));
%     figure; imshow(double(dist34)/3, [0 max(dist34(img))/3]);
%     colormap(jet); title('Borgefors 3-4 weights');
%
%
%   % uses the examples from bwdist with different distances
%     img = ones(255, 255);
%     img(126, 126) = 0;
%     res1 = imGeodesicDistanceMap(img);
%     res2 = imGeodesicDistanceMap(img, [1 inf]);
%     res3 = imGeodesicDistanceMap(img, [1 1]);
%     res4 = imGeodesicDistanceMap(img, [1 1.5]);
%     figure;
%     subplot(221); subimage(mat2gray(res1));
%     hold on; imcontour(res1); title('quasi-euclidean');
%     subplot(222); subimage(mat2gray(res2));
%     hold on; imcontour(res2); title('city-block');
%     subplot(223); subimage(mat2gray(res3));
%     hold on; imcontour(res3); title('chessboard');
%     subplot(224); subimage(mat2gray(res4));
%     hold on; imcontour(res4); title('approx euclidean');
%
%   
%   See also
%   imGeodesics, imGeodesicDistanceMap3d, imGeodesicDistance, imGeodesicDiameter
%   bwdist, bwdistgeodesic

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2016-01-14,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

%   HISTORY
%   2010.08.25 fix memory allocation for large images, add verbosity option
%   2018.02.22 rename from imChamferDistance5x5 to imGeodesicDistanceMap

%% Defualt options

% empty markers 
markers = [];

% default weights for orthogonal, diagonal, and chess-knight neighbors
weights = [5 7 11];

normalize = true;

% silent processing by default
verbose = false;


%% Process input arguments

% extract markers if they are given as parameter
if ~isempty(varargin)
    var = varargin{1};
    if ndims(var) == ndims(img) && sum(size(var) ~= size(img)) == 0
        % use binarised markers
        markers = var > 0;
        varargin(1) = [];
    end
end

% if the markers are not given, assumes they correspond to the complement
% of the input image
if isempty(markers)
    markers = img==0;
end

% extract user-specified weights
if ~isempty(varargin)
    weights = varargin{1};
    varargin(1) = [];
end
 
% extract verbosity option
if length(varargin) > 1
    varName = varargin{1};
    if ~ischar(varName)
        error('Require options as name-value pairs');
    end
    
    if strcmpi(varName, 'normalize')
        normalize = varargin{2};
    elseif strcmpi(varName, 'verbose')
        verbose = varargin{2};
    else
        error(['unknown option: ' varName]);
    end
end


%% Pre-Processing

% extract weights in specific directions
w1 = weights(1);
w2 = weights(2);

% small check up to avoid degenerate cases
if w2 == 0
    w2 = 2 *  w1;
end

% initialize weight associated to chess-knight move
if length(weights) == 2
    nShifts = 4;
    % the list of shifts for forward scans (shift in y, shift in x, weight)
    fwdShifts = [...
        -1 -1; ...
        -1  0; ...
        -1 +1; ...
         0 -1];
    
    % the list of shifts for backward scans (shift in y, shift in x, weight)
    bckShifts = [...
        +1 +1; ...
        +1  0; ...
        +1 -1; ...
         0 +1];
    ws = [w2 w1 w2 w1];
else
    w3 = weights(3);
    nShifts = 8;
    
    % the list of shifts for forward scans (shift in y, shift in x, weight)
    fwdShifts = [...
        -2 -1; ...
        -2 +1; ...
        -1 -2; ...
        -1 -1; ...
        -1  0; ...
        -1 +1; ...
        -1 +2; ...
         0 -1 ];
    
    % the list of shifts for backward scans (shift in y, shift in x, weight)
    bckShifts = [...
        +2 +1; ...
        +2 -1; ...
        +1 +2; ...
        +1 +1; ...
        +1  0; ...
        +1 -1; ...
        +1 -2; ...
         0 +1];
    ws = [w3 w3 w3 w2 w1 w2 w1 w3];
end

% determines type of output from type of weights
outputType = class(w1);

% allocate memory for result
dist = ones(size(img), outputType);

% init result: either max value, or 0 for marker pixels
if isinteger(w1)
    dist(:) = intmax(outputType);
else
    dist(:) = inf;
end
dist(markers) = 0;

% size of image
[D1, D2] = size(img);


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
    
    % forward iteration on lines
    for i = 1:D1
        % process all pixels inside the current line
        for j = 1:D2
            % computes only for pixel inside structure
            if img(i, j) == 0
                continue;
            end
            
            % compute minimal propagated distance around neighbors in
            % forward mask
            newVal = dist(i, j);
            for k = 1:nShifts
                % coordinate of neighbor
                i2 = i + fwdShifts(k, 1);
                j2 = j + fwdShifts(k, 2);
                
                % check bounds of neighbor
                if i2 < 1 || i2 > D1
                    continue;
                end
                if j2 < 1 || j2 > D2
                    continue;
                end
                
                % compute new value of local distance map
                if img(i2, j2) == img(i, j)
                    % neighbor in same region
                    % -> add offset weight to neighbor distance
                    newVal = min(newVal, dist(i2, j2) + ws(k));
                end
            end
            
            % if distance was changed, update result, and toggle flag
            if newVal < dist(i,j)
                modif = true;
                dist(i,j) = newVal;
            end
        end
        
    end % iteration on lines

    % check end of iteration
    if ~modif && nIter ~= 1
        break;
    end
    
    %% Backward iteration
    modif = false;
    
    if verbose
        disp(sprintf('Backward iteration %d', nIter)); %#ok<DSPS>
    end
    
    % backward iteration on lines
    for i = D1:-1:1
        % process all pixels inside the current line
        for j = D2:-1:1
            % computes only for pixel inside structure
            if img(i, j) == 0
                continue;
            end
            
            % compute minimal propagated distance around neighbors in
            % backward mask
            newVal = dist(i, j);
            for k = 1:nShifts
                % coordinate of neighbor
                i2 = i + bckShifts(k, 1);
                j2 = j + bckShifts(k, 2);
                
                % check bounds of neighbor
                if i2 < 1 || i2 > D1
                    continue;
                end
                if j2 < 1 || j2 > D2
                    continue;
                end
                
                % compute new value of local distance map
                if img(i2, j2) == img(i, j)
                    % neighbor in same region
                    % -> add offset weight to neighbor distance
                    newVal = min(newVal, dist(i2, j2) + ws(k));
                end
            end
               
            % if distance was changed, update result, and toggle flag
            if newVal < dist(i,j)
                modif = true;
                dist(i,j) = newVal;
            end
        end
        
    end % line iteration
    
    nIter = nIter+1;
end % until no more modif

% normalize map
if normalize
    dist(img > 0) = dist(img > 0) / w1;
end

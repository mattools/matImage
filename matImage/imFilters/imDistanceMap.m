function dist = imDistanceMap(img, varargin)
%IMDISTANCEMAP Compute chamfer distance using scanning algorithm
%
%   RES = imDistanceMap(IMG);
%   where IMG is a binary images, computes for each foreground pixel the
%   minimum distance to the background.
%   The function propagates distances to orthogonal and diagonal pixels,
%   using weights equal to 1 for orthogonal pixels, and sqrt(2) for
%   diagonal markers. The result RES is given in a double array the same
%   size as IMG.
%
%   The function uses scanning algorithm, by applying one forward and one
%   backward scan. 
%
%   RES = imDistanceMap(..., WEIGHTS);
%   Specifies different weights for computing distance between 2 pixels.
%   WEIGHTS is a 2 elements array, with WEIGHTS(1) corresponding to the
%   distance between two orthonal pixels, and WEIGHTS(2) corresponding to
%   the distance between two diagonal pixels.
%   Possible choices
%   WEIGHTS = [1 sqrt(2)]   -> quasi-euclidean distance
%   WEIGHTS = [1 Inf]       -> "Manhattan" or "cityblock" distance
%   WEIGHTS = [1 1]         -> "Chessboard" distance
%   WEIGHTS = [3 4]         -> Borgerfors' weights
%   WEIGHTS = [5 7]         -> close approximation of sqrt(2)
%   WEIGHTS = [5 7 11]      -> Uses an additional weight for chess-knight
%                              shifts around each pixel( default)
%
%   Note: when specifying weights, the result has the same class/data type
%   than the array of weights. It is possible to balance between speed and
%   memory usage:
%   - if weights are double (the default), the memory usage is larger, but
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
%   RES = imDistanceMap(..., 'normalize', TF);
%   If TF is true, normalizes the resulting map by the first weight.
%   Default is true.
%
%   RES = imDistanceMap(..., 'verbose', true);
%   Displays info on iterations.
%
%   Example
%   % Computes distance map on closed circles, with Borgefors Metric
%     img = imread('circles.png');
%     se = strel('disk', 6);
%     img2 = imclose(img, se);
%     dist = imDistanceMap(img2, [3 4]);
%     imshow(dist, []); colormap jet;
%
%   % uses the examples from bwdist with different distances
%     img = ones(255, 255);
%     img(126, 126) = 0;
%     res1 = imDistanceMap(img);
%     res2 = imDistanceMap(img, [1 inf]);
%     res3 = imDistanceMap(img, [1 1]);
%     res4 = imDistanceMap(img, [1 1.5]);
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
%   imChamferDistance, bwdist, imSeparateParticles
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-08-20,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2010-08-25 fix memory allocation for large images, add vebosity option
%   2012-08-20 adapt imChamferDistance to create imDistanceMap
%   2018-02-22 add management of contiguous labels, and of three weights


%% Process input arguments

% default weights for orthogonal or diagonal
weights = [5 7 11];

normalize = true;

% extract user-specified weights
if ~isempty(varargin)
    weights = varargin{1};
    varargin(1) = [];
end

% extract verbosity option
verbose = false;
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


%% Initialisations

% determines type of output from type of weights
outputType = class(weights);

% small check up to avoid degenerate cases
w1 = weights(1);
w2 = weights(2);
if w2 < w1
    w2 = 2 * w1;
end

% shifts in directions i and j for (1) forward and (2) backward iterations
if length(weights) == 2
    nShifts = 4;
    di1 = [-1 -1 -1  0];
    dj1 = [-1  0  1 -1];
    di2 = [+1 +1 +1  0];
    dj2 = [-1  0  1 +1];
    ws =  [w2 w1 w2 w1];
    
elseif length(weights) == 3
    nShifts = 8;
    w3 = weights(3);
    di1 = [-2 -2 -1 -1 -1 -1 -1  0];
    dj1 = [-1 +1 -2 -1  0  1 +2 -1];
    di2 = [+2 +2 +1 +1 +1 +1 +1  0];
    dj2 = [-1 +1 +2 +1  0 -1 -2 +1];
    ws =  [w3 w3 w3 w2 w1 w2 w3 w1];
end

% allocate memory for result
dist = ones(size(img), outputType);

% init result: either max value, or 0 for marker pixels
if isinteger(w1)
    dist(:) = intmax(outputType);
else
    dist(:) = inf;
end
dist(~img) = 0;

% size of image
[D1, D2] = size(img);


%% Forward iteration

if verbose
    disp('Forward iteration %d');
end

for i = 1:D1
    for j = 1:D2
        % computes only for pixels within a region
        if img(i, j) == 0
            continue;
        end
        
        % compute minimal propagated distance
        newVal = dist(i, j);
        for k = 1:nShifts
            % coordinate of neighbor
            i2 = i + di1(k);
            j2 = j + dj1(k);
            
            % check bounds
            if i2 < 1 || i2 > D1 || j2 < 1 || j2 > D2
                continue;
            end
            
            % compute new value
            if img(i2, j2) == img(i, j)
                % neighbor in same region 
                % -> add offset weight to neighbor distance
                newVal = min(newVal, dist(i2, j2) + ws(k));
            else
                % neighbor in another region 
                % -> initialize with the offset weight
                newVal = min(newVal, ws(k));
            end
            
        end
        
        % if distance was changed, update result
        dist(i,j) = newVal;
    end
    
end % iteration on lines



%% Backward iteration

if verbose
    disp('Backward iteration');
end

for i = D1:-1:1
    for j = D2:-1:2
        % computes only for foreground pixels
        if img(i, j) == 0
            continue;
        end
        
        % compute minimal propagated distance
        newVal = dist(i, j);
        for k = 1:nShifts
            % coordinate of neighbor
            i2 = i + di2(k);
            j2 = j + dj2(k);
            
            % check bounds
            if i2 < 1 || i2 > D1 || j2 < 1 || j2 > D2
                continue;
            end
            
            % compute new value
            if img(i2, j2) == img(i, j)
                % neighbor in same region 
                % -> add offset weight to neighbor distance
                newVal = min(newVal, dist(i2, j2) + ws(k));
            else
                % neighbor in another region 
                % -> initialize with the offset weight
                newVal = min(newVal, ws(k));
            end
             
        end
        
        % if distance was changed, update result
        dist(i,j) = newVal;
    end
    
end % line iteration

if normalize
    dist(dist>0) = dist(dist>0) / w1;
end

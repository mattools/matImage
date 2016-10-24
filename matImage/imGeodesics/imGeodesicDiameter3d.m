function gl = imGeodesicDiameter3d(img, varargin)
%IMGEODESICDIAMETER3D Compute geodesic diameter of 3D particles
%
%   GL = imGeodesicDiameter3d(IMG)
%   where IMG is a labeled image, returns the geodesic diameter of each
%   particle.
%   If IMG is a binary image, a labelling is performed first.
%   GL is a column vector containing the geodesic diameter of each particle.
%
%   A definition for the geodesic length can be found in the book from
%   Coster & Chermant: "Precis d'analyse d'images", Ed. CNRS 1989.
%
%   
%   GL = imGeodesicDiameter3d(IMG, WS)
%   Specifies the weights associated to neighbor pixels. WS(1) is the
%   distance to orthogonal pixels, WS(2) is the distance to diagonal pixels
%   in same plane, and WS(3) is the distance to opposite pixel in cube. 
%   Default is [3 4 5 ], recommended by Borgefors. The final length is 
%   normalized by weight associated to orthogonal pixels.
%   
%   GL = imGeodesicDiameter3d(..., 'verbose', true);
%   Display some informations about the computation procedure, that may
%   take some time for large and/or complicated images.
%
%   These algorithm uses 3 steps:
%   * first propagate distance from particles boundary to find a pixel
%       approximately in the center of the particle(s)
%   * propagate distances from the center, and keep the furthest pixel,
%       which is assumed to be a geodesic extremity
%   * propagate distances from the geodesic extremity, and keep the maximal
%       distance.
%   This algorithm is less time-consuming than the direct approach that
%   consists in computing geodesic propagation and keeping the max value.
%   However, for some cases in can happen that the two methods give
%   different results.
%
%
%   Notes: 
%   * the particles are assumed to be 26 connected. If two or more
%       particles touch by a corner, the result will not be valid.
%   
%   Example
%   % uses the examples from bwdist with different distances
%     img = false(60, 60, 60);
%     img(6:55, 6:15, 6:15) = true;
%     img(46:55, 6:55, 6:15) = true;
%     img(6:55, 46:55, 6:15) = true;
%     img(6:15, 46:55, 6:55) = true;
%     img(6:55, 46:55, 46:55) = true;
%     img(46:55, 6:55, 46:55) = true;
%     img(6:55, 6:15, 46:55) = true;
%     diam = imGeodesicDiameter3d(img)
%     ans = 
%
%     diam = imGeodesicDiameter3d(img, uint16([3 4 5]))
%     ans = 
%         243
%
%   See Also
%   imGeodesics, imChamferDistance3d, imGeodesicExtremities
%   imGeodesicRadius, imGeodesicCenter, imMaxGeodesicPath
%
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/05/2012.
%

%   HISTORY 


%% Default values 

% weights for computing geodesic lengths
ws = [3 4 5];

% no verbosity by default
verbose = 0;


%% process input arguments

% extract weights if present
if ~isempty(varargin)
    if isnumeric(varargin{1})
        ws = varargin{1};
        varargin(1) = [];
    end
end

% Extract options
while ~isempty(varargin)
    paramName = varargin{1};
    if strcmpi(paramName, 'verbose')
        verbose = varargin{2};
    else
        error(['Unkown option in imGeodesicDiameter3d: ' paramName]);
    end
    varargin(1:2) = [];
end

% make input image a label image if this is not the case
if islogical(img)
    if verbose
        disp('Labelling particles');
    end
    img = bwlabeln(img);
end

% number of structures in image
n = max(img(:));


%% Detection of center point (furthest point from boundary)

if verbose
    disp(sprintf('Computing geodesic length of %d particle(s).', n)); %#ok<*DSPS>
end

% create markers image
markers = ~img;

if verbose
    disp('Computing empirical centers.'); 
end

% computation of geodesic length from empirical markers
dist = imChamferDistance3d(img, markers, ws, 'verbose', verbose);



%% Second pass: find a geodesic extremity

% compute new seed point in each label, and use it as new marker
markers = false(size(img));
for i = 1:n
    % find the pixel with greatest distance in current label
    inds = find(img == i);
    [maxVal, indMax] = max(dist(img==i)); %#ok<ASGLU>
    [yi, xi, zi] = ind2sub(size(img), inds(indMax));
    markers(yi, xi, zi) = true;
end

if verbose
    disp('Second step markers computations done.'); 
end

% recomputes geodesic distance from new markers
dist = imChamferDistance3d(img, markers, ws, 'verbose', verbose);


%% third pass: find second geodesic extremity

% compute new seed point in each label, and use it as new marker
markers = false(size(img));
for i = 1:n
    % find the pixel with greatest distance in current label
    inds = find(img == i);
    [maxVal, indMax] = max(dist(img==i)); %#ok<ASGLU>
    [yi, xi, zi] = ind2sub(size(img), inds(indMax));
    markers(yi, xi, zi) = true;
end

if verbose
    disp('Third step markers computations done.'); 
end

% recomputes geodesic distance from new markers
dist = imChamferDistance3d(img, markers, ws, 'verbose', verbose);


%% Final computation of geodesic distances

% keep max geodesic distance inside each label
gl = zeros(n, 1);
for i = 1:n
    % find the pixel with greatest distance in current label
    gl(i) = max(dist(img==i));
end

% format to have metric in pixels, and not a multiple of the weights
gl = double(gl) / double(ws(1));

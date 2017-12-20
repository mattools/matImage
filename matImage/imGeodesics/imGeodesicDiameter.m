function gd = imGeodesicDiameter(img, varargin)
%IMGEODESICDIAMETER Compute geodesic diameter of particles
%
%   GD = imGeodesicDiameter(IMG)
%   where IMG is a label image, returns the geodesic diameter of each
%   particle in the image. If IMG is a binary image, a connected-components
%   labelling is performed first. 
%   GD is a column vector containing the geodesic diameter of each particle.
%
%   A definition for the geodesic diameter can be found in the book from
%   Coster & Chermant: "Precis d'analyse d'images", Ed. CNRS 1989.
%
%   
%   GD = imGeodesicDiameter(IMG, WS)
%   Specifies the weights associated to neighbor pixels. WS(1) is the
%   distance to orthogonal pixels, and WS(2) is the distance to diagonal
%   pixels. An optional WS(3) weight may be specified, corresponding to
%   chess-knight moves. Default is [5 7 11], recommended for 5-by-5 masks.
%   The final length is normalized by weight for orthogonal pixels. For
%   thin structures (skeletonization result), or for very close particles,
%   the [3 4] weights recommended by Borgeors may be more appropriate.
%   
%   GD = imGeodesicDiameter(..., 'verbose', true);
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
%   * only planar images are currently supported.
%   * the particles are assumed to be 8 connected. If two or more particles
%       touch by a corner, the result will not be valid.
%   
%   Example
%     % segment and labelize image of grains, and compute their geodesic
%     % diameter
%     img = imread('rice.png');
%     img2 = img - imopen(img, ones(30, 30));
%     bin = imopen(img2 > 50, ones(3, 3));
%     lbl = bwlabel(bin);
%     gd = imGeodesicDiameter(lbl);
%     plot(gd, '+');
%
%
%   See Also
%   imGeodesics, imChamferDistance, imGeodesicExtremities
%   imGeodesicRadius, imGeodesicCenter, imMaxGeodesicPath
%

%   ---------
%   author : David Legland 
%   mail: david.legland@inra.fr
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/07/2005.
%

%   HISTORY 
%   10/08/2006 add support for 3D images
%   19/04/2007 update doc, allocate memory for result
%   20/05/2009 rewrite using chamfer distance (work now only for 2D)
%   24/08/2010 add comments, add verbosity option
%   15/09/2010 add a pass to detect center
%   08/04/2016 use chess-knight weight as default weights

%% Default values 

% weights for computing geodesic lengths
ws = [5 7 11];

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
        error(['Unkown option in imGeodesicDiameter: ' paramName]);
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
nLabels = max(img(:));


%% Detection of center point (furthest point from boundary)

if verbose
    disp(sprintf('Computing geodesic diameters of %d particle(s).', nLabels)); %#ok<*DSPS>
end

% create markers image at the boundary of the labels
markers = img == 0;

if verbose
    disp('Computing initial centers...'); 
end

% computation of geodesic length from empirical markers
dist = imChamferDistance(img, markers, ws, 'verbose', verbose);


%% Second pass: find a geodesic extremity

if verbose
    disp('Create marker image of initial centers'); 
end

% find the pixel with largest distance in current label
maxVals = -ones(nLabels, 1);
maxValInds = zeros(nLabels, 1);

for i = 1:numel(img)
    label = img(i);
    if label > 0
        if dist(i) > maxVals(label)
            maxVals(label) = dist(i);
            maxValInds(label) = i;
        end
    end
end

% compute new seed point in each label, and use it as new marker
markers = false(size(img));
markers(maxValInds) = 1;

if verbose
    disp('Propagate distance from initial centers'); 
end

% recomputes geodesic distance from new markers
dist = imChamferDistance(img, markers, ws, 'verbose', verbose);


%% third pass: find second geodesic extremity

if verbose
    disp('Create marker image of first geodesic extremity'); 
end

% find the pixel with largest distance in current label
maxVals = -ones(nLabels, 1);
maxValInds = zeros(nLabels, 1);

for i = 1:numel(img)
    label = img(i);
    if label > 0
        if dist(i) > maxVals(label)
            maxVals(label) = dist(i);
            maxValInds(label) = i;
        end
    end
end

% compute new seed point in each label, and use it as new marker
markers = false(size(img));
markers(maxValInds) = 1;

if verbose
    disp('Propagate distance from first geodesic extremity'); 
end

% recomputes geodesic distance from new markers
dist = imChamferDistance(img, markers, ws, 'verbose', verbose);


%% Final computation of geodesic distances

if verbose
    disp('Compute geodesic diameters'); 
end

% keep max geodesic distance inside each label
gd = -ones(nLabels, 1);
for i = 1:numel(img)
    label = img(i);
    if label > 0
        if dist(i) > gd(label)
            gd(label) = dist(i);
        end
    end
end

% add 1 for taking into account pixel thickness
gd = gd + 1;

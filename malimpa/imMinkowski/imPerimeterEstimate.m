function [perim labels] = imPerimeterEstimate(img, varargin)
% Perimeter estimate of a 2D binary structure
%
%   P = imPerimeter(IMG);
%   Return an estimate of the perimeter of the image, computed by
%   counting intersections with 2D lines, and using discretized version of
%   the Crofton formula.
%
%   P = imPerimeter(IMG, CONN);
%   Specify connectivity to use. Either 4 or 8. Default is 4.
%
%   P = imPerimeter(IMG, CONN, SCALE);
%   Also specify scale of image tile. SCALE si a 2x1 array, containing
%   pixel size in each direction. Default is [1 1].
%   
%   [P LABEL] = imPerimeter(IMG, ...);
%   When IMG is a label image, the perimeter of each label is computed and
%   returned in column array P. The output LABEL returns the LABEL of each
%   computed phase.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% check image dimension
if ndims(img)~=2
    error('first argument should be a 2D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    % extract labels (considers 0 as background)
    labels = unique(img);
    labels(labels==0) = [];
    
    % allocate result array
    nLabels = length(labels);
    perim = zeros(nLabels, 1);

    props = regionprops(img, 'BoundingBox');
    
    % compute perimeter of each label considered as binary image
    for i = 1:nLabels
        label = labels(i);
        bin = imcrop(img, props(label).BoundingBox) == label;
        perim(i) = imPerimeterEstimate(bin, varargin{:});
    end
    
    return;
end


%% Process input arguments

% in case of binary image, compute only one label
labels = 1;

% default connectivity
conn = 4;

% default image resolution
delta = [1 1];

while ~isempty(varargin)
    var = varargin{1};
    if ~isnumeric(var)
        error('option should be numeric');
    end
    
    % option is either connectivity or resolution
    if isscalar(var)
        conn = var;
    else
        delta = var;
    end
    varargin(1) = [];
end


%% Initialisations 

% distances between a pixel and its neighbours.
d1  = delta(1);
d2  = delta(2);
d12 = sqrt(delta(1)^2 + delta(2)^2);
vol = d1*d2;

% size of image
dim = size(img);
D1 = dim(1);
D2 = dim(2);


%% Compute intersections

% first compute number of intersections in the 2 main directions
n1 = sum(sum(img(1:D1-1,:) ~= img(2:D1,:)));
n2 = sum(sum(img(:,1:D2-1) ~= img(:,2:D2)));

% compute for 4 closest neighbours
% equivalent to:
% perim = mean([n1/(d1/a) n2/(d2/a)])*pi/2;
% with a = d1*d2 being the area of the unit tile
if conn==4
    perim = mean([n1*d2 n2*d1])*pi/2;
else
    
    % check the 2 diagonal directions
    n3 = sum(sum(img(1:D1-1, 1:D2-1) ~= img(2:D1, 2:D2)   )) ;
    n4 = sum(sum(img(1:D1-1, 2:D2  ) ~= img(2:D1, 1:D2-1) )) ;
    
    % average over directions
    perim = mean([n1*d2 n2*d1 [n3 n4]*vol/d12])*pi/2;    
end


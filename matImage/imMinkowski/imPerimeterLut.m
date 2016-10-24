function lut = imPerimeterLut(varargin)
%IMPERIMETERLUT Look-Up Table for measuring perimeter in a binary image
%
%   LUT = imPerimeterLut()
%   Returns a 16-by-1 column vector computing the perimeter contribution
%   associated to each of the 2-by-2 configurations of binary pixels.
%
%   LUT = imPerimeterLut(NDIRS)
%   Specifies the numner of directions to use (default is 4)
%
%   LUT = imPerimeterLut(..., RESOL)
%   Specifies the resolution of the image, as a 1-by-2 row vector.
%
%   Example
%     % compute the perimeter of a binary disk of radius 40
%     lx = 1:100; ly = 1:100;
%     [x, y] = meshgrid(lx, ly);
%     img = hypot(x - 50.12, y - 50.23) < 40;
%     bch = imBinaryConfigHisto(img);
%     lut = imPerimeterLut();
%     sum(bch .* lut)
%     ans =
%       251.1751
      % to be compared to (2 * pi * 40), approximately 251.3274
%
%   See also
%     imPerimeter, imSurfaceLut, imBinaryConfigHisto
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-20,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

%% Extract input data

% size of image tile
delta = [1 1];

% number of discrete directions
nDirs = 4;

% Process user input arguments
while ~isempty(varargin)
    var = varargin{1};
    if isnumeric(var)
        % option is either connectivity or resolution
        if isscalar(var)
            nDirs = var;
        else
            delta = var;
        end
        varargin(1) = [];

    else
        error('option should be numeric');
    end
end

%% Initialisations 

% distances between a pixel and its neighbours.
% (d1 is dx, d2 is dy)
d1  = delta(1);
d2  = delta(2);
d12 = hypot(d1, d2);

% area of a pixel (used for computing line densities)
vol = d1 * d2;


% correspondance map between pixel label and pixel coord in config
coord = [...
    1 1; ...
    1 2; ...
    2 1; ...
    2 2; ...
    ];

% compute direction weights (necessary for anisotropic case)
if any(delta ~= 1)
    c = computeDirectionWeights2d4(delta)';
else
    c = [1 1 1 1] / 4;
end
c1 = c(1);
c2 = c(2);
c3 = c(3);


%% Create Look-up Table

% initialize empty arrays
N = 16; % = 2^(2^2);
lut = zeros(N, 1);


% loop for each tile configuration
for i = 1:N
    % create the tile
    im = false([2 2]);
    v = i - 1;
    im(1,1) = bitand(v,1) ~= 0;
    im(1,2) = bitand(v,2) ~= 0;
    im(2,1) = bitand(v,4) ~= 0;
    im(2,2) = bitand(v,8) ~= 0;
    
    % compute contribution of individual configuration
    for j = 1:numel(im)
        % position of pixel in the tile
        p1 = coord(j, 1);
        p2 = coord(j, 2);
        
        % if pixel do not belong to the structure, its contribution is 0
        if im(p1, p2) == 0
            continue;
        end
        
        % contributions for horizontal and vertical directions, 
        % corresponding to projected diameters, and taking into account
        % image resolution
        ke1 = 0; ke2 = 0;
        if ~im(3-p1, p2), ke1 = ke1 + vol/d1/2; end
        if ~im(p1, 3-p2), ke2 = ke2 + vol/d2/2; end
        
        if nDirs == 2
            % For 2 directions, the direction weight is 1/2, and the
            % multiplicity of edges is 2, resulting in 1/4 coefficient
            lut(i) = lut(i) + (ke1 + ke2) * pi / 4;
            
        elseif nDirs == 4
            % compute the contribution to projected diameters also in the
            % diagonal direction containing current pixel
            ke3 = 0; 
            if ~im(3-p1, 3-p2), ke3 = ke3 + vol/d12/2; end
            
            % Decomposition of Crofton formula on 4 directions, taking into
            % account direction weights c_i and edges multiplicity
            lut(i) = lut(i) + pi * (ke1*c1/2 + ke2*c2/2 + ke3*c3);
        else
            error ('Sorry, non supported connectivity');
        end
    end
end



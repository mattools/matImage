function rgb = angle2rgb(img, varargin)
% Convert an image of angles to a color image.
%
%   RES = angle2rgb(IMG);
%   IMG is an image containing angle values, in radians.
%   RES is a RGB image with the same size a IMG, with 3 channels for
%   dimension 3, containing colors corresponding to each angle, based on
%   the 'hsv' colormap:
%   0       -> red
%   pi/3    -> yellow
%   2*pi/3  -> green
%   pi      -> cyan
%   4*pi/3  -> blue
%   5*pi/3  -> magenta
%   2*pi    -> red again
%   Angle values are considered modulo 2*pi.
%
%   RES = angle2rgb(IMG, MAXANGLE)
%   Also specifies the value of the maximal angle. Can be PI, in this case
%   the function considers unoriented angles, or 360, in this case consider
%   degrees instead of radians.
%
%   RES = angle2rgb(IMG, RANGE)
%   Specifies the angular range as a 1-by-2 row vector containing the
%   minimal and maximal angle values.
%
%   RES = angle2rgb(..., 'range', RANGE)
%   Provides the angular range (min and max value of angles) as a 1-by-2
%   row vector.
%
%   RES = angle2rgb(..., 'weights', WEIGHTS)
%   Provides weights associated to each angle, as a numeric array the same
%   size as the input array. Large weights will result in saturated colors,
%   small weights to unsatured (default: white) colors.
%   
%
%   Example
%   % show angle of angular values around origin
%     [x, y] = meshgrid(-50:50, -50:50);
%     a = atan2(y, x);
%     imshow(angle2rgb(a));
%
%   % show hue value of a color image
%     img = imread('peppers.png');
%     hsv = rgb2hsv(img);
%     % convert hue value, coded between 0 and 1, into RGB
%     rgbHue = angle2rgb(hsv(:,:,1), 1);
%     subplot(121); imshow(img); subplot(122); imshow(rgbHue);
%
%   See also
%     deg2rad, rad2deg, angle, imGetHue
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-02-06,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.


%% Process input arguments

% default values
mini = 0;
maxi = 2 * pi;
weights = ones(size(img));

% extract input arguments given as numeric values
if ~isempty(varargin) && isnumeric(varargin{1})
    var1 =  varargin{1};
    
    if isscalar(var1)
        maxi = var1;
    elseif isnumeric(var1) && all(size(var1) == [1 2])
        mini = var1(1);
        maxi = var1(2);
    else
        error('Second argument must be either a scalar or 2-elements row vector');
    end
    
    varargin(1) = [];
end

% process input argument as parameter name-value pairs
while length(varargin) > 1
    name = varargin{1};
    
    if strcmpi(name, 'range')
        % range of angle values, such as [0 2*pi], [-90 90]...
        value = varargin{2};
        if any(size(value) ~= [1 2])
            error('range parameter must have size [1 2]');
        end
        mini = value(1);
        maxi = value(2);
        
    elseif strcmpi(name, 'weights')
        % weights associated to each angular value
        weights = varargin{2};
        if any(size(weights) ~= size(img))
            error('weights parameter must have same size as input array');
        end
        
    else
        error('matImage:angle2rgb', ....
            'Unable to interpret argument name %s', name);
    end
    
    varargin(1:2) = [];
end


%% Main processing

% normalise within range of angular values
hue = (img - mini) / (maxi - mini);
% clamp values between 0 and 1
hue = mod(mod(hue, 1) + 1, 1);

% use weights as saturation, and max intensity everywhere
sat = double(weights) / double(max(weights(:)));
val = ones(size(weights));

% convert to RGB
rgb = hsv2rgb(cat(3, hue, sat, val));


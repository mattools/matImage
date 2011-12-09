function varargout = imGradient(img, varargin)
%IMGRADIENT Compute gradient magnitude in a grayscale image
%
%   [DX DY] = imGradient(IMG);
%   [DX DY DZ] = imGradient(IMG);
%   Compute the components of the gradient vector of a 2D or a 3D image.
%   The gradient is computed in each orthogonal direction by using
%   normalised Sobel filters. 
%   For a 2D image, gradient magnitude and angle can be computed from:
%   MAG = hypot(DX, DY);
%   ANGLE = atan2(DY, DX);
%
%   GRAD = imGradient(IMG);
%   Compute the gradient magnitude. Magnitude is computed as:
%   - hypot(dx, dy) for 2D images
%   - hypot(hypot(dx, dy), dz) for 3D images
%
%   GRAD = imGradient(IMG, 'filter', FILTER);
%   Specifies the filter used for computing gradient in the X direction.
%   Note that fspecial('sobel') or fspecial('prewitt') return unnormalized
%   filters for the Y direction (horizontal gradient).
%
%   ... = imGradient(..., OPTION1, OPTION2...);
%   Will use the given set of options when computing the gradient filter.
%   See the documentation of imfilter for details.
%   Default options are 'conv' and 'replicate'.
%
%   Example
%   % display edge strength computed on cameraman picture
%   img = imread('cameraman.tif');
%   grad = imGradient(img);
%   imshow(grad, [0 max(grad(:))]);
%
%   % compute edge direction on rice picture
%   img = imread('rice.png');
%   [dx dy] = imGradient(img);
%   grad = hypot(dx, dy);
%   theta = atan2(dy, dx);
%   rgb = angle2rgb(theta);     % convert to rgb
%   bin = grad>50;              % select only salient edges
%   rgb(~bin(:,:, [1 1 1])) = 0;% display salient edges orientation
%   imshow(rgb);
%
%   % Uses a different filter (the same as for the "gradient" function)
%   img = imread('cameraman.tif');
%   grad = imGradient(img, 'filter', [1 0 -1]);
%   imshow(grad, [0 max(grad(:))]);
%
%   See also
%   imfilter, fspecial, angle2rgb, gradient
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-08-19,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% HISTORY
% 2010-01-13 add support for gradient direction and filter options
% 2010-02-16 change output format for 2 output parameters, add support
%   for 3D images, and add psb to change filter.
% 2010-03-03 use convolution by default
% 2010-03-05 return result as double, normalize default filter
% 2010-12-06 use 3D kernel by default for 3D images


%% Parse input arguments

% image dimension
dim = size(img);

% number of dimension of image (do not manage color images)
nd = length(dim);

% default filter for gradient: normalised sobel
if nd <= 2
    sx = fspecial('sobel')'/8;
    
elseif nd == 3
    % use normalisation of 2 sobel matrices
    base = [1 2 1]'*[1 2 1];
    base = base/sum(base(:))/2;
    sx = permute(cat(3, base, zeros(3, 3), -base), [2 3 1]);

else
    error('Input image must have 2 or 3 dimensions');
end

% check if another gradient filter is proposed
for i = 1:length(varargin)-1
    if strcmp(varargin{i}, 'filter')
        sx = varargin{i+1};
        varargin(i:i+1) = [];
        break;
    end
end

% default options for computations
varargin = [{'replicate'}, {'conv'}, varargin];


%% Gradient computation

% compute gradients in each main direction
if nd == 2
    % Process 2D Image
    dx = imfilter(double(img), sx, varargin{:});
    dy = imfilter(double(img), sx', varargin{:});
    
elseif nd == 3
    % Process 3D Image
    sy = permute(sx, [2 3 1]);
    sz = permute(sx, [3 1 2]);
    dx = imfilter(double(img), sx, varargin{:});
    dy = imfilter(double(img), sy, varargin{:});
    dz = imfilter(double(img), sz, varargin{:});
end


%% Format output

% Depending on number of output arguments, returns either the gradient
% module, or each component of the gradient vector.
if nargout == 1
    % compute gradient module
    if nd == 2
        varargout{1} = hypot(dx, dy);
    else
        varargout{1} = hypot(hypot(dx, dy), dz);
    end
    
else
    % return each component of the vector array
    varargout{1} = dx;
    varargout{2} = dy;
    if nd > 2
        varargout{3} = dz;
    end
end

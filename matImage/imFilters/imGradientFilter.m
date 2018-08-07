function varargout = imGradientFilter(img, varargin)
%IMGRADIENTFILTER Compute gradient components of a grayscale image
%
%   [DX, DY] = imGradientFilter(IMG);
%   [DX, DY, DZ] = imGradientFilter(IMG);
%   Compute the components of the gradient vector of a 2D or a 3D image.
%   The gradient is computed in each orthogonal direction by using
%   normalised Sobel filters. 
%   For a 2D image, gradient magnitude and angle can be computed from:
%   MAG = hypot(DX, DY);
%   ANGLE = atan2(DY, DX);
%
%   GRAD = imGradientFilter(IMG);
%   Compute the gradient magnitude. Magnitude is computed as:
%   - hypot(dx, dy) for 2D images
%   - hypot(hypot(dx, dy), dz) for 3D images
%
%   ... = imGradientFilter(IMG, SIGMA);
%   Specifies the width of the kernel (2D only). The size of the kernel is
%   determined automatically from the SIGMA.
%
%   ... = imGradientFilter(IMG, 'filter', FILTER);
%   Specifies the filter used for computing gradient in the X direction.
%   Note that fspecial('sobel') or fspecial('prewitt') return unnormalized
%   filters for the Y direction (horizontal gradient).
%
%   ... = imGradientFilter(..., OPTION1, OPTION2...);
%   Will use the given set of options when computing the gradient filter.
%   See the documentation of imfilter for details.
%   Default options are 'conv' and 'replicate'.
%
%   Example
%   % display edge strength computed on cameraman picture
%   img = imread('cameraman.tif');
%   grad = imGradientFilter(img);
%   imshow(grad, [0 max(grad(:))]);
%
%   % compute edge direction on rice picture
%   img = imread('rice.png');
%   [dx dy] = imGradientFilter(img);
%   grad = hypot(dx, dy);
%   theta = atan2(dy, dx);
%   rgb = angle2rgb(theta);     % convert to rgb
%   bin = grad>50;              % select only salient edges
%   rgb(~bin(:,:, [1 1 1])) = 0;% display salient edges orientation
%   imshow(rgb);
%
%   % Uses a different filter (the same as for the "gradient" function)
%   img = imread('cameraman.tif');
%   grad = imGradientFilter(img, 'filter', [1 0 -1]);
%   imshow(grad, [0 max(grad(:))]);
%
%   See also
%   imLaplacian, imMorphoGradient, imHessian, imRobinsonFilter,
%   imKirschFilter, imfilter, fspecial, angle2rgb, gradient

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2009-08-19,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% HISTORY
% 2010-01-13 add support for gradient direction and filter options
% 2010-02-16 change output format for 2 output parameters, add support
%   for 3D images, and add psb to change filter.
% 2010-03-03 use convolution by default
% 2010-03-05 return result as double, normalize default filter
% 2010-12-06 use 3D kernel by default for 3D images
% 2013-05-20 add support for variable kernel width (2D only)
% 2015-08-27 rename ti gradientFilter, update normalisation constants

%% Parse input arguments

% image dimension
dim = size(img);

% number of dimension of image (do not manage color images)
nd = length(dim);

% check if the width of the kernel is specified
sigma = 0;
if ~isempty(varargin) 
    var1 = varargin{1};
    if isnumeric(var1) && isscalar(var1)
        sigma = var1;
        varargin(1) = [];
    end
end

% parse verbosity option
verbose = false;
ind = find(strcmp(varargin, 'verbose'));
if ~isempty(ind) 
    if ind ~= length(varargin)
       verbose = varargin{ind+1};
       varargin(ind:ind+1) = [];
    end
end

% default filter for gradient: normalised sobel
if verbose
    disp('init kernels');
end
if nd <= 2
    if sigma == 0
        % Default 2D case: normalised sobel matrix
        sx = fspecial('sobel')'/8;
    else
        Nx = ceil((3*sigma));
        lx = -Nx:Nx;
        sy = exp(-((lx / sigma) .^2) * .5) / (sqrt(2*pi) * sigma);
        sx = -(lx / sigma) .* sy;
        sx = sy' * sx;
    end
    
elseif nd == 3
    if sigma == 0
        % Default 3D case: normalisation of 2 classical sobel matrices
        base = [1 2 1]' * [1 2 1];
        base = base / sum(base(:))/2;
        sx = permute(cat(3, base, zeros(3, 3), -base), [2 3 1]);
    else
        Nx = ceil((3*sigma));
        lx = -Nx:Nx;
        sy = exp(-((lx / sigma) .^2) * .5) / (sqrt(2*pi) * sigma);
        sx = -(lx / sigma) .* sy;
        sz = permute(sy, [3 1 2]);

        n = length(lx);
        tmp = zeros(n, n , n);
        for i = 1:n
            tmp(:,:,i) = sz(i) * sy' * sx;
        end
        sx = tmp;
    end
    
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
    if verbose
        disp('compute gradient along x direction');
    end
    dx = imfilter(double(img), sx, varargin{:});
    if verbose
        disp('compute gradient along y direction');
    end
    dy = imfilter(double(img), sx', varargin{:});
    
elseif nd == 3
    % Process 3D Image
    sy = permute(sx, [2 3 1]);
    sz = permute(sx, [3 1 2]);
    if verbose
        disp('compute gradient along x direction');
    end
    dx = imfilter(double(img), sx, varargin{:});
    if verbose
        disp('compute gradient along y direction');
    end
    dy = imfilter(double(img), sy, varargin{:});
    if verbose
        disp('compute gradient along z direction');
    end
    dz = imfilter(double(img), sz, varargin{:});
end


%% Format output

% Depending on number of output arguments, returns either the gradient
% module, or each component of the gradient vector.
if nargout == 1
    if verbose
        disp('compute gradient norm');
    end
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

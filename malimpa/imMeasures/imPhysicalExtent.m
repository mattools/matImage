function extent = imPhysicalExtent(img, varargin)
%IMPHYSICALEXTENT Compute the physical extent of an image
%
%   BOX = imPhysicalExtent(IMG)
%   Returns the physical extent of the image IMG, such that the display
%   will be contained within the extent. IMG can be either 2D or 3D image.
%
%   BOX = imPhysicalExtent(IMG, SPACING)
%   Computes the extent by taking into account the resolution of the image.
%   The resolution is given in X-Y-Z order (ie., SPACING(1) corresponds to
%   the resolution of the second dimension of IMG).
%
%   BOX = imPhysicalExtent(IMG, SPACING, ORIGIN)
%   Also takes into account the stack origin, i.e. the coordinates of the
%   first voxel expressed in user coordinates.
%   The origin is given in X-Y-Z order.
%
%   BOX = imPhysicalExtent(IMG, 'spacing', SPACING, 'origin', ORIGIN)
%   Uses a syntax based on parameter name-value pairs.
%
%   BOX = imPhysicalExtent(DIM, SPACING, ORIGIN)
%   Computes the physical extent based on the size of the stack. This
%   syntax can be used to avoid passing an array as parameter. DIM is given
%   in X-Y-Z order.
%
%
%   Example
%   % Compute physical extent of MRI Human head
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     box = imPhysicalExtent(I, [1 1 2.5])
%     box =
%         0.5000  128.5000    0.5000  128.5000    -0.2500   67.2500
%
%   See also
%     imSize
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


% size of image in each physical direction
sz = imSize(img);
% if length(dim) > 2
%     % compute size of the stack
%     sz = stackSize(img);
% else
%     % the size of the stack is given as input
%     sz = img;
% end

% default spacing and origin (matlab display convention)
nd = length(sz);
sp = ones(1, nd);
or = ones(1, nd);

% parse origin and spacing of the stack
if ~isempty(varargin)
    var = varargin{1};
    
    if isnumeric(var)
        % extract voxel spacing
        sp = var;
        
        if length(varargin) > 1
            % also extract voxel origin
            or = varargin{2};
        end
        
    elseif ischar(var)
        while length(varargin) > 2
            paramName = varargin{1};
            if strcmp(paramName, 'spacing')
                sp = varargin{2};
                
            elseif strcmp(paramName, 'origin')
                or = varargin{2};
                
            else
                error(['Unknown parameter: ' paramName]);
            end
        end
    end
end

% put extent in array
extent = (([zeros(nd, 1) sz'] - .5).* [sp' sp'] + [or' or'])';

% change array shape to get a single row
extent = extent(:)';

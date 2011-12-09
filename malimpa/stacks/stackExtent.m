function extent = stackExtent(img, varargin)
%STACKEXTENT Compute the physical extent of a 3D image
%
%   BOX = stackExtent(IMG)
%   Returns the physical extent of the 3D image IMG, such that the display
%   using slices will be contained within the extent.
%
%   BOX = stackExtent(IMG, SPACING)
%   Computes the extent by taking into account the resolution of the image.
%
%   Example
%   stackExtent
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


% size of image in each physical direction
sz = stackSize(img);

% default spacing and origin (matlab display convention)
sp = [1 1 1];
or = [1 1 1];

% parse origin and spacing of the stack
if ~isempty(varargin)
    var = varargin{1};
    
    if isnumeric(var)
        % extract voxel spacing
        sp = var;
        
        if length(varargin)>1
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
extent = (([zeros(3, 1) sz']-.5).* [sp' sp'] + [or' or'])';

% change array shape to get a single row
extent = extent(:)';

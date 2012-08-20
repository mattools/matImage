function res = imDistanceClasses(img, varargin)
%IMDISTANCECLASSES  Converts a distance map to a label image of regions
%
%   RES = imDistanceClasses(IMG, WIDTH)
%
%   Example
%   imDistanceClasses
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-08-10,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% default values of parameters
method = 'physical';
param = 10;

% process input arguments
if ~isempty(varargin)
    arg = varargin{1};
    if ischar(arg)
        method = arg;
        if nargin > 2
            param = varargin{2};
        end
    elseif isnumeric(arg)
        param = arg;
    end
end

% choose regions weight depending on method
switch lower(method)
    case 'physical'
        % width is given as parameter
        width = param;
        
    case 'normalised'
        % width is normalised with max distance
        maxi = max(img(isfinite(img)));
        width = maxi / param;
        
    otherwise 
        error('imDistanceClasses:UnknownMethod', ...
            ['Unknwon method name: ' method]);
end

% compute classes
res = ceil(img / width);

% process background
res(~isfinite(img)) = 0;

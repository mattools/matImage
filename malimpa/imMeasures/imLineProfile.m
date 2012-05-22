function varargout = imLineProfile(img, varargin)
%IMLINEPROFILE Evaluate image value along a line segment
%
%   VALS = imLineProfile(IMG, P1, P2)
%   Interpolates values within image between points P1 and P2.
%
%   VALS = imLineProfile(IMG, P1, P2, N)
%   Specifies the number of positions to use for evaluation.
%
%   [VALS PTS] = imLineProfile(...)
%   Also returns the position of the points used for the evaluation.
%
%   imLineProfile(...)
%   If no output is specified, evaluated values are plotted on the current
%   axis. 
%
%   Example
%     % Plot line profile of gray values in cameraman image
%     img = imread('cameraman.tif');
%     p1 = [10 200];
%     p2 = [200 200];
%     imLineProfile(img, p1, p2)
%
%   See also
%   imEvaluate, improfile
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

if isempty(varargin)
    error('requires input argument');
end

var = varargin{1};
if size(var, 1) == 1
    % points given as separate arguments
    p1 = varargin{1};
    p2 = varargin{2};
    varargin(1:2) = [];
    
else
    % case of points specified with a point array
    p1 = var(1, :);
    p2 = var(end, :);
    varargin(1) = [];
end

nValues = sqrt(sum((p2 - p1) .^ 2));
if ~isempty(varargin) && isnumeric(varargin{1})
    nValues = varargin{1};
    varargin(1) = [];
end

method = '*linear';
if ~isempty(varargin) && ischar(varargin{1})
    method = varargin{1};
end

% coordinate of interpolation points
x = linspace(p1(1), p2(1), nValues);
y = linspace(p1(2), p2(2), nValues);

% create point array
if ~is3DImage(img)
    pts = [x' y'];
else
    z = linspace(p1(3), p2(3), nValues);
    pts = [x' y' z'];
end

% extract corresponding pixel values (nearest-neighbor eval)
vals = imEvaluate(img, pts, method);

if nargout == 0
    % create cumulative array of distances for plotting
    dists = [0 cumsum(sqrt(sum(diff(pts, 1), 2)))'];

    % new figure for display
    figure;
    colors = get(gca, 'colororder');
    set(gca, 'colororder', colors([3 2 1 4:end], :));
    plot(dists, vals);

elseif nargout > 1
    % return evaluated values
    varargout{1} = vals;
    
else
    % return evaluated values with positions
    varargout = {vals, pts};
    
end

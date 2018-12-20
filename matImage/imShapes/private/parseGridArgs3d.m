function [lx, ly, lz, varargin] = parseGridArgs3d(varargin)
%PARSEGRIDARGS3D  Extract or compute position vectors for meshgrid
%
%   [LX, LY] = parseGridArgs3d(LX, LY)
%   simply returns LX and LY.
%
%   [LX, LY] = parseGridArgs3d([NX NY])
%   assumes LX = 1:NX and LY = 1:NY
%
%   [LX, LY] = parseGridArgs3d([NX NY])
%   assumes LX = 1:NX and LY = 1:NY
%
%
%   Example
%   [lx, ly, lz] = parseGridArgs3d([100 100 100]);
%   [lx, ly, lz] = parseGridArgs3d(1:2:50, 1:4:100, 1:25);
%   [lx, ly, lz, varargin] = parseGridArgs3d(varargin{:});
%   for usage within another function.
%
%   See also
%     parseGridArgs

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2009-05-29,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.


% If empty arguments, return default values
if isempty(varargin)
    lx = 1:100;
    ly = 1:100;
    lz = 1:100;
    return
end

var = varargin{1};

% case of a 2x3 matrix with starting position, increment, end position for
% each coordinate
if all(size(var) > [2 2])
    lx = var(1,1):var(1,2):var(1,3);
    ly = var(2,1):var(2,2):var(2,3);
    lz = var(3,1):var(3,2):var(3,3);
    varargin(1) = [];
    return;
end

% first argument contains maximal position for each coordinate
if all(size(var) == [1 3])
    lx = 1:var(1);
    ly = 1:var(2);
    lz = 1:var(3);
    varargin(1) = [];
    return;
end

% first and second arguments contain vector for each coordinate
% respectively
if length(varargin) > 2
    lx = varargin{1};
    ly = varargin{2};
    lz = varargin{3};
    varargin(1:3) = [];
    return
end

% otherwise, throws error
error('Error in parsing grid arguments');

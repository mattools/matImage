function installMatImage(varargin)
%INSTALLMATIMAGE Add the paths required for using MATIMAGE library
%
%   usage: 
%       installMatImage;
%   All the required directories are successively added, in appropriate
%   order to comply with dependencies.
%
%   Example
%   installMatImage
%
%   See also
%   matImage
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-01-17,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the modified BSD licence

% extract library path
fileName = mfilename('fullpath');
libDir = fileparts(fileName);

moduleNames = {...
    'util', ...
    'imFilters', ...
    'imMeasures', ...
    'imMinkowski', ...
    'imGeodesics', ...
    'imGranulometry', ...
    'imShapes', ...
    'imStacks'};

disp('Installing MatImage Library');
addpath(libDir);

% add all library modules
for i = 1:length(moduleNames)
    name = moduleNames{i};
    fprintf('Adding module: %-20s', name);
    addpath(fullfile(libDir, name));
    disp(' (done)');
end


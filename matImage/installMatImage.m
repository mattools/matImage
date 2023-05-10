function installMatImage(varargin)
%INSTALLMATIMAGE Add all the paths required for using the MATIMAGE library.
%
%   usage: 
%       installMatImage;
%   All the required directories are successively added, in appropriate
%   order to comply with dependencies.
%
%   Example:
%     installMatImage
%
%   See also
%     matImage
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2008-01-17,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the modified BSD licence

% The list of "modules" of the library, that correspond to the
% sub-directories from the main directory.
moduleNames = {...
    'imExplore', ...
    'imStacks', ...
    'imFilters', ...
    'imQuantify', ...
    'imMinkowski', ...
    'imGeodesics', ...
    'imGranulometry', ...
    'imShapes'};

% extract library base path
fileName = mfilename('fullpath');
libDir = fileparts(fileName);

% add the base path
disp('Installing the MatImage Library');
addpath(libDir);

% add each library module
for i = 1:length(moduleNames)
    name = moduleNames{i};
    fprintf('Adding module: %-20s', name);
    addpath(fullfile(libDir, name));
    fprintf(' (done)\n');
end

disp('Success: MatImage Library fully installed.');

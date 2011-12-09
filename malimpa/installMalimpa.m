function installImael(varargin)
%INSTALLIMAEL  Add the paths required for using IMAEL library
%
%   usage: 
%       installImael;
%   All the required directories are successively added, in appropriate
%   order to comply with dependencies.
%
%   Example
%   installImael
%
%   See also
%   imael
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-01-17,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"

% base directory of the library
p = pwd;

% general use toolboxe
addpath(fullfile(p, 'util'));

% generic modules (used by other modules)
addpath(fullfile(p, 'imFilters'));
addpath(fullfile(p, 'imMeasures'));

% specific modules
addpath(fullfile(p, 'imMinkowski'));
addpath(fullfile(p, 'imGeodesics'));

% generation of test shapes
addpath(fullfile(p, 'imShapes'));

% management of 3D images
addpath(fullfile(p, 'stacks'));


function installMalimpa(varargin)
%INSTALLMALIMPA Add the paths required for using MALIMPA library
%
%   usage: 
%       installMalimpa;
%   All the required directories are successively added, in appropriate
%   order to comply with dependencies.
%
%   Example
%   installMalimpa
%
%   See also
%   malimpa
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-01-17,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the modified BSD licence

% base directory of the library
p = fileparts(mfilename('fullpath'));

% The main path of the library
addpath(p);

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
addpath(fullfile(p, 'imStacks'));


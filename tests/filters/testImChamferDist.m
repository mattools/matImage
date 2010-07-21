function test_suite = testImChamferDist(varargin)
%TESTIMCHAMFERDIST  One-line description here, please.
%
%   output = testImChamferDist(input)
%
%   Example
%   testImChamferDist
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


initTestSuite;


%% Tests for Grayscale image 2D

function test_FiniteDistWithMarkerOutside %#ok<*DEFNU>

img = [...
    0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0; ...
    0 1 1 1 1 1 1 1 1 0; ...
    0 0 0 0 0 0 0 1 1  0; ...
    0 0 1 1 1 1 0 0 1 0; ...
    0 1 0 0 0 1 0 0 1 0; ...
    0 1 1 0 0 0 0 1 1 0; ...
    0 0 1 1 1 1 1 1 1 0; ...
    0 0 0 0 1 1 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0];
    
marker = false(size(img));
marker(2, 2) = 1;

dist = imChamferDistance(img, marker);
maxDist = max(dist(isfinite(dist)));

assertTrue(isfinite(maxDist));

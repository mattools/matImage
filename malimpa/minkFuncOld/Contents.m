% Measurements of geometric parameters in digital images
%
%   Most of these function are obsolete and will be removed in a later
%   version of the IMAEL Library.
%   Use with care, and check references (Books from Serra, Lang and
%   Ohser...) before trusting results.
%
% Various estimation functions:
%   epc2                 - EPC compute Euler-Poincare Characteristic (EPC) of a structure.
%   epcm                 - compute density of Euler-Poincare Characteristic (EPC) of a structure
%   epcmap               - create a map for computing the EPC value
%   epcMean              - estimate Euler-Poincare Charac with mean sampling
%   epcPlus              - estimate Euler-Poincare Charac with plus sampling
%   epcShell             - estimate Euler-Poincare Characteristic with shell-sampling
%   estEuler             - esimate Euler-Poincare Characteristic (EPC) of a structure.
%   estMeanBreadth       - estMeanBreadth : estimate mean breadth of a discretized set
%   estPerim             - estimate perimeter of a 2D structure
%   estPerimeter         - estimate surface measure of a discretized 3D set
%   estSurface           - estimate surface measure of a discretized 3D set
%
% Processing based on LUT:
%   euler3dLutC26        - create a Look-Up Table for computing 3D Euler-Poincare measure
%   euler3dLutC6         - One-line description here, please.
%   createConfig         - create a 2x2x2 configuration from label
%   createEpcTab3d       - create a table of valued for computing 3D EPC values.
%   createMeanBreadthTab - create a table of valued for computing mean breadth
%   createSurfTab        - create a Look-up-Table for computing surface contributions
%
% Estimate several Minkowski functionals in one function:
%   minkmap              - create a map for computing the Minkowski measures
%   minkmap2             - create a map for computing the Minkowski measures
%   minkMean             - estimate Minkowski densities of a random structure
%   minkowski            - computes Minkowski measure of a structure
%   minkPlus             - estimate Minkowski densities with plus-sampling
%   minkProfile          - estimate minkowski densities along image
%   minkShell            - estimate Minkowski densities of a random structure
%
%   Profile of parameters:
%   surfaceProfile       - compute surface density profile
%
% -----
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the  07/11/2005.
% Copyright INRA - Cepia Software Platform.
% http://www.pfl-cepia.inra.fr/index.php?page=imael
% Licensed under the terms of the BSD License, see the file license.txt
 
% display help if executed
help Contents




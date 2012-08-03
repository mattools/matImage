function res = ensureDirExists(dirName)
%ENSUREDIREXISTS Create a directory if it does not exist
%
%   ensureDirExists(DIRNAME)
%   Checks if the directory DIRNAME exists. If not, creates it.
%
%   RES = ensureDirExists(DIRNAME)
%   Returns an info flag. RES = 0 if directory did not exist, and 1 if it
%   existed.
%
%   See also
%   mkdir, exist
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

res = 1;

if ~exist(dirName, 'dir')
    mkdir(dirName);
    res = 0;
end

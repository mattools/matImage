function runAllTests(varargin)
%RUNALLTESTS  Explore all subdirectories, and run 'runtests' function
%
%   output = runAllTests(input)
%
%   Example
%   runAllTests
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

list = dir('.');

for i = 1:length(list)
    if ~list(i).isdir
        continue;
    end
    
    name = list(i).name;
    if length(name) < 3
        continue;
    end
        
    disp(['Running tests for directory: ' name]);
    
    cd(name);
    runtests;
    cd('..');
end

    
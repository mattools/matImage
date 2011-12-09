function varargout = cleanGraph(nodes, edges)
%CLEANGRAPH return a 'cleaned' graph.
%
%   See also : removeMultiplePoints, removeDoubleEdges, simplifyLines
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation

[nodes edges] = removeMultiplePoints(nodes, edges);
[nodes edges] = removeDoubleEdges(nodes, edges);
[nodes edges] = simplifyLines(nodes, edges);


% process output depending on how many arguments are needed
if nargout == 1
    out{1} = nodes;
    out{2} = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout{1} = nodes;
    varargout{2} = edges;
end

return;

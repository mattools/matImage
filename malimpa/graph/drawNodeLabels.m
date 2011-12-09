function varargout = drawNodeLabels(p, value)
%DRAWNODELABELS draw values associated to graph nodes
% 
%   usage :
%   drawNodeLabels(NODES, VALUES);
%   NODES : array of double, containing x and y values of nodes
%   VALUES is an array the same length of EDGES, containing values
%   associated to each edges of the graph.
%
%   The function computes the center of each edge, and puts the text with
%   associated value.
%   
%   H = drawNodeLabels(...) return array of handles to each text structure,
%   making possible to change font, color, size
%
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2003.
%

%   HISTORY
%   10/03/2004 : included into lib/graph library


if length(p)>1
    h = zeros(length(p),1);
    hold on;
    if size(p, 2)==2
        for i=1:size(p, 1)
            x = p(i,1);
            y = p(i,2);
            h(i) = text(x, y, sprintf('%3d', floor(value(i))));
        end
    elseif size(p, 2)==3
        for i=1:size(p, 1)
            x = p(i,1);
            y = p(i,2);
            z = p(i,3);
            h(i) = text(x, y, z, sprintf('%3d', floor(value(i))));
        end
    end
end

if nargout==1
    varargout(1) = {h};
end
    
return;
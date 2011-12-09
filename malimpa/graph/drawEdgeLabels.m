function varargout = drawEdgeLabels(p, e, value)
%DRAWEDGELABELS draw values associated to graph edges
% 
%   usage :
%   drawEdgeLabels(NODES, EDGES, VALUES);
%   NODES : array of double, containing x and y values of nodes
%   EDGES : array of int, containing indices of in and out nodes
%   VALUES is an array the same length of EDGES, containing values
%   associated to each edges of the graph.
%
%   The function computes the center of each edge, and puts the text with
%   associated value.
%   
%   H = drawEdgeLabels(...) return array of handles to each text structure,
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


if length(p)>1 && length(e)>1
    h = zeros(length(e),1);
    hold on;
    for l=1:length(e)
        p1 = e(l, 1);
        p2 = e(l, 2);
        %h(l) = line([p(p1,1) p(p2,1)], [p(p1,2) p(p2,2)]);
        line([p(p1,1) p(p2,1)], [p(p1,2) p(p2,2)]);
        xm = (p(p1,1) + p(p2,1))/2;
        ym = (p(p1,2) + p(p2,2))/2;
        %set(h(l), 'color', 'green', 'linestyle', '--');
        h(l) = text(xm, ym, sprintf('%3d', floor(value(l))));
    end
end

if nargout==1
    varargout(1) = {h};
end
    
return;
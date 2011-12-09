function diam = graphDiameter(v, e, l)
%GRAPHDIAMETER Diameter of a graph
%
%   D = graphDiameter(V, E)
%   Computes the diameter of the graph given by V and E. The diameter of
%   the graph is the greatest eccentricity over all vertices in the graph.
%
%   CENTER = graphCenter(V, E, L)
%   Specifies the weight of each edge for computing the distances. Default
%   is to consider a weight of 1 for each edge.
%
%   Example
%   graphDiameter
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-09-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% ensure there is a valid length array
if nargin<3
    l = ones(size(e,1), 1);
end

g = grVertexEccentricity(v, e, l);

diam = max(g);

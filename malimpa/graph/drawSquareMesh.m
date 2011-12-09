function varargout = drawSquareMesh(nodes, edges, faces)
%DRAWSQUAREMESH transform 3D graph (mesh) into patch
%
%   DRAWSQUAREMESH(NODES, EDGES, FACES)
%   Draw the mesh defined by NODES, EDGES and FACES.
%
%   See Also :
%   imPatch, boundaryGraph, drawGraph
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%

Nf = size(faces, 1);

px=zeros(Nf, 1);
py=zeros(Nf, 1);
pz=zeros(Nf, 1);

for f=1:size(faces, 1)
    face = faces(f, 1:4);
    px(1:4, f) = nodes(face, 1);
    py(1:4, f) = nodes(face, 2);
    pz(1:4, f) = nodes(face, 3);
end
p = patch(px, py, pz, 'r');

if nargout>0
    varargout{1}=p;
end
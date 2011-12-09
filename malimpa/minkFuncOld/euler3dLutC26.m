function lut = euler3dLutC26(delta, pos)
%EULER3DLUTC26 create a Look-Up Table for computing 3D Euler-Poincare measure
%   output = euler3dLutC26(input)
%
%   Example
%   lut = euler3dLutC26([1 1 1], 14);
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-02-23
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

coord = [1 1 1;1 2 1;2 1 1;2 2 1;1 1 2;1 2 2;2 1 2;2 2 2];
lut=zeros(256, 1); ind=contributingVoxels(pos);

for i=1:256
    im = createTile(i); voxels = find(im([1 3 2 4 5 7 6 8]));
    coords = coord(voxels, :);
    
    for j=1:length(ind)
        indJ=ind(j); coordJ=coord(indJ,:);        
        if ~im(coordJ(1), coordJ(2), coordJ(3)), continue; end
        ind2 = find(voxels==indJ);
        
        if isCoplanar(coords)        
            n = length(voxels);
            if n==3
                ii = find(voxels==indJ); ip=mod(ii+1,3)+1; in=mod(ii,3)+1;
                pts = coords([ip ii in], :);
                kf  = (pi-angle3d(pts.*repmat(delta, [3 1])))/(2*pi);
                mFace = power(2, sum(sum(abs(diff(pts)))==0)>0);
                ke1 = (1/2)/power(2, sum(coordJ==coords(ip,:)));
                ke2 = (1/2)/power(2, sum(coordJ==coords(in,:)));
                lut(i) = lut(i) + 1/8 - (ke1+ke2) + kf/mFace;
            elseif n==2
                mEdge = power(2, sum(coords(1,:) == coords(2,:)));
                lut(i) = lut(i) + 1/8 - 1/mEdge/2;               
            elseif n==1
                lut(i) = lut(i) + 1/8;
            end
        else
            hull = convhulln(coords);   % determines faces of convex hull
            indf = find(sum(ismember(hull, ind2), 2)); 
            neigh=[]; nFaces=length(indf);
            
            alpha   = zeros(nFaces,1);
            mFaces  = zeros(nFaces,1);
            
            % compute angle and multiplicity of each face
            for k=1:nFaces          
                face = hull(indf(k), :);
                ii=find(face==ind2); ip=mod(ii, 3)+1; in=mod(ii+1,3)+1;
                pts = coords(face([ip ii in]), :);
                alpha(k) = angle3d(pts.*repmat(delta, [3 1]));
                mFaces(k) = power(2, sum(sum(abs(diff(pts)))==0)>0);
                neigh = unique([neigh face([ip in])]);               
            end
            
            mEdges = power(2, ...      % compute edge multiplicities
                sum(repmat(coordJ,[nFaces 1]) == coords(neigh, :), 2));
            lut(i) = lut(i) + 1/8 - (1/2)*sum(1./mEdges) + ...
                 sum((pi-alpha)./(mFaces*2*pi))-(2*pi-sum(alpha))/(4*pi);
        end
     end
 end
   
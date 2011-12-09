function lut = euler3dLutC6(delta, pos) %#ok<INUSL>
%EULER3DLUTC6  One-line description here, please.
%   output = euler3dLutC6(input)
%
%   Example
%   euler3dLutC6
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
lut=zeros(256, 1);
ind=contributingVoxels(pos);

for i=1:256
    im = createTile(i);
    
    lut(i)=0;
    for j=1:length(ind);  % loop for each voxel of configuration
        p1=coord(ind(j), 1);
        p2=coord(ind(j), 2);
        p3=coord(ind(j), 3);

        if ~im(p1, p2, p3)
            continue; 
        end

        % check for a cube
        n = sum(im(:));
        if n==8
            ks=1/8;
        else
            ks=0;
        end

        % check for isothetic faces
        kf = 0;
        if im(3-p1,p2,p3) && im(p1,3-p2,p3) && im(3-p1,3-p2,p3)
            kf = kf+1/4;
        end
        if im(3-p1,p2,p3) && im(p1,p2,3-p3) && im(3-p1,p2,3-p3)
            kf = kf+1/4;
        end
        if im(p1,3-p2,p3) && im(p1,p2,3-p3) && im(p1,3-p2,3-p3)
            kf = kf+1/4;
        end
        
        % check for isothetic edges
        ke = 0;
        if im(3-p1, p2, p3), ke = ke+1/2; end
        if im(p1, 3-p2, p3), ke = ke+1/2; end
        if im(p1, p2, 3-p3), ke = ke+1/2; end

        % add contribution of voxel, using multiplicities of cells
        lut(i) = lut(i) + 1/8 - ke/4 + kf/2 - ks;
    end  
 end
   
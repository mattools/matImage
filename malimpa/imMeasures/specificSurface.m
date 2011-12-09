function surf = specificSurface(img, varargin)
%SPECIFICSURFACE implementation of Ohser's algo for surface comput.
%
%   compute surface area in discrete images.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2005.
%

%   HISTORY 

img = img~=0;

delta = [1 1 1];

% edges of the unit cell
kl = [1 2;1 3;1 5;1 4;2 3;1 6;2 5;1 7;3 5;1 8;2 7;3 6;4 5];

% unit surface for each cell
c1 = 0.045778;
c2 = 0.036981;
c3 = 0.035196;
c = [c1 c1 c1   c2 c2 c2   c2 c2 c2   c3 c3 c3 c3];

% distances between pixels
d12 = sqrt(delta(1)*delta(1) + delta(2)*delta(2));
d13 = sqrt(delta(1)*delta(1) + delta(3)*delta(3));
d23 = sqrt(delta(2)*delta(2) + delta(3)*delta(3));
d123 = sqrt(sum(delta.*delta));
r = [delta(1) delta(2) delta(3) d12 d12 d13 d13 d23 d23 d123 d123 d123 d123];


% compute gray-tone histogram of the image
h = grayHist(img);


sv = 0;

% for each type of configuration
for l=1:256
    
    v = l-1;
    b(1) = bitand(v,1)~=0;
    b(2) = bitand(v,2)~=0;
    b(3) = bitand(v,4)~=0;
    b(4) = bitand(v,8)~=0;
    b(5) = bitand(v,16)~=0;
    b(6) = bitand(v,32)~=0;
    b(7) = bitand(v,64)~=0;
    b(8) = bitand(v,128)~=0;

    % for each edge of configuration
    for nu=1:13
        sv = sv + h(l)*c(nu)/r(nu)*xor( b(kl(nu, 1)), b(kl(nu,2)) );
    end
end




surf = 4*sv/sum(h(:));
function imc = specificIntMeanCurv(img, varargin)
%SPECIFICINTMEANCURV Ohser's Integral of Mean Curvature
%
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

% square faces of the unit cell
kr = [...
    1 2 3 4;...
    1 2 5 6;...
    1 3 5 7;...
    1 2 7 8;...
    3 5 4 6;...
    1 6 3 8;...
    2 4 5 7;...
    2 3 6 7;...
    1 5 3 8];

% triangle faces of the unit cell
kt = [...
    1 7 6;...
    2 5 8;...
    4 7 6;...
    3 5 8;...
    2 3 8;...
    4 1 7;...
    2 3 5;...
    4 1 6];

    
% unit surface for each cell
c1 = 0.045778;
c2 = 0.036981;
c3 = 0.035196;
c = [c1 c1 c1   c2 c2 c2   c2 c2 c2   c3 c3 c3 c3];

% distances between pixels
d1 = delta(1);
d2 = delta(2);
d3 = delta(3);
d12  = sqrt(delta(1)*delta(1) + delta(2)*delta(2));
d13  = sqrt(delta(1)*delta(1) + delta(3)*delta(3));
d23  = sqrt(delta(2)*delta(2) + delta(3)*delta(3));
s = (d12 + d23 + d13)/2;
a123 = 2*sqrt(s*(s-d12)*(s-d13)*(s-d23));

a = [d1*d2 d1*d3 d2*d3   d3*d12 d3*d12 d2*d13 d2*d13 d1*d23 d1*d23  a123 a123 a123 a123];



% compute gray-tone histogram of the image
h = grayHist(img);

mv = 0;

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
    
    % for each square face
    for nu=1:9        
        
        b1 = b(kr(nu, 1));
        b2 = b(kr(nu, 2));
        b3 = b(kr(nu, 3));
        b4 = b(kr(nu, 4));

        s = sum([b1 b2 b3 b4]);
        if s==1
            mv = mv + h(l)*c(nu)/4/a(nu);
        elseif s==3
            mv = mv - h(l)*c(nu)/4/a(nu);
        end
    end
    
    % for each triangular face
    for nu=10:13
        
        b1 = b(kt(nu-9, 1));
        b2 = b(kt(nu-9, 2));
        b3 = b(kt(nu-9, 3));
        b4 = b(kt(nu-5, 1));
        b5 = b(kt(nu-5, 2));
        b6 = b(kt(nu-5, 3));

        s1 = sum([b1 b2 b3]);
        s2 = sum([b4 b5 b6]);
        if s1==1
            mv = mv + h(l)*c(nu)/3/a(nu);
        end
        if s2==2
            mv = mv - h(l)*c(nu)/3/a(nu);
        end
    end
end

imc = 4*pi*mv/sum(h(:));

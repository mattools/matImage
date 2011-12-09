function tab = createMeanBreadthTab(varargin)
%CREATEMEANBREADTHTAB create a table of valued for computing mean breadth
%
%   TAB = createMeanBreadthTab
%   return an array of size 256, whgich can be used with function imLUT to
%   create map of contributin to the mean breadth density
%   (also call 'integral of mean curvature')
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/03/2005.
%

%   HISTORY
%   01/03/2006 : result was wrong, correct it.


conn = 6;
if ~isempty(varargin)
    conn = varargin{1};
end

delta = [1 1 1];
if length(varargin)>1
    delta = varargin{2};
end

% distance between a pixel and its neighbours.
% di refer to orthogonal neighbours
% dij refer to neighbours on the same plane
% dijk refer to the opposite pixel in a tile
d1  = delta(1);
d2  = delta(2);
d3  = delta(3);
d12 = sqrt(delta(1)^2 + delta(2)^2);
d13 = sqrt(delta(1)^2 + delta(3)^2);
d23 = sqrt(delta(2)^2 + delta(3)^2);
vol = d1*d2*d3;

% area of elementary profiles
a1 = d2*d3;
a2 = d1*d3;
a3 = d1*d2;
a4 = d3*d12;
a5 = d2*d13;
a6 = d1*d23;
s  = (d12+d13+d23)/2;
a7 = 2*sqrt( s*(s-d12)*(s-d13)*(s-d23) );

N = 2^(2*2*2); %=256
tab = zeros(N, 1);
im = zeros(2,2,2);

if conn==6
    for i=1:N
        v = i-1;
        im(1,1,1) = bitand(v,1)~=0;
        im(1,2,1) = bitand(v,2)~=0;
        im(2,1,1) = bitand(v,4)~=0;
        im(2,2,1) = bitand(v,8)~=0;
        im(1,1,2) = bitand(v,16)~=0;
        im(1,2,2) = bitand(v,32)~=0;
        im(2,1,2) = bitand(v,64)~=0;
        im(2,2,2) = bitand(v,128)~=0;
        
        % first compute number of intersections in the 3 main directions

        % total number of vertices in image
        n = sum(im(:));

        % count number of intersections in all directions
        e1 = sum(sum(sum(im(1,:,:) & im(2,:,:))));
        e2 = sum(sum(sum(im(:,1,:) & im(:,2,:))));
        e3 = sum(sum(sum(im(:,:,1) & im(:,:,2))));

        % count number of square faces in all directions
        f1 = sum(sum(sum( ...
            im(:,1,1) & im(:,1,2) & im(:,2,1) & im(:,2,2) )));
        f2 = sum(sum(sum( ...
            im(1,:,1) & im(1,:,2) & im(2,:,1) & im(2,:,2) )));
        f3 = sum(sum(sum( ...
            im(1,1,:) & im(1,2,:) & im(2,1,:) & im(2,2,:) )));
        
        % Express EPC in each discrete plane, and divide by multiplicity.
        D1 = n/8 - (e2 + e3)/4 + f1/2;
        D2 = n/8 - (e1 + e3)/4 + f2/2;
        D3 = n/8 - (e1 + e2)/4 + f3/2;
        % Then, average on the 3 directions, and rearrange terms :
        tab(i) = (D1*d1 + D2*d2 + D3*d3)/3;
        
        % For orthonormal case, d1=d2=d3, and it is possible to rearrange
        % terms :         
        % tab(i) = n/8 + (-e1 - e2 - e3 + f1 + f2 + f3)/6;
    end


else

    % 'magical numbers', corresponding to area of voronoi partition on the
    % unit sphere, when germs are the 26 directions in the cube
    % Sum of 6*c1+12*c2+8*c3 equals 1.
    c1 = 0.0457778912 * 2;
    c2 = 0.0369806279 * 2;
    c3 = 0.0351956398 * 2;

    for i=1:N
        v = i-1;
        im(1,1,1) = bitand(v,1)~=0;
        im(1,2,1) = bitand(v,2)~=0;
        im(2,1,1) = bitand(v,4)~=0;
        im(2,2,1) = bitand(v,8)~=0;
        im(1,1,2) = bitand(v,16)~=0;
        im(1,2,2) = bitand(v,32)~=0;
        im(2,1,2) = bitand(v,64)~=0;
        im(2,2,2) = bitand(v,128)~=0;
        
        % total number of vertices in image
        n = sum(im(:));

        % count number of intersections in all directions
        e1 = sum(sum(sum(im(1,:,:) & im(2,:,:))));
        e2 = sum(sum(sum(im(:,1,:) & im(:,2,:))));
        e3 = sum(sum(sum(im(:,:,1) & im(:,:,2))));
        
        % check the 6 directions orthogonal to only one axis
        e4 = sum(sum(sum(im(1, 1, :) & im(2, 2, :) ))) ;
        e5 = sum(sum(sum(im(1, 2, :) & im(2, 1, :) ))) ;
        e6 = sum(sum(sum(im(1, :, 1) & im(2, :, 2) ))) ;
        e7 = sum(sum(sum(im(1, :, 2) & im(2, :, 1) ))) ;
        e8 = sum(sum(sum(im(:, 1, 1) & im(:, 2, 2) ))) ;
        e9 = sum(sum(sum(im(:, 1, 2) & im(:, 2, 1) ))) ;


        % count number of square faces in all directions
        f1 = sum(sum(sum( ...
            im(:,1,1) & im(:,1,2) & im(:,2,1) & im(:,2,2) )));
        f2 = sum(sum(sum( ...
            im(1,:,1) & im(1,:,2) & im(2,:,1) & im(2,:,2) )));
        f3 = sum(sum(sum( ...
            im(1,1,:) & im(1,2,:) & im(2,1,:) & im(2,2,:) )));
        
        % count number of square faces in 6 directions orthogonal to one axis
        f4 = sum(sum(sum( ...
            im(1,2,1) & im(2,1,1) & im(2,1,2) & im(1,2,2) )));
        f5 = sum(sum(sum( ...
            im(1,1,1) & im(1,1,2) & im(2,2,1) & im(2,2,2) )));

        f6 = sum(sum(sum( ...
            im(2,1,1) & im(1,1,2) & im(2,2,1) & im(1,2,2) )));
        f7 = sum(sum(sum( ...
            im(1,1,1) & im(2,1,2) & im(1,2,1) & im(2,2,2) )));

        f8 = sum(sum(sum( ...
            im(1,1,2) & im(1,2,1) & im(2,1,2) & im(2,2,1) )));
        f9 = sum(sum(sum( ...
            im(1,1,1) & im(1,2,2) & im(2,1,1) & im(2,2,2) )));

        % number of triangular faces orthogonal to the 4 cube diagonals
        fa = sum(sum(sum( im(2, 1, 2) & im(1, 2, 2) & im(2, 2, 1) ))) + ...
             sum(sum(sum( im(2, 1, 1) & im(1, 1, 2) & im(1, 2, 1) ))) ;

        fb = sum(sum(sum( im(1, 1, 2) & im(2, 2, 2) & im(1, 2, 1) ))) + ...
             sum(sum(sum( im(2, 1, 2) & im(2, 2, 1) & im(1, 1, 1) ))) ;

        fc = sum(sum(sum( im(1, 1, 1) & im(2, 1, 2) & im(1, 2, 2) ))) + ...
             sum(sum(sum( im(2, 1, 1) & im(2, 2, 2) & im(1, 2, 1) ))) ;

        fd = sum(sum(sum( im(1, 1, 1) & im(2, 2, 1) & im(1, 2, 2) ))) + ...
             sum(sum(sum( im(1, 1, 2) & im(2, 1, 1) & im(2, 2, 2) ))) ;

        % Compute equivalent diameter in each discrete direction        
        D1 = n/8 - (e2 + e3)/4 + f1/2;
        D2 = n/8 - (e1 + e3)/4 + f2/2;
        D3 = n/8 - (e1 + e2)/4 + f3/2;
        
        D4 = n/8 - e5/2 - e3/4 + f4;
        D5 = n/8 - e4/2 - e3/4 + f5;
        D6 = n/8 - e7/2 - e2/4 + f6;
        D7 = n/8 - e6/2 - e2/4 + f7;
        D8 = n/8 - e9/2 - e1/4 + f8;
        D9 = n/8 - e8/2 - e1/4 + f9;

        Da = n/8 - (e5 + e7 + e9)/2 + fa;
        Db = n/8 - (e4 + e6 + e9)/2 + fb;
        Dc = n/8 - (e4 + e7 + e8)/2 + fc;
        Dd = n/8 - (e5 + e6 + e8)/2 + fd;

        % Discretization of Crofton formula, using diameters previously computed
        tab(i) = c1*vol*(D1/a1 + D2/a2 + D3/a3) + ...
                 c2*vol*( (D4+D5)/a4 + (D6+D7)/a5 + (D8+D9)/a6 ) + ...
                 c3*vol*(Da + Db + Dc + Dd)/a7;
               
    end
    
end
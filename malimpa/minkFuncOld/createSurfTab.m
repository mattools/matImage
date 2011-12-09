function tab = createSurfTab(varargin)
%CREATESURFTAB create a Look-up-Table for computing surface contributions
%
%   TAB = createSurfTab
%   return an array of size 256, whgich can be used with function imLUT to
%   create map of contributin to the surface density
%
%   TAB = createSurfTab(CONN)
%   Also specify connectivity, can be either 6 or 26.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/03/2005.
%


conn = 6;
if ~isempty(varargin)
    conn = varargin{1};
end


N = 2^(2*2*2); %=256
tab = zeros(N, 1);
im = zeros(2,2,2);

if conn==6
    for i=1:N
        v = i-1;
        im(1,1,1) = bitand(v,1)~=0;
        im(1,1,2) = bitand(v,2)~=0;
        im(1,2,1) = bitand(v,4)~=0;
        im(1,2,2) = bitand(v,8)~=0;
        im(2,1,1) = bitand(v,16)~=0;
        im(2,1,2) = bitand(v,32)~=0;
        im(2,2,1) = bitand(v,64)~=0;
        im(2,2,2) = bitand(v,128)~=0;

        n1 = sum(sum(sum(im(1,:,:) ~= im(2,:,:)))) ;
        n2 = sum(sum(sum(im(:,1,:) ~= im(:,2,:)))) ;
        n3 = sum(sum(sum(im(:,:,1) ~= im(:,:,2)))) ;

        tab(i) = mean([n1 n2 n3])/2;
    end


elseif conn==26

    % 'magical numbers', corresponding to area of voronoi partition on the
    % unit sphere, when germs are the 26 directions in the cube
    % Sum of 6*c1+12*c2+8*c3 equals 1.
    c1 = 0.04577789120476 * 2;
    c2 = 0.03698062787608 * 2;
    c3 = 0.03519563978232 * 2;
%   c = [c1 c1 c1   c2 c2 c2   c2 c2 c2   c3 c3 c3 c3];

    % line density for 2D diagonal and 3D diagonal
    d2 = 1/sqrt(2);
    d3 = 1/sqrt(3);

    for i=1:N
        v = i-1;
        im(1,1,1) = bitand(v,1)~=0;
        im(1,1,2) = bitand(v,2)~=0;
        im(1,2,1) = bitand(v,4)~=0;
        im(1,2,2) = bitand(v,8)~=0;
        im(2,1,1) = bitand(v,16)~=0;
        im(2,1,2) = bitand(v,32)~=0;
        im(2,2,1) = bitand(v,64)~=0;
        im(2,2,2) = bitand(v,128)~=0;

        % first compute number of intersections in the 3 main directions
        n1 = sum(sum(sum(im(1,:,:) ~= im(2,:,:)))) ;
        n2 = sum(sum(sum(im(:,1,:) ~= im(:,2,:)))) ;
        n3 = sum(sum(sum(im(:,:,1) ~= im(:,:,2)))) ;

        
        % check the 6 directions orthogonal to only one axis
        n4 = sum(sum(sum(im(1, 1, :) ~= im(2, 2, :) ))) ;
        n5 = sum(sum(sum(im(1, 2, :) ~= im(2, 1, :) ))) ;
        n6 = sum(sum(sum(im(1, :, 1) ~= im(2, :, 2) ))) ;
        n7 = sum(sum(sum(im(1, :, 2) ~= im(2, :, 1) ))) ;
        n8 = sum(sum(sum(im(:, 1, 1) ~= im(:, 2, 2) ))) ;
        n9 = sum(sum(sum(im(:, 1, 2) ~= im(:, 2, 1) ))) ;


        % then check the 4 diagonal directions  (count from a to d, as in
        % hexadecimal form)
        na = sum(sum(sum(im(1, 1, 1) ~= im(2, 2, 2) ))) ;
        nb = sum(sum(sum(im(1, 1, 2) ~= im(2, 2, 1) ))) ;
        nc = sum(sum(sum(im(1, 2, 1) ~= im(2, 1, 2) ))) ;
        nd = sum(sum(sum(im(1, 2, 2) ~= im(2, 1, 1) ))) ;

        tab(i) = 2*( (n1+n2+n3)*c1/4 + (n4+n5+n6+n7+n8+n9)*c2*d2/2 + (na+nb+nc+nd)*c3*d3);
        
    end
else
    error 'sorry, unknown connectivity number'
end
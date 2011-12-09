function perim = estPerimeter(img, varargin)
%ESTPERIMETER estimate surface measure of a discretized 3D set
%
%
%   usage :
%   S = estPerimeter(IMG);
%   return an estimate of the perimeter of the image, computed by
%   counting intersections with 2D lines, and using discretized version of
%   the Crofton formula.
%
%   S = estPerimeter(IMG, CONN);
%   Specify connectivity to use. Either 4 or 8.
%
%   S = estPerimeter(IMG, SCALE, CONN);
%   Also specify scale of image tile. SCALE si a 2x1 array.
%   
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/07/2005.
%

%   HISTORY
%   09/08/2006 : add support for scale


img = squeeze(img>0);

if ndims(img)~=2
    error('first argument should be a 2D binary array');
end

conn=4;
if ~isempty(varargin)
    conn = varargin{end};
end

delta = [1 1];
if length(varargin)>1
    delta = varargin{1};
end


% distance between a pixel and its neighbours.
d1  = delta(1);
d2  = delta(2);
d12 = sqrt(delta(1)^2 + delta(2)^2);
vol = d1*d2;

% size of image
dim = size(img);
D1 = dim(1);
D2 = dim(2);


% first compute number of intersections in the 2 main directions
n1 = sum(sum(img(1:D1-1,:) ~= img(2:D1,:)));
n2 = sum(sum(img(:,1:D2-1) ~= img(:,2:D2)));

% compute for 4 closest neighbours
if conn==4
    perim = mean([n1*d2 n2*d1])*pi/2;
    return;
end


% check the 2 diagonal directions
n3 = sum(sum(img(1:D1-1, 1:D2-1) ~= img(2:D1, 2:D2)   )) ;
n4 = sum(sum(img(1:D1-1, 2:D2  ) ~= img(2:D1, 1:D2-1) )) ;

% average over directions
perim = mean([n1*d2 n2*d1 [n3 n4]*vol/d12])*pi/2;


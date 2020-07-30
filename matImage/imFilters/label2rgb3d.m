function rgb = label2rgb3d(img, varargin)
% Convert a 3D label image to a 3D RGB image.
%
%   RGB = label2rgb(LBL);
%   returns a Nx*Ny*3*Nz array, and assign a unique color in RGB for each
%   value of LBL image.
%
%   RGB = label2rgb(LBL, MAP) 
%   uses the colormap MAP. By default, the matlab colorcube algorithm is
%   used.
%
%   RGB = label2rgb(LBL, MAP, BGCOLOR)
%   Also specifies the background color as a 1-by-3 array representing the
%   color, with values between 0 and 1.
%
%   See also: 
%     label2rgb, bwlabeln, watershed, colorcube
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/12/2003.
%

%   HISTORY :
%   12/12/2003 now use same color for each label, but is slower ...
%   22/03/2004 small bug corrected : when img is uint16, it was not
%   working...
%   21/12/2005 add possibility tu specify colormap 

%   note (20/04/2004): could use ind2rgb, but maybe output need to be
%   converted, and need to check if faster or not.

% identifies max label within label image
N = double(max(img(:)));

% create map (colorcube, with white background)
map = colorcube(N + 1);
if ~isempty(varargin)
    var = varargin{1};
    if size(var, 1) >= N && size(var, 2) == 3
        map = var;
        varargin(1) = [];
    end
end

bgColor = [1 1 1];
if ~isempty(varargin)
    bgColor = varargin{1};
end

% create each channel
dim = [size(img, 1) size(img, 2) 1 size(img, 3)]; 
r = ones(dim, 'uint8') * 255 * bgColor(1);
g = ones(dim, 'uint8') * 255 * bgColor(2);
b = ones(dim, 'uint8') * 255 * bgColor(3);

for label = 1:N
    inds = find(img==label);
    r(inds) = 255*map(label, 1);
    g(inds) = 255*map(label, 2);
    b(inds) = 255*map(label, 3);
end
 
% build the result 3D color image
rgb = cat(3, r, g, b);

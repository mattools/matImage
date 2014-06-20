function res = imLUT(img, lut)
%IMLUT apply a lut to a gray-scale image.
%
%   IM2 = imLUT(IMG, LUT).
%   IMG is a gray-scale image, 1, 8 or 16 bits image, LUT is a double array
%   with 2**Nbits elements.
%   Each element x in IMG will by replaced by the value of the (x+1)-th
%   element in the LUT. 
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/10/2004.
%

%   HISTORY

res = zeros(size(img));
for i=0:length(lut)-1
    res(img==i) = lut(i+1);
end
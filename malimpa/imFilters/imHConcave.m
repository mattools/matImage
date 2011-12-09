function res = imHConcave(image, threshold)
% H-concave transformation of an image
% H-concave transformation is defined by substracting an
% image from the h-minima of the original image
%
% author : Gaetan Lehmann
% Wed Mar 23 14:01:13 CET 2005
%
hmin = imhmin(image, threshold);
res = imsubtract( hmin, image);

function res = imHConvex(image, threshold)
% H-convex transformation of an image
%
% H-convex transformation is defined by substracting the h-maxima of an
% image from the original image
%
% author : Gaetan Lehmann
% Wed Mar 23 14:01:13 CET 2005
%
hmax = imhmax(image, threshold);
res = imsubtract( image, hmax);

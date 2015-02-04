function res = subsamplergb(src, scale)
%SUBSAMPLERGB Return a sub-sampled version of an rgb image.
%
%   TAB2 = subsamplergb(TAB, N);
%   Returns matrix of dimension size(TAB)/N. Each value of result is the
%   max value of corresponding area in the input image.
%
%   Example:
%   TAB2 = subsamplergb(TAB, 4);
%   will return new array containing:
%   [max(TAB(1:4)) max(TAB(5:8)) ... ]
%   
%   N can also be an array of dimension size(TAB), then it is possible to
%   specify different subsampling in each direction. 
%
%   TODO: Future versions should provide more possibilities for filter 
%   function: mean, median, k-order ...
%   TODO: manage 3D RGB images
%
%   See also:
%   subsample, blkproc
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%

%   HISTORY
%   06/05/2009 return image with same class as input image
%   23/07/2009 update doc 


dim = size(src);
if length(scale)==1
    scale = ones(2, 1)*scale;
end

res = zeros([floor(dim(1)/scale(1)) floor(dim(2)/scale(2)) 3], class(src)); %#ok<ZEROLIKE>

res(:,:,1) = subsample(src(:,:,1), scale(1:2)');
res(:,:,2) = subsample(src(:,:,2), scale(1:2)');
res(:,:,3) = subsample(src(:,:,3), scale(1:2)');

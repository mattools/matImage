function res = subsample(src, scale, varargin)
%SUBSAMPLE Subsample an array by applying operation on blocs
%
%   Note: deprecated, replaced by imDownSample
%
%   subsample(TAB, K);
%   Returns a matrix of dimension size(TAB)/K. Each pixel of the output
%   array is computed from a K*K frame in the original array, by taking the
%   maximal value in the frame as default. 
%
%   Example: 
%   IMG = subsample(TAB, 4);
%   will return new array containing [max(TAB(1:4)) max(TAB(5:8)) ... ]
%   
%   N can also be an array of dimension size(TAB), then it is 
%   possible to specify different sampling factors in each direction.
%
%   Example: 
%   IMG = subsample(TAB, K, OP);
%   will use different method for computing value corresponding to a given
%   frame. OP can be one of: 
%   - 'first'   return the value of the first pixel in the frame
%   - 'mean'    compute the mean value of all pixels in the frame
%   - 'median'  compute the median value of all pixels in the frame
%   - 'min'     compute the min value of all pixels in the frame
%   - 'max'     compute the max value of all pixels in the frame
%
%   Works also for 3D image, but only for 'max' filtering.
%
%   TODO: add processing for low and right edge (currently 'forgotten')
%   TODO: add options for edge processing : pad, crop, repeat ...
%
%   See also:
%   subsamplergb, blkproc
%
%   ---------
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/12/2003.
%

%   HISTORY:
%   07/01/2004 add support for different methods of subsampling
%   25/08/2006 result has now the same class as the input
%   28/05/2009 add doc
%   23/07/2009 update doc

warning('imFilters:deprecated', ...
    'subsample is deprecated, use imDownSample instead');

% get initial size of image
dim = size(src);

% if scale is given as single value, convert to 1*NDIMS array
if length(scale)==1
    scale = ones(size(dim))*scale;
end

% get type of sampling (max, min, mean, median ...)
type = 'max';
if ~isempty(varargin)
    type = varargin{1};
end

% allocate memory for result
if islogical(src)
    res = false(floor(size(src)./scale));
else
    res = zeros(floor(size(src)./scale), class(src)); %#ok<ZEROLIKE>
end

% process case DIM=1
if length(dim)==1 % & (dim(1)==1 | dim(2)==1)

    disp('dimension 1');
    if strcmp(type, 'max')
        for i=1:size(res, 1)-1
            res(i)=max(src(i*scale(1):(i+1)*scale(1)-1));
        end
        res(dim(1)) = max(src(size(res,1)*scale(1):dim(1)));
    elseif strcmp(type, 'min')
        for i=1:size(res, 1)-1
            res(i)=min(src(i*scale(1):(i+1)*scale(1)-1));
        end
    elseif strcmp(type, 'mean')
        for i=1:size(res, 1)-1
            res(i)=mean( src(i*scale(1):(i+1)*scale(1)-1));
        end
    elseif strcmp(type, 'median')
        for i=1:size(res, 1)-1
            res(i)=median( src(i*scale(1):(i+1)*scale(1)-1));
        end
    elseif strcmp(type, 'first')
        for i=1:size(res, 1)-1
            res(i)=src(i*scale(1));
        end
    end
    return;
end

% process case DIM=2
if length(dim)==2
%    Old version, not vectorized ...
%    for i=1:size(res, 1)-1
%        for j=1:size(res, 2)-1
%            %x = i*scale(1):(i+1)*scale(1)-1
%            %y = j*scale(2):(j+1)*scale(2)-1
%            res(i,j)=max(max( src(i*scale(1):(i+1)*scale(1)-1, ...
%                              j*scale(2):(j+1)*scale(2)-1 )  ));
%        end
%    end
%end

    dim2 = floor(dim./scale);
    dim = dim2.*scale;
    if islogical(src)
        tab = false([dim2(1) dim2(2) scale(1)*scale(2)]);
    else
        tab = zeros([dim2(1) dim2(2) scale(1)*scale(2)], class(src)); %#ok<ZEROLIKE>
    end

    for i=1:scale(1)
        for j=1:scale(2)
            tab(1:dim2(1), 1:dim2(2) ,i+(j-1)*scale(1)) = ...
                src(i:scale(1):dim(1), j:scale(2):dim(2));
        end
        
    end
    
    if strcmp(type, 'max')
        res = max(tab, [], 3);
    elseif strcmp(type, 'min');
        res = min(tab, [], 3);
    elseif strcmp(type, 'mean');
        res = mean(tab, 3);
    elseif strcmp(type, 'median');
        res = median(tab, 3);
    elseif strcmp(type, 'first');
        res = tab(:, :, 1);
    end
    return;
end

% process case DIM=3
if length(dim)==3
    for i=1:size(res, 1)-1
        for j=1:size(res, 2)-1
            for k=1:size(res, 3)-1
                % crop portion of image to process
                sub = src(i*scale(1):(i+1)*scale(1)-1, ...
                          j*scale(2):(j+1)*scale(2)-1, ...
                          k*scale(3):(k+1)*scale(3)-1  );
                      
                % apply operation on cropped image 
                res(i,j,k) = feval(type, sub(:));
                %res(i,j,k) = max(sub(:));
            end
        end
    end
end

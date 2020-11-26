function res = imDownSample(img, k, varargin)
%IMDOWNSAMPLE Apply down-sampling on an image by applying operation on blocs
%
%   imDownSample(IMG, K);
%   Returns a matrix of dimension size(IMG)/K. Each pixel of the output
%   array is computed from a K-by-K frame in the original array, by taking
%   the maximal value in the frame as default. 
%
%   IMG2 = imDownSample(IMG, 4);
%   will return new array containing [max(IMG(1:4)) max(IMG(5:8)) ... ]
%   
%   N can also be an array of dimension size(TAB), then it is 
%   possible to specify different sampling factors in each direction.
%
%   IMG = imDownSample(TAB, K, OP);
%   will use different method for computing value corresponding to a given
%   frame. OP can be one of: 
%   - {'none'}  return the value of the first pixel in the frame (default)
%   - 'mean'    compute the mean value of all pixels in the frame (default)
%   - 'median'  compute the median value of all pixels in the frame
%   - 'min'     compute the min value of all pixels in the frame
%   - 'max'     compute the max value of all pixels in the frame
%   - 'first'   return the value of the first pixel in the frame
%
%   TODO: add processing for low and right edge (currently 'forgotten')
%   TODO: add options for edge processing : pad, crop, repeat ...
%
%   Example
%     img = imread('cameraman.tif');
%     imgMax = imDownSample(img, 4, 'max');
%     imgMin = imDownSample(img, 4, 'min');
%     figure; 
%     subplot(121); imshow(imgMin); title('downsample with min');
%     subplot(122); imshow(imgMax); title('downsample with max');
% 
%   See also:
%      imResize, imReadDownSampled3d, blkproc
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
%   10/05/2019 rename from subsample to imDownSample

% get initial size of image
dim = size(img);

% if scale is given as single value, convert to 1*NDIMS array
if isscalar(k)
    k = ones(size(dim)) * k;
end

if ndims(img) > 2 && size(img, 3) == 3 %#ok<ISMAT>
    k(3) = 1;
end

% get type of sampling (max, min, mean, median ...)
type = 'none';
if ~isempty(varargin)
    type = varargin{1};
end

% allocate memory for result
newDims = floor(size(img) ./ k);
if islogical(img)
    res = false(newDims);
else
    res = zeros(newDims, class(img));
end

% First process to secific case of 'none' type
if strcmpi(type, 'none')
    % use sub indexing for resampling (faster)
    switch ndims(img)
        case 2, res = img(1:k(1):end, 1:k(2):end);
        case 3, res = img(1:k(1):end, 1:k(2):end, 1:k(3):end);
        case 4, res = img(1:k(1):end, 1:k(2):end, 1:k(3):end, 1:k(4):end);
        case 5, res = img(1:k(1):end, 1:k(2):end, 1:k(3):end, 1:k(4):end, 1:k(5):end);
    end
    return;
end


% process case DIM=1
if isscalar(dim)
    switch type
        case 'max'
            for i = 1:size(res, 1)-1
                res(i) = max(img(i*k(1):(i+1)*k(1)-1));
            end
            res(dim(1)) = max(img(size(res,1)*k(1):dim(1)));
        case 'min'
            for i = 1:size(res, 1)-1
                res(i) = min(img(i*k(1):(i+1)*k(1)-1));
            end
        case 'mean'
            for i = 1:size(res, 1)-1
                res(i) = mean( img(i*k(1):(i+1)*k(1)-1));
            end
        case 'median'
            for i = 1:size(res, 1)-1
                res(i) = median( img(i*k(1):(i+1)*k(1)-1));
            end
        case 'first'
            for i = 1:size(res, 1)-1
                res(i) = img(i*k(1));
            end
        otherwise
            error(['Unable to process option: ' type]);
    end
    
    return;
end

% process case DIM=2
if length(dim) == 2
    % allocate 3D image with third dimension corresponding to index in block
    dim2 = floor(dim ./ k);
    dim = dim2 .* k;
    if islogical(img)
        tab = false([dim2(1) dim2(2) k(1)*k(2)]);
    else
        tab = zeros([dim2(1) dim2(2) k(1)*k(2)], class(img));
    end

    % fill in the 3D image
    for i = 1:k(1)
        for j = 1:k(2)
            tab(1:dim2(1), 1:dim2(2) ,i+(j-1)*k(1)) = ...
                img(i:k(1):dim(1), j:k(2):dim(2));
        end
    end

    % apply processing along the third dimension
    if strcmp(type, 'max')
        res = max(tab, [], 3);
    elseif strcmp(type, 'min')
        res = min(tab, [], 3);
    elseif strcmp(type, 'mean')
        res = mean(tab, 3, 'native');
    elseif strcmp(type, 'median')
        res = median(tab, 3);
    elseif strcmp(type, 'first')
        res = tab(:, :, 1);
    end
    return;
end

% process case DIM=3
if length(dim) == 3
    for i = 1:size(res, 1)-1
        for j = 1:size(res, 2)-1
            for k = 1:size(res, 3)-1
                % crop portion of image to process
                sub = img(i*k(1):(i+1)*k(1)-1, ...
                          j*k(2):(j+1)*k(2)-1, ...
                          k*k(3):(k+1)*k(3)-1  );
                      
                % apply operation on cropped image 
                res(i,j,k) = feval(type, sub(:)); %#ok<FVAL>
            end
        end
    end
end

function res = imDirectionalFilter(img, varargin)
%IMDIRECTIONALFILTER Apply and combine several directional filters
%
%   Applies a directional filter, with linear structural element, and 
%   computes min or max of results. Result is the same type as the input
%   image.
%
%   Classical uses of such filters is max of opening, which performs
%   good enhancement of lines.
%
%   For the use of median or mean filters, the functions "imMedianFilter"
%   and "imMeanFilter" are also provided, with a syntax similar to imopen
%   or imclose.
%
%   Usage
%   RES = imDirectionalFilter(SRC, 'imMeanFilter', 'max', 20, 8);
%   computes the mean in each 8 directions, with linear structuring element
%   of length 20, and keep the max value over all directions.
%   
%   RES = imDirectionalFilter(SRC, 'imMeanFilter', 20, 8); 
%   uses 'max' as default for second operator.
%
%   RES = imDirectionalFilter(SRC, 20, 8); also work, the
%   uses 'imopen' as default operator for first transform.
%
%   RES = imDirectionalFilter(SRC, 'imMeanFilter', 'max', 20, 8, 3);
%   Specifies width of the line (obtained by dilation).
%
%
%   See also
%   imopen, imclose, imMeanFilter, imMedianFilter

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/02/2004.
%

%   HISTORY
%   17/02/2004 debug, added some doc, manage different types of images
%   26/02/2007 cleanup code
%   03/10/2007 update doc
%   19/08/2009 fix bug in parsing arguments
%   18/06/2010 fix initialization for 'min' operator, update doc
%   02/12/2011 rename to "imDirectionalFilter", update doc


%% Default values

% operators
op1 = 'imopen';
op2 = 'max';

% parameters for structuring element
Nd = 32;
N = 65;
w = 1;


%% Process input parameters

% first operation
if ~isempty(varargin)
    op1 = varargin{1};
end

% other arguments
if length(varargin) > 1
    
    var = varargin{2};    
    if ischar(var)
        % third argument is name of second operator
        op2 = var;
        
        % fourth argument is length of the line
        if length(varargin) > 2
            N = varargin{3};
        end
        % fifth argument is number of directions
        if length(varargin) > 3
            Nd = varargin{4};
        end
        % sixth argument is width of the line
        if length(varargin) > 4
            w = varargin{5};
        end
    else
        % third argument is length of the line
        N = varargin{2};
        
        % fourth argument is number of directions
        if length(varargin) > 2
            Nd = varargin{3};
        end
        % fifth argument is width of the line
        if length(varargin) > 3
            w = varargin{4};
        end
    end
end


%% Initialisations

% memory allocation, creating result the same type as input
if strcmp(op2, 'max')
    % fill image with zeros
    if islogical(img)
        res = false(size(img));
    else
        res = zeros(size(img), class(img));
    end
    
elseif strcmp(op2, 'min')
    % fill image with ones
    if islogical(img)
        res = true(size(img));
    elseif isinteger(img)
        type = class(img);
        res = intmax(type) * ones(size(img), type);
    else
        res = inf * ones(size(img));
    end
else
    error('Do not know how to manage "%s" operator', op2);
end


%% Iteration on directions

% iterate on directions
for d = 1:Nd
    % compute structuring element. 
    % base is a  line, eventually dilated by a  ball
    filt = getnhood(strel('line', N,  (d-1) * 180 / Nd));
    if w > 1
        filt = imdilate(filt, ones(3*ones(1, length(size(img)))), 'full');
    end
    
    % keep max or min along all directions
    res = feval(op2, res, feval(op1, img, filt));
end


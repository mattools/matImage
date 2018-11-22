function res = imBoxFilter(img, dims, varargin)
%IMBOXFILTER Box filter on 2D/3D iamge
%
%   RES = imBoxFilter(IMG, BOXSIZE)
%   Returns an array with the same size as the input array IMG, using a
%   flat kernel of size given by DIMS (as a 1-by-ND array).
%
%   Example
%   imBoxFilter
%
%   See also
%     imMeanFilter, imfilter
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-11-22,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2018 INRA - Cepia Software Platform.
% get Padopt option

% choose border management strategy
padopt = 'replicate';
if ~isempty(varargin)
    padopt = varargin{1};
end

% perform filtering
if isfloat(img)
    res = img;
    for d = 1:length(dims)
        kernel = ones([dims(d) 1]) / dims(d);
        dimD = ones(1, length(dims));
        dimD(d) = dims(d);
        kernel = reshape(kernel, dimD);
        res = imfilter(res, kernel, padopt);
    end
    
else
    % create ND kernel
    kernel = ones(dims);
    kernel = kernel / sum(kernel(:));

    % apply kernel
    res = imfilter(img, kernel, padopt);
end
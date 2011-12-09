function res = imRescale(img, varargin)
%IMRESCALE Rescale gray levels of image to get better dynamic
%
%   This function has been replaced by function 'imAdjustDynamic', and is
%   now deprecated.
%   
%   RES = imRescale(IMG, [GMIN GMAX]);
%   all values below GMIN will be set to 0, all values greater than GMAX
%   will be set to 255, all values in between will be equally spaced
%   between 0 and 255.
%   The result is a 255 grayscale image.
%
%   RES = imRescale(IMG);
%   rescale using min and max values found in image.
%
%   See Also:
%   imLUT, imGrayscaleExtent, imadjust, mat2gray
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/03/2005.
%

%   HISTORY
%   25/03/2005 correct bug, due to computation with unsigned values
%   21/08/2009 extends to manage double images
%   05/11/2011 deprecated and replace by imAdjustDynamic

warning('imael:deprecatedFunction', ...
    'function "imRescale" has been deprecated and replaced by "imAdjustDynamic"');

% process input arguments
if ~isempty(varargin)
    % use min and max values given as parameter
    var = varargin{1};
    min1 = double(var(1));
    max1 = double(var(end));
else
    % use min and max values computed from input image
    min1 = double(min(img(:)));
    max1 = double(max(img(:)));
end

% compute slope of linear transformation
a = double(255 / (max1 - min1));

% compute result image
% values below 0 or greater than 255 are automatically clipped when
% casting to uint8
res = uint8((img - min1) * a);


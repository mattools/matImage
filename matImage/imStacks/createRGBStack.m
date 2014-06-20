function rgb = createRGBStack(img1, img2, img3)
%CREATERGBSTACK Concatenate 2 or 3 grayscale stacks to form a color stack
%
%   RGB = createRGBStack(RED, GREEN)
%   RGB = createRGBStack(RED, GREEN, BLUE)
%   Create a new 3D image containing RGB values from 2 or 3 grayscale
%   images. All input images must have the same size M-by-N-ny-P.
%   The resulting RGB image has size M-by-N-by-3-by-P.
%
%   It is also possible to specify empty red or green channel:
%   RGB = createRGBStack([], GREEN, BLUE)
%   RGB = createRGBStack(RED, [], BLUE)
%
%   Example
%     % Colorize in red the bright parts of a 3D image
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata) * 3;
%     I2 = I;
%     I2(I > 200) = 0;
%     rgb = createRGBStack(I, I2, I2);
%     slicer(rgb)
%
%   See also
%   
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Process input arguments

% ensure initialisation of variable
if nargin < 3
    img3 = [];
end

% choose one of the 3 inputs as reference
ref = img1;
if isempty(img1)
    ref = img2;
    if isempty(img2)
        ref = img3;
        if isempty(ref)
            error('At least one channel must be specified');
        end
    end
end


%% Initialize result

% size of reference and new image
dim = size(ref);
newDim = [dim(1:2) 3 dim(3)];

% create empty result image
if islogical(ref)
    rgb = false(newDim);
else
    rgb = zeros(newDim, class(ref));
end


%% Fill up result with data

% Red channel
if ~isempty(img1)
    rgb(:,:,1,:) = img1;
end

% green channel
if ~isempty(img2)
    if sum(size(img2) ~= dim) > 0
        error('Red and Green images must have the same size');
    end
    rgb(:,:,2,:) = img2;
end

% blue channel
if ~isempty(img3) 
    if sum(size(img3) ~= dim) > 0
        error('Blue and reference images must have the same size');
    end
    rgb(:,:,3,:) = img3;
end


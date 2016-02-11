function [value, maxEntropy] = imMaxEntropyThreshold(img, varargin)
%IMMAXENTROPYTHRESHOLD Compute image threshold using maximisation of entropies
%
%   VALUE = imMaxEntropyThreshold(IMG)
%   Automatically computes threshold for segmenting image IMG, based on
%   maximisation of entropy method, and returns the threshold value.
%
%   [VALUE, ENTROPY] = imMaxEntropyThreshold(IMG)
%   Also returns the entropy corresponding to the chosen value.
%
%
%   Example
%   % Compute threshold for coins image
%     img = imread('coins.png');
%     figure; imshow(img);
%     T = imMaxEntropyThreshold(img);
%     figure; imshow(img > T);
%
%   Note
%   Only implemented for grayscale image coded on uint8.
%
%
%   See also
%   imHistogram, imOtsuThreshold, watershed
%

%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2012-01-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute frequency histogram
histo = imHistogram(img, varargin{:})';
freq = histo / sum(histo);

% allocate memory: entropy of each class and sum of entropies, for all
% threshold values 
H1 = zeros(256, 1);
H2 = zeros(256, 1);
psi = zeros(256, 1);

% compute total entropy
Hn = 0;
for i = 1:256
    if freq(i) ~= 0
        Hn = Hn - freq(i) * log(freq(i));
    end
end

% compute sum of entropy for each threshold level
for s = 1:256
    % compute total frequencies for each part
    P1 = sum(freq(1:s));
    P2 = sum(freq(s+1:end));

    % do not process degenerate cases 
    if P1 == 0 || P2 == 0
        continue;
    end
    
    Hs = 0;
    for i = 1:s
        if freq(i) ~= 0
            Hs = Hs - freq(i) * log(freq(i));
        end
    end
    
    % entropy of each class
    H1(s) = log(P1) + Hs / P1;
    H2(s) = log(P2) + (Hn - Hs) / P2;

    % total entropy
    psi(s) = H1(s) + H2(s);
end

% find index giving maximum of entropy
[maxEntropy, ind] = max(psi);

% convert to gray level
value = ind - 1;

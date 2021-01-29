function [regions, thresholds, maxSig] = imMultiOtsuThreshold(img, nClasses, varargin)
% Multilevel Thresholding using Otsu Method.
%
%   CLASSES = imMultiOtsuThreshold(IMG, NC)
%   Computes a segmentation of the input grayscale image IMG into NC 
%   classes. The number of classes must be comprised between 2 and 5.
%
%   [CLASSES, THRESHOLDS] = imMultiOtsuThreshold(IMG, NC)
%   Also returns the list of threshold. The number of threshold values is
%   the number of classes minus one.
%
%   Example
%     % segment cameraman image into three classes
%     img = imread('cameraman.tif');
%     [classes, threshs] = imMultiOtsuThreshold(img, 3);
%     rgb = label2rgb(classes, 'jet', [1 0 0], 'shuffle');
%     figure; imshow(rgb);
%     % also displays histogram with threshold levels
%     figure; imHistogram(img);
%     hold on;
%     for i = 1:2
%        plot(threshs([i i]), [0 1800], 'color', 'r', 'linewidth', 2);
%     end
%
%   References
%   * Ping-Sung Liao, Tse-Sheng Chen, Pau-Choo Chung (2001). "A Fast
%   Algorithm for Multilevel Thresholding". Journal of Information Science
%   and Engineering, Vol. 17 No. 5, pp. 713-727.  
%   https://jise.iis.sinica.edu.tw/JISESearch/pages/View/PaperView.jsf?keyId=86_1302#
%   * https://imagej.net/Multi_Otsu_Threshold
%
%   See also
%     imOtsuThreshold, imHistogram, imMaxEntropyThreshold
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-01-29,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

%% Input arguments

if ~isa(img, 'uint8')
    error('Requires a grayscale uint8 image as first input');
end

if nClasses < 2 || nClasses > 5
    error('The number of classes must be comprised between 2 and 5.');
end


%% Initialisations

% compute histogram, and convert into probability density
[h, levels] = imHistogram(img, varargin{:});
h = h / sum(h);

% number of gray levels
nLevels = length(levels);

Puv = zeros(nLevels, nLevels);
Suv = zeros(nLevels, nLevels);
Huv = zeros(nLevels, nLevels);

% initialize diagonal terms
for i = 1:nLevels
    Puv(i, i) = h(i);
    Suv(i, i) = h(i) * i;
end

% initialize first rows
for i = 2:nLevels
    Puv(1, i) = Puv(1, i-1) + h(i);
    Suv(1, i) = Suv(1, i-1) + i*h(i);  
end
% initialize the rest of the matrices
for u = 2:nLevels
    for v = u+1:nLevels
        Puv(u, v) = Puv(1, v) - Puv(1, u-1);
        Suv(u, v) = Suv(1, v) - Suv(1, u-1);
    end
end

% now calculate Huv
for u = 1:nLevels
    for v = u+1:nLevels
        if Puv(u,v) > 0
            Huv(u,v) = Suv(u,v) * Suv(u,v) / Puv(u,v);
        end
    end
end


%% Main processing

% create array for threshold values (first one is zeros, last one is inf)
thresholds = zeros(nClasses+1, 1);
thresholds(end) = inf;

% iterate over all possible combinations
maxSig = 0.0;
switch nClasses
    case 2
        % two classes -> only need to find second threshold value
        for i = 1:nLevels-1
            Sq = Huv(1,i) + Huv(i+1, end);
            if Sq >= maxSig
                thresholds(2) = i;
                maxSig = Sq;
            end
        end
        
    case 3
        % three classes
        for i = 1:nLevels-2
            for j = i+1:nLevels-1
                Sq = Huv(1,i) + Huv(i+1, j) + Huv(j+1, end);
                if Sq >= maxSig
                    thresholds(2) = i;
                    thresholds(3) = j;
                    maxSig = Sq;
                end
            end
        end
        
    case 4
        % four classes
        for i = 1:nLevels-3
            for j = i+1:nLevels-2
                for k = j+1:nLevels-1
                    Sq = Huv(1,i) + Huv(i+1, j) + Huv(j+1, k) + Huv(k+1, end);
                    if Sq >= maxSig
                        thresholds(2) = i;
                        thresholds(3) = j;
                        thresholds(4) = k;
                        maxSig = Sq;
                    end
                end
            end
        end
        
    case 5
        % five classes
        for i = 1:nLevels-3
            for j = i+1:nLevels-2
                for k = j+1:nLevels-1
                    for m = k+1:nLevels-1
                        Sq = Huv(1,i) + Huv(i+1, j) + Huv(j+1, k) + Huv(k+1, m) + Huv(m+1, end);
                        if Sq >= maxSig
                            thresholds(2) = i;
                            thresholds(3) = j;
                            thresholds(4) = k;
                            thresholds(5) = m;
                            maxSig = Sq;
                        end
                    end
                end
            end
        end
        
    otherwise
        error('Can not manage %d number of classes', nClasses);
end


%% Create region image

regions = zeros(size(img), 'uint8');
for i = 1:nClasses
    inds = img >= thresholds(i) & img < thresholds(i+1);
    regions(inds) = i;
end



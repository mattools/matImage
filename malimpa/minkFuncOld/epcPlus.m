function chi = epcPlus(img, varargin)
%EPCPLUS estimate Euler-Poincare Charac with plus sampling
%   Estime les densites de Minkowski d'une image binaire
%   la struture est representee par des 1, le fond par des 0
% 
%   See also: EPC, EPCSHELL, EPCMEAN, MINKMEAN, MINKSHELL, MINKPLUS
% 
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/06/2004.
%

%   HISTORY
%   18/06/2004 : rewrite, adapted from minkPlus

% input image dimension 
img = squeeze(img);
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims = 1;
end


% init, depending on input variables =====================


% dimension 1
if nbDims==1
    chi = epc(img) - sum(img)/length(img);
    return;
end

% dimension 2
if nbDims==2
    N1 = dim(1); N2 = dim(2);

    % boundary density estimation
    A = sum(img(:));
    D1 = tpl(img, [1 0]);
    D2 = tpl(img, [0 1]);
    
    % connectivity estimation
    chi = epc(img) - D2/N1 - D1/N2 + A/N1/N2;
    
    return;
end

% dimension 3
if ndims(img)==3
    N1 = dim(1); N2 = dim(2); N3 = dim(3);
    
    % measure charac on visible structure -----------------------------
    
    % compute Euler-Poincare Characteristic of visible structure 
    %   ( equals to :  tpl(img,[0 0 0])) 
    chi = epc(img);      

    % compute total projected diameter in each direction
    D1 = tpl(img, [1 0 0]);
    D2 = tpl(img, [0 1 0]);
    D3 = tpl(img, [0 0 1]);

    % compute total projected area in each direction
    S1 = tpl(img, [0 1 1]);
    S2 = tpl(img, [1 0 1]);
    S3 = tpl(img, [1 1 0]);
    
    % compute volume of visible structure (equals to :  tpl(img,[1 1 1]))  
    V = sum(img(:));
      
    % Euler-Poincare Characteristic estimation 
    % cf EPC(IMG) for more base algorithm.    
    chi = chi - D1/N1 - D2/N2 - D3/N3 + ...
        S1/N2/N3 + S2/N1/N3 + S3/N1/N2 - V/N1/N2/N3;
end

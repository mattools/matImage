function mink = minkPlus(img, varargin)
%MINKPLUS   estimate Minkowski densities with plus-sampling
%
%   M = MINKPLUS(IMG) : returns Minkowski densities estimated with
%   plus-samlpig. Length of array M is ndims(IMG)+1.
%
%   M = MINKPLUS(IMG, CONN) : specifies connectivity to use. CONN can be
%   either a numerical value, depending on the IMG dimension, or one of the
%   following strings : 'minimal' 'maximal'.
%
%   Available connectivities in 2D are :
%   4, 8
%   
%   Available connectivities in 3D are :
%   6, 26
%
%   See also : MINKOWSKI, MINKSHELL
%
%   TODO : process 3D case
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/12/2003.
%

%   HISTORY 
%   18/03/2004 : correct bugs in 2D case.
%   01/04/2004 : add 3D case

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
    mink = zeros(2, 1);
    mink(1) = sum(img(:));
    mink(2) = 2*(epc(img) - sum(img)/length(img));
    return;
end

% dimension 2
if nbDims==2
    mink = zeros(3, 1);   
    N1 = dim(1); N2 = dim(2);
    % area density estimation
    mink(1) = sum(img(:))/N1/N2;
    
    % boundary density estimation
    A = sum(img(:));
    D1 = tpl(img, [1 0]);
    D2 = tpl(img, [0 1]);

    mink(2) = (D1*N1/(N1-1) + D2*N2/(N2-1)-A/(N1-1)-A/(N2-1));
    mink(2) = mink(2)*pi/4/N1/N2;
    
    % connectivity estimation
    chi     = epc(img);                     % = tpl(tab, [0 0]);
    mink(3) = (chi - D2/N1 - D1/N2 + A/N1/N2 )*pi/(N1-1)/(N2-1);
    
    return;
end

% dimension 3
if ndims(img)==3
    mink = zeros(4, 1);
    N1 = dim(1); N2 = dim(2); N3 = dim(3);
    
    % measure charac on visible structure -----------------------------
    
    % compute Euler-POoincare Characteristic of visible structure 
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
    
    
    % estimate charac from visible parts -----------------------------
    
    
    % volume density estimation 
    mink(1) = V/N1/N2/N3;
    
    % surface density estimation 
    mink(2) = ( (S1 - V/N1)*N1/(N1-1) + ...
                (S2 - V/N2)*N2/(N2-1) + ...
                (S3 - V/N3)*N3/(N3-1) ) * 4/9 / ...
                N1/N2/N3;

    % mean curvature density estimation (= mean length)

    mink(3) = ( ...
        (D1 - S2/N2 - S3/N2 + V/N2/N3)/N1/(N2-1)/(N3-1) + ...
        (D2 - S1/N3 - S3/N1 + V/N1/N3)/N2/(N1-1)/(N3-1) + ...
        (D3 - S1/N2 - S2/N1 + V/N1/N2)/N3/(N1-1)/(N2-1) ) * ...
        2*pi/9;
            
    
    % Euler-Poincare Characteristic estimation 
    % cf EPC(IMG) for more base algorithm.
    
    mink(4) = (chi - D1/N1 - D2/N2 - D3/N3 + ...
        S1/N2/N3 + S2/N1/N3 + S3/N1/N2 - ...
        V/N1/N2/N3 )*4*pi/3/(N1-1)/(N2-1)/(N3-1);
    
    
    return
end

return 
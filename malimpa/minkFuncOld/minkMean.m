function mink = minkMean(img, varargin)
%MINKMEAN estimate Minkowski densities of a random structure
%   Estime les densites de Minkowski d'une image binaire
%   la struture est representee par des 1, le fond par des 0
% 
%   See also : MINKOWSKI
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%


% input image dimension 
img = squeeze(img);
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims = 1;
end

% set edge condition to '000' by default
edge = zeros(nbDims, 1);

% extract edge condition information -------------
if ~isempty(varargin)    
    
    var = varargin{1};
    
    % check parameter dimensions
    if length(var)~=nbDims
        error('edge condition dimension doesn''t match image dimension');
    end
    
    if isnumeric(var)
        % edge cond. given as integer array
        edge = var;
        
    elseif ischar(var)
        % edge cond. given as char array            
        for j=1:length(var)
            switch var(j)
                case {'0', '-'}
                    edge(j) = 0;
                case {'1', '+'}
                    edge(j) = 1;
                case {'/', 'x', 'X', '*'}
                    edge(j) = NaN;
                otherwise
                    error('non supported character in edge condition');
            end                        
        end        
    else
        error('unsupported parameter for edge condition');
    end
end
    


% init, depending on input variables =====================

% edge condition
b = zeros(nbDims, 1);
for d=1:nbDims
    if edge(d)==0
        b(d) = 1;
    elseif edge(d)==1
        b(d) = dim(d);
    else
        b(d) = inf;
    end
end


% dimension 1
if ndims(img)==2 && (dim(2)==1 || dim(1)==1) 
    mink = zeros(2, 1);
    mink(1) = sum(img(:));
    mink(2) = 2*(epc(img) - mean([epc(img(1)) epc(img(dim(1)))]));
    return;
end

% dimension 2
if ndims(img)==2
    mink = zeros(3, 1);   
    
    % area density estimation
    mink(1) = sum(img(:));
    
    % boundary density estimation
    Dx=0; Dy=0;
    for i=1:dim(2)
        Dx = Dx + epc(img(:,i)) - ...
            mean([epc(img(1,i)) epc(img(dim(1),i)) ]);
    end
    for i=1:dim(1)
        Dy = Dy + epc(img(i,:)) - ...
            mean([epc(img(i,1)) epc(img(i,dim(2))) ]);
    end
    mink(2) = (Dx*dim(2)/(dim(2)-1) + Dy*dim(1)/(dim(1)-1))*pi/4;
    
    
    % connectivity estimation
    chi = epc(img);
    chix = mean([ epc(img(1,:)) epc(img(dim(1),:)) ]);
    chiy = mean([ epc(img(:,1)) epc(img(:,dim(2))) ]);
    chixy = mean([ ...
            epc(img(1, 1)), ...
            epc(img(dim(1), 1)), ...
            epc(img(1, dim(2))), ...
            epc(img(dim(1), dim(2))) ]);
    mink(3) = (chi - chix - chiy + chixy)*pi*dim(1)*dim(2)/(dim(1)-1)/(dim(2)-1);
    
    % convertit en densite
    mink = mink/(dim(1)*dim(2));
    
    return;
end

% dimension 3
if ndims(img)==3
    
    % upper bounds of image (lower bounds are always 1)
    N1 = dim(1);
    N2 = dim(2);
    N3 = dim(3);
    
    % compute volume of visible structure (equals to :  tpl(img,[1 1 1]))  
    V = sum(img(:));

    % compute total projected area in each direction
    S1 = tpl(img, [0 1 1]);
    S2 = tpl(img, [1 0 1]);
    S3 = tpl(img, [1 1 0]);
    
    % area of intersection with each face
    A1 = sum(sum(sum(img([1 N1], :, :))))/2;
    A2 = sum(sum(sum(img(:, [1 N2], :))))/2;
    A3 = sum(sum(sum(img(:, :, [1 N3]))))/2;
    

    % compute total projected diameter in each direction
    D1 = tpl(img, [1 0 0]);
    D2 = tpl(img, [0 1 0]);
    D3 = tpl(img, [0 0 1]);

    
    % intersection length with each edge
    L1 = mean([sum(img(:, 1, 1)) sum(img(:, 1, N3)) sum(img(:, N2, 1)) sum(img(:, N2, N3))]);
    L2 = mean([sum(img(1, :, 1)) sum(img(1, :, N3)) sum(img(N1, :, 1)) sum(img(N1, :, N3))]);
    L3 = mean([sum(img(1, 1, :)) sum(img(1, N2, :)) sum(img(N1, 1, :)) sum(img(N1, N2, :))]);

    % tpl of itersection with each face in both directions
    L12 = mean([tpl(squeeze(img(1,:,:)), [1 0]) tpl(squeeze(img(N1,:,:)), [1 0])]);
    L13 = mean([tpl(squeeze(img(1,:,:)), [0 1]) tpl(squeeze(img(N1,:,:)), [0 1])]);
    L21 = mean([tpl(squeeze(img(:,1,:)), [1 0]) tpl(squeeze(img(:,N2,:)), [1 0])]);
    L23 = mean([tpl(squeeze(img(:,1,:)), [0 1]) tpl(squeeze(img(:,N2,:)), [0 1])]);
    L31 = mean([tpl(squeeze(img(:,:,1)), [1 0]) tpl(squeeze(img(:,:,N3)), [1 0])]);
    L32 = mean([tpl(squeeze(img(:,:,1)), [0 1]) tpl(squeeze(img(:,:,N3)), [0 1])]);

    
    % connecitivity in window
    chi = epc(img);
    
    % connectivity on faces (window boundaries)
    chi1 = (epc(squeeze(img(1,:,:))) + epc(squeeze(img(N1,:,:))))/2;
    chi2 = (epc(squeeze(img(:,1,:))) + epc(squeeze(img(:,N2,:))))/2;
    chi3 = (epc(squeeze(img(:,:,1))) + epc(squeeze(img(:,:,N3))))/2;

    % connectivity on edges (window boundaries)
    chi12 = mean([ ...
        epc(squeeze(img(1,   1, :))) ...
        epc(squeeze(img(1,  N2, :))) ...
        epc(squeeze(img(N1,  1, :))) ...
        epc(squeeze(img(N1, N2, :))) ]);
    chi13 = mean([ ...
        epc(squeeze(img(1,  :,  1))) ...
        epc(squeeze(img(1,  :, N3))) ...
        epc(squeeze(img(N1, :,  1))) ...
        epc(squeeze(img(N1, :, N3))) ]);
    chi23 = mean([ ...
        epc(squeeze(img(:,  1,  1))) ...
        epc(squeeze(img(:,  1, N3))) ...
        epc(squeeze(img(:, N2,  1))) ...
        epc(squeeze(img(:, N2, N3))) ]);

    % connectivity on corner boundary
    chi123 = mean([ ...
            epc(img(N1,  1,  1)) ...
            epc(img(N1,  1, N3)) ...
            epc(img(N1, N2,  1)) ...
            epc(img(N1, N2, N3)) ...
            epc(img(1,   1,  1)) ...
            epc(img(1,   1, N3)) ...
            epc(img(1,  N2,  1)) ...
            epc(img(1,  N2, N3)) ]);
  

 
    % estimate charac from visible parts -----------------------------
    
    mink = zeros(4, 1);
    
    % volume density estimation 
    mink(1) = V/N1/N2/N3;
    
    % surface density estimation 
    mink(2) = ( (S1 - A1)*N1/(N1-1) + ...
                (S2 - A2)*N2/(N2-1) + ...
                (S3 - A3)*N3/(N3-1) ) * 4/9 / ...
                N1/N2/N3;

    % mean curvature density estimation (= mean length)
    mink(3) = ( ...
        (D1 - L21 - L31 + L1)/N1/(N2-1)/(N3-1) + ...
        (D2 - L12 - L32 + L2)/N2/(N1-1)/(N3-1) + ...
        (D3 - L13 - L23 + L3)/N3/(N1-1)/(N2-1) ) * ...
        2*pi/9;
            
    
    
    % connectivity estimation
    mink(4) = (chi - (chi1+chi2+chi3) + (chi12+chi13+chi23) - chi123)*4*pi/3/(N1-1)/(N2-1)/(N3-1);
        
    return
end

return 
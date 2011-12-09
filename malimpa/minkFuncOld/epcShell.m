function chi = epcShell(img, varargin)
%EPCSHELL estimate Euler-Poincare Characteristic with shell-sampling
%   Estime les densites de Minkowski d'une image binaire
%   la structure est representee par des 1, le fond par des 0
% 
%   See also : MINKOWSKI, minkShell
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%

%   HISTORY :
%   15/06/2004 : rewrite, now adapted from minkShell

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
        error('edge condition dimension does not match image dimension');
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
b = zeros(nbdims, 1);
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
    chi = epc(img) - epc(img(b(1)));
    return;
end

% dimension 2
if ndims(img)==2
    b1 = b(1); b2 = b(2);
    
    % connectivity estimation (chi image - chi boundary)
    chi   = epc(img);
    chi1  = epc(img(b1, :));
    chi2  = epc(img(:,  b2));
    chi12 = epc(img(b1, b2));
    chi = chi - chi1 - chi2 + chi12;
    
elseif ndims(img)==3
        
    b1 = b(1); b2 = b(2); b3 = b(3);

    % connectivity in window
    chi = epc(img);
    
    % connectivity on faces (window boundaries)
    chi1 = epc(squeeze(img(b1,:,:)));
    chi2 = epc(squeeze(img(:,b2,:)));
    chi3 = epc(squeeze(img(:,:,b3)));

    % connectivity on edges (window boundaries)
    chi12 = epc(squeeze(img(b1, b2, :)));
    chi13 = epc(squeeze(img(b1, :, b3)));
    chi23 = epc(squeeze(img(:, b2, b3)));

    % connectivity on corner boundary
    chi123 = epc(img(b1, b2, b3));
    
    % connectivity estimation
    chi = chi - (chi1+chi2+chi3) + (chi12+chi13+chi23) - chi123;
end

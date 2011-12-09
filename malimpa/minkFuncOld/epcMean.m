function chi = epcMean(img, varargin)
%EPCMEAN estimate Euler-Poincare Charac with mean sampling
%
%   Estimate Euler-Poincare characteristic by measuring EPC inside image,
%   then by substracting EPC of the intersection with the window boundary.
%   The edge corrrection is averaged for each border of the window, giving
%   a better estimate as the epcShell.
%
%   See also: EPC, EPCSHELL, MINKMEAN, MINKSHELL
% 
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/09/2003.
%

%   HISTORY
%   15/06/2004 : rewrite, adapted from minkMean
%   24/03/2006 : process error for unknown connectivity
%   09/08/2006 : add support for 8 and 26 connectivities

% input image dimension 
img = squeeze(img);
dim = size(img);
nbDims = length(dim);
if nbDims==2 && dim(2)==1
    nbDims = 1;
end

% set minimal connectivity by default
switch nbDims
    case 2
        conn = 4;
    case 3
        conn = 6;
    otherwise
        conn = 1;
end

    
% extract connectivity information ----------------
if ~isempty(varargin)
    var = varargin{1};
    
    % connectivity given as integer
    if isnumeric(var)
        if nbDims==2 && var==4
            conn = var;
        elseif nbDims==2 && var==8
            conn = var;
        elseif nbDims==3 && var==6
            conn = var;
        elseif nbDims==3 && var==26
            conn = var;
        else
            error('non supported connectivity');
        end
    else
        error('unsupported parameter for connectivity');
    end
end


% init, depending on input variables =====================

% dimension 1
if ndims(img)==2 && (dim(2)==1 || dim(1)==1) 
    chi = epc(img) - (epc(img(1)) + epc(img(dim(1))))/2;
    return;
end

% dimension 2
if ndims(img)==2
    N1 = dim(1); N2 = dim(2);

    if conn==4 || conn==8
        chi     = epc(img, conn);
        chix    = mean([ epc(img(1,:)) epc(img(N1,:)) ]);
        chiy    = mean([ epc(img(:,1)) epc(img(:,N2)) ]);
        chixy   = mean([ ...
                epc(img( 1,  1)), ...
                epc(img(N1,  1)), ...
                epc(img( 1, N2)), ...
                epc(img(N1, N2)) ]);
        chi = chi - chix - chiy + chixy;
    else
        error('sorry, non supported connectivity');
    end
end

% dimension 3
if ndims(img)==3
    
    % upper bounds of image (lower bounds are always 1)
    N1 = dim(1); N2 = dim(2); N3 = dim(3);

    if conn==6
        % connectivity in window
        chi = epc(img, conn);

        % connectivity on faces (window boundaries)
        chi1 = (epc(squeeze(img(1,:,:)),4) + epc(squeeze(img(N1,:,:)),4))/2;
        chi2 = (epc(squeeze(img(:,1,:)),4) + epc(squeeze(img(:,N2,:)),4))/2;
        chi3 = (epc(squeeze(img(:,:,1)),4) + epc(squeeze(img(:,:,N3)),4))/2;

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

        % connectivity estimation
        chi = chi - (chi1+chi2+chi3) + (chi12+chi13+chi23) - chi123;
        
    elseif conn==26
        % connectivity in window
        chi = epc(img, conn);

        % connectivity on faces (window boundaries)
        chi1 = (epc(squeeze(img(1,:,:)),8) + epc(squeeze(img(N1,:,:)),8))/2;
        chi2 = (epc(squeeze(img(:,1,:)),8) + epc(squeeze(img(:,N2,:)),8))/2;
        chi3 = (epc(squeeze(img(:,:,1)),8) + epc(squeeze(img(:,:,N3)),8))/2;

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

        % connectivity estimation
        chi = chi - (chi1+chi2+chi3) + (chi12+chi13+chi23) - chi123;
    else
        error('sorry, non supported connectivity');
    end
end


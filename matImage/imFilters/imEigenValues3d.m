function [lambda1, lambda2, lambda3] = imEigenValues3d(Dxx, Dyy, Dzz, Dxy, Dxz, Dyz)
%IMEIGENVALUES3D Image eigen values from second derivatives
%
%   [LAMBDA1, LAMBDA2, LAMBDA3] = imEigenValues(Dxx, Dyy, Dzz, Dxy, Dxz, Dyz)
%   Compute eigen values from hessian matrix components.
%   Eigen values are ordered in increasing order of absolute values.
%
%   Execution can take long time...
%
%   Example
%   imEigenValues
%
%   See also
%     imHessian

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% allocate memory for result arrays
lambda1 = zeros(size(Dxx));
lambda2 = zeros(size(Dxx));
lambda3 = zeros(size(Dxx));

n = numel(Dxx);
for i = 1:n
    % compute eigen values of current hessian matrix
    ev = eig([Dxx(i) Dxy(i) Dxz(i); Dxy(i) Dyy(i) Dyz(i); Dxz(i) Dyz(i) Dzz(i)]);
    
    % sort eigen values in increasing order of absolute values
    [tmp, inds] = sort(abs(ev)); %#ok<ASGLU>
    
    lambda1(i) = ev(inds(1));
    lambda2(i) = ev(inds(2));
    lambda3(i) = ev(inds(3));
end


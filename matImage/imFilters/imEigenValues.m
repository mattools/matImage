function [lambda1, lambda2] = imEigenValues(gxx, gxy, gyy)
%IMEIGENVALUES Image eigen values from second derivatives
%
%   [LAMBDA1, LAMBDA2] = imEigenValues(Gxx, Gxy, Gyy)
%   Compute eigen values from hessian matrix components.
%   Eigen values are ordered in increasing order of absolute values.
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
lambda1 = zeros(size(gxx));
lambda2 = zeros(size(gxx));

n = numel(gxx);

for i = 1:n
    % compute eigen values of current hessian matrix
    ev = eig([gxx(i) gxy(i) ; gxy(i) gyy(i)]);
    
    % sort eigen values in increasing order of absolute values
    if abs(ev(1)) < abs(ev(2))
        lambda1(i) = ev(1);
        lambda2(i) = ev(2);
    else
        lambda1(i) = ev(2);
        lambda2(i) = ev(1);
    end
end


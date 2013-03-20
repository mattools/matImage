function [lambda1 lambda2] = imEigenValues(gxx, gxy, gyy)
%IMEIGENVALUES Image eigen values from second derivatives
%
%   [LAMBDA1 LAMBDA2] = imEigenValues(Gxx, Gxy, Gyy)
%
%   Example
%   imEigenValues
%
%   See also
%     imHessian
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

lambda1 = zeros(size(gxx));
lambda2 = zeros(size(gxx));

n = numel(gxx);

for i = 1:n
    ev = eig([gxx(i) gxy(i) ; gxy(i) gyy(i)]);
    lambda1(i) = ev(1);
    lambda2(i) = ev(2);
end

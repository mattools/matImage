function [lambda1, lambda2, orient] = imEigenValues(gxx, gxy, gyy)
%IMEIGENVALUES Image eigen values from second derivatives
%
%   [LAMBDA1, LAMBDA2] = imEigenValues(Gxx, Gxy, Gyy)
%   Compute eigen values from hessian matrix components.
%   Eigen values are ordered in increasing order of absolute values.
%
%   [LAMBDA1, LAMBDA2,ORIENT] = imEigenValues(Gxx, Gxy, Gyy)
%   Also return an array with the local orientation, in the direction of
%   the largest eigen value (corresponding to the tangent direction of a
%   curvilinear structure).
%
%   Example
%     % Compute demo image
%     [x, y] = meshgrid(-100:100, -100:100);
%     radius = hypot(x, y);
%     img = radius >= 70 & radius < 90;
%     % compute Hessian matrix and its eigenvalues for each pixel
%     [gxx, gxy, gyy] = imHessian(double(img), 10);
%     [lambda1, lambda2, orient] = imEigenValues(gxx, gxy, gyy);
%     figure; 
%     subplot(121); imshow(lambda1, []);
%     subplot(122); imshow(lambda2, []);
%     % Also display map of orientation, restricted by values of lambda2
%     orient2 = mod(orient + 180, 180);
%     orient2(lambda2 > -1e-3) = NaN;
%     figure; imshow(double2rgb(orient2, hsv, [0 180]));
%
%   See also
%     imHessian

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2013-03-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% allocate memory for result arrays
lambda1 = zeros(size(gxx));
lambda2 = zeros(size(gxx));
n = numel(gxx);

if nargout > 2
    % also compute orientations
    orient = zeros(size(gxx));
    
    for i = 1:n
        % compute eigen values of current hessian matrix
        ev = eig([gxx(i) gxy(i) ; gxy(i) gyy(i)]);
        
        theta = atan2(2 * gxy(i), gxx(i) - gyy(i)) / 2;
        theta = theta * 180 / pi;
        
        % sort eigen values in increasing order of absolute values
        if abs(ev(1)) < abs(ev(2))
            lambda1(i) = ev(1);
            lambda2(i) = ev(2);
            orient(i) = theta + 90;
        else
            lambda1(i) = ev(2);
            lambda2(i) = ev(1);
            orient(i) = theta;
        end
    end
    
else
    
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
    
    
end

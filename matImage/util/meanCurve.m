function res = meanCurve(curves, N)
%MEANCURVE compute average of several curves
%
%   usage :
%   curve = meanCurve(curves, N), with curves being a cell array containing
%   several one dimension array, and N being the number of points of result
%   curve.
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/04/2004.
%

%   HISTORY
%   07/05/2004 : correct bug (divide by Nc at the wrong place)

Nc = length(curves);
res = zeros(N, 1);

% process each curve
for c=1:Nc
    
    % extract curve, and length of the curve
    curve = curves{c};
    NX = length(curve);
    
    % compute sub frames limits
    x0 = floor([1:NX/N:NX NX]);
    %x1 =  ceil([1:NX/N:NX NX]);
    
    % for each point of the new curve, add mean value of current curve,
    % computed on a subframe.
    for x=1:N
        res(x) = res(x) + mean(curve(x0(x):x0(x+1)-1));
    end    

end 

% divide by the number of curves
res = res/Nc;

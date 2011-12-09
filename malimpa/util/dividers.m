function res = dividers(num)
%DIVIDERS compute dividers of an integer
%
%   D = DIVIDERS(NUM)
%   return the list of numbers such that NUM/D(i) is integer, including 1
%   and NUM.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/12/2004.
%

r = num./(1:num);
res = find(r==round(r));

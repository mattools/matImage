function c = cnp(n, p)
%CNP compute combination number of p items in n
%
%   usage :
%   c = cnp(n, p)
%   return the number of possibilities in taking p items from n elements,
%   without ordering of them.
%   Be careful of precision for large (n>20) n.
%
%   Example:
%   cnp(4, 2)       % returns 6
%   cnp(6, 3)       % returns 10
%
%   See also :
%   anp
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 01/04/2005.
%

c = prod((n-p+1):n)/factorial(p);
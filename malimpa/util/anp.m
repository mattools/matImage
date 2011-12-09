function a = anp(n, p)
%ANP compute arrangement number of p items in n
%
%   usage :
%   a = anp(n, p)
%   return the number of possibilities in taking p items from n elements,
%   keeping ordering of them.
%   Be careful of precision for large (n>20) n.
%
%   See also :
%   cnp
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 01/04/2005.
%

a = prod((n-p+1):n);
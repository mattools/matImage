function varargout = histo(X, varargin)
%HISTO compute discrete histograms
%
%   HISTO(X);
%   Draw Histogram of values of X. Each value produces a stem, and the
%   height of each bar correspond to the number of occurences of this
%   value. 
%   
%   N = HISTO(X);
%   compute the number of occurencies of each unique value, does not draw
%   the histogram.
%   
%   [N B] = HISTO(X);
%   compute the number of occurencies of each unique value and return the
%   unique value array B. Does not draw the histogram.
%
%   HISTO(X, ...) 
%   specifies the same options as STEM to draw the histogram.
%
%   See also HIST, HISTC.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 24/09/2004
%

%   HISTORY
%   16/02/2005 : rewrite using unique and stem
%   30/11/2006 : use similar behaviour as hist, and update doc.

% extract unique values
[B, I, J] = unique(X);

% compute occurences of each unique value
N = hist(J, 1:max(J));

if nargout==0
    % if no output argument, display the histogram
    stem(B, N, varargin{:});
else
    % return output arguments
    varargout{1} = N;
    if nargout>1
        varargout{2} = B;
    end
end
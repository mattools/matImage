function subset = randomSubset(set, k)
%RANDOMSUBSET randomly select K individuals from a set
%
%   SUBSET = randomSubset(SET, K)
%   select K different items from the array SET, and put them in the array
%   SUBSET.
%   The number of unique elements of SET must be greater than K.
%
%   Example
%   randomSubset
%
%   See also rand, randn
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2005-11-18
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


Nu = length(unique(set));

if Nu < k
    error('randomSubset : number of unique elements too small');
end

N = length(set(:));

subset=[];
i = 1;
while i <= k
    indi = set(floor(N*rand) + 1);
    if ~ismember(indi, subset)
        subset = [subset indi]; %#ok<AGROW>
        i = i+1;
    end
end

% set the same 'orientation' as set
if size(set, 1) > 1
    subset = subset';
end

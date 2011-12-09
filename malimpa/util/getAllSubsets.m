function subsets = getAllSubsets(elements, varargin)
%GETALLSUBSETS  return all possible subset of a parent set
%
%   SUBSETS = getAllSubsets(SET)
%   Return all subsets which can be formed with elements of SET. SUBSETS is
%   a cell array, with 2^length(SET)-1 elements (it does not contains the
%   empty set).
%   SET must be a vector of numbers.
%
%   SUBSETS = getAllSubsets(SET, P)
%   Specify the cardinality P of the subsets. In this case the result is an
%   array with P columns.
%
%   Example
%   getAllSubsets([1 2 3])
%   Returns : {1, 2, 3, [1 2], [1 3], [2 3], [1 2 3]}
%
%   getAllSubsets([1 2 3 4], 2)
%   Returns : [1 2 ; 1 3 ; 1 4 ; 2 3 ; 2 4 ; 3 4]
%
%   See also
%
%   NOTE:
%   Current implementation can be time-consuming for large data sets
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-04-21
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   24/05/2006 : update doc, and change output format


% default cardinal number of subsets to search
n = length(elements);
orders = 1:n;

% process input arguments
if length(varargin)>0
    orders = varargin{1};
end

% initialize empty arrays, sorted by number of elements
for i=1:length(orders)
    subsets{i} = zeros(0, orders(i));
end

nbSets = 0;

% loop over all possible inclusion/exclusions of all elements.
for i=0:power(2, n)-1
    % work on a binary representation with n digits
    bin = dec2bin(i, n);
    bin = bin(n:-1:1);
    
    % indices of elements to include
    ind = find(bin=='1');
    
    % number of elements to include
    p = length(ind);
    
    % check that we are interested in the sets with p elements
    if ~ismember(p, orders)
        continue;
    end      
    
    % add this subset to the list of subsets with p elements
    sets = subsets{find(orders==p)};
    sets = [sets; elements(ind)];
    subsets{find(orders==p)} = sets;
    nbSets = nbSets + 1;
end


% process output arguments
if length(orders)==1
    subsets = sortrows(sort(subsets{1}, 2));
else
    % subsets are stored in a cell array of [NxP] arrays
    % this converts it to a cell array of subsets.
    sets = cell(1, nbSets);
    n = 1;
    for i=1:length(subsets)
        subset = sortrows(sort(subsets{i}, 2));
        for j=1:size(subset, 1)
            sets{n} = subset(j, :);
            n = n+1;
        end
    end
    subsets = sets;
end

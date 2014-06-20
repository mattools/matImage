function C = concat(A, B, dec, val)
%CONCAT  concatenate two arrays, with shift
%
%   RES = concat(A, B, DEC)
%   concatenate two arrays A and B, by shifting B by the vector DEC, and
%   padding with zeros.
%
%   RES = concat(A, B, DEC, VALUE)
%   pads with the given value
%
%   Example
%   A = zeros(4, 4);
%   B = ones(3, 3);
%   C = concat(A, B, [2 1]); % shifts 2 rows and one column
%   gives:
%   0 0 0 0
%   0 0 0 0
%   0 1 1 1
%   0 1 1 1
%   0 1 1 1
%
%   % concatenate in horizontal direction
%   C = concat(A, B, [0 size(A, 2)]);
%   % concatenate in vertical direction:
%   C = concat(A, B, [size(A, 1) 0]);
%   % concatenate in diagonal:
%   C = concat(A, B, size(A));
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-08-22,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"

%   HISTORY
%   2008/07/02 fix mistake in doc, add process for ND, and pads value


% dimension of input arrays
dimA = size(A);
dimB = size(B);

% check arrays dimension
if length(dimA)~=length(dimB)
    error('arrays must have the same dimension');
end

% ensure that the shift has enough dimension, and pad with zeros
if length(dec)<length(dimA)
    dec(length(dimA)) = 0;
end

% compute dimension of result
dimMin = min(ones(size(dimA)), dec+1);
dimMax = max(dimA, dimB+dec);

% allocate memory for result
dimC = dimMax-dimMin+1;
if islogical(A)
    C = false(dimC);
else
    C = zeros(dimC, class(A));
end

% fill up with given value
if exist('val', 'var')
    C(:) = val;
end

% compute the shift of the 2 arrays in the system of result array
decA = max(zeros(size(dec)), -dec);
decB = max(dec, zeros(size(dec)));

if length(dimA)==2
    % Process 2D case
    
    % limits of A in new array
    A10=decA(1)+1; A11=decA(1)+dimA(1);
    A20=decA(2)+1; A21=decA(2)+dimA(2);

    % limits of B in new array
    B10=decB(1)+1; B11=decB(1)+dimB(1);
    B20=decB(2)+1; B21=decB(2)+dimB(2);

    % fill up new array
    C(A10:A11, A20:A21) = A;
    C(B10:B11, B20:B21) = B;

elseif length(dimA)==3
    % Process 3D case
    
    % limits of A in new array
    A10=decA(1)+1; A11=decA(1)+dimA(1);
    A20=decA(2)+1; A21=decA(2)+dimA(2);
    A30=decA(3)+1; A31=decA(3)+dimA(3);

    % limits of B in new array
    B10=decB(1)+1; B11=decB(1)+dimB(1);
    B20=decB(2)+1; B21=decB(2)+dimB(2);
    B30=decB(3)+1; B31=decB(3)+dimB(3);

    % fill up new array
    C(A10:A11, A20:A21, A30:A31) = A;
    C(B10:B11, B20:B21, B30:B31) = B;
else
    % Process greater dimensional case
    
    % compute limits of each array in result array
    N = length(dec);
    indsA = cell(N,1);
    indsB = cell(N,1);
    for i=1:N
        indsA{i} = (1:dimA(i)) + decA(i);
        indsB{i} = (1:dimB(i)) + decB(i);
    end

    % fill up new array    
    C(indsA{:}) = A;
    C(indsB{:}) = B;
end

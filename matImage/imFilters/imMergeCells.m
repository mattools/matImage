function res = imMergeCells(img, c1, c2)
%IMMERGECELLS merge labeled cell of an image
%
%   Deprecated: use 'imMergeLabels' instead.
%
%   Usage:
%   LBL2 = imMergeCells(LBL, C1, C2);
%   LBL is a label image, C1 and C2 are labels of the 2 cells to merge.
%   The indices of two regions are set to the same value, and the boundary
%   between the 2 regions is also merged to the new region, preserving
%   topology of adjacent regions.
%
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 19/07/2004.
%

warning('imael:deprecated', ...
    'imMergeCells is deprecated, use imMergeLabels instead');

ind = imBoundaryIndices(img, c1, c2);
res = img;
res(img==c2)=c1;
res(ind)=c1;

return;


function varargout = imRAG(img, varargin)
%IMRAG Region adjacency graph of a labeled image
%
%   Usage:
%   ADJ = imRAG(IMG);
%   computes region adjacencies graph of labeled 2D or 3D image IMG. 
%   The result is a N*2 array, containing 2 indices for each couple of
%   neighbor regions. Two regions are considered as neighbor if they are
%   separated by a black   (i. e. with color 0) pixel in the horizontal or
%   vertical direction.
%   ADJ has the format [LBL1 LBL2], LBL1 and LBL2 being vertical arrays the
%   same size.
%
%   LBL1 is given in ascending order, LBL2 is given in ascending order for
%   each LBL1. Ex:
%   [1 2]
%   [1 3]
%   [1 4]
%   [2 3]
%   [2 5]
%   [3 4]
%
%   [NODES, ADJ] = imRAG(IMG);
%   Return two arrays: the first one is a [N*2] array containing centroids
%   of the N labeled region, and ADJ is the adjacency previously described.
%   For 3D images, the nodes array is [N*3].
%   
%   Example  (requires image processing toolbox)
%     % read and display an image with several objects
%     img = imread('coins.png');
%     figure(1); clf;
%     imshow(img); hold on;
% 
%     % compute the Skeleton by influence zones using watershed
%     bin = imfill(img>100, 'holes');
%     dist = bwdist(bin);
%     wat = watershed(dist, 4);
%
%     % compute overlay image for display
%     tmp = uint8(double(img).*(wat>0));
%     ovr = uint8(cat(3, max(img, uint8(255*(wat==0))), tmp, tmp));
%     imshow(ovr);
%
%     % show the resulting graph
%     [n e] = imRAG(wat);
%     for i=1:size(e, 1)
%         plot(n(e(i,:), 1), n(e(i,:), 2), 'linewidth', 4, 'color', 'g');
%     end
%     plot(n(:,1), n(:,2), 'bo', 'markerfacecolor', 'b');
%   
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2004-02-20,  
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

%   History
%   2007-10-12 update doc
%   2007-10-17 add example
%   2010-03-08 replace calls to regionprops by local centroid computation
%   2010-07-29 update doc

%% Initialisations

% convert to double, to avoid repetitive type cast
img = double(img);

% get greatest region label
N = max(img(:));

% size of image
dim = size(img);

% number of dimensions
nd = length(dim);

% initialize array
edges = [];


%% Main processing

if nd==2
	% compute matrix of absolute differences in the first direction
	diff1 = abs(diff(img, 1, 1));
	
	% find non zero values (region changes)
	[i1 i2] = find(diff1);
	
	% delete values close to border
	i2 = i2(i1<dim(1)-1);
	i1 = i1(i1<dim(1)-1);
	
	% get values of consecutive changes
	val1 = diff1(sub2ind(size(diff1), i1, i2));
	val2 = diff1(sub2ind(size(diff1), i1+1, i2));
	
	% find changes separated with 2 pixels
	ind = find(val2 & val1~=val2);
	edges = unique([val1(ind) val2(ind)], 'rows');	
	
    
	% compute matrix of absolute differences in the second direction
	diff2 = abs(diff(img, 1, 2));
	
	% find non zero values (region changes)
	[i1 i2] = find(diff2);
	
	% delete values close to border
	i1 = i1(i2<dim(2)-1);
	i2 = i2(i2<dim(2)-1);
	
	% get values of consecutive changes
	val1 = diff2(sub2ind(size(diff2), i1, i2));
	val2 = diff2(sub2ind(size(diff2), i1, i2+1));
	
	% find changes separated with 2 pixels
	ind = find(val2 & val1~=val2);
	edges = [edges ; unique([val1(ind) val2(ind)], 'rows')];
	
elseif nd==3
    
     % compute matrix of absolute differences in the first direction
	diff1 = abs(diff(img, 1, 1));
	
	% find non zero values (region changes)
	[i1 i2 i3] = ind2sub(size(diff1), find(diff1));
	
	% delete values close to border
	i2 = i2(i1<dim(1)-1);
	i3 = i3(i1<dim(1)-1);
	i1 = i1(i1<dim(1)-1);
	
	% get values of consecutive changes
	val1 = diff1(sub2ind(size(diff1), i1, i2, i3));
	val2 = diff1(sub2ind(size(diff1), i1+1, i2, i3));
	
	% find changes separated with 2 pixels
	ind = find(val2 & val1~=val2);
	edges = unique([val1(ind) val2(ind)], 'rows');	
	
	
	% compute matrix of absolute differences in the second direction
	diff2 = abs(diff(img, 1, 2));
	
	% find non zero values (region changes)
	[i1 i2 i3] = ind2sub(size(diff2), find(diff2));
	
	% delete values close to border
	i1 = i1(i2<dim(2)-1);
	i3 = i3(i2<dim(2)-1);
	i2 = i2(i2<dim(2)-1);
	
	% get values of consecutive changes
	val1 = diff2(sub2ind(size(diff2), i1, i2, i3));
	val2 = diff2(sub2ind(size(diff2), i1, i2+1, i3));
	
	% find changes separated with 2 pixels
	ind = find(val2 & val1~=val2);
	edges = [edges ; unique([val1(ind) val2(ind)], 'rows')];	

    
	% compute matrix of absolute differences in the third direction
	diff3 = abs(diff(img, 1, 3));
	
	% find non zero values (region changes)
	[i1 i2 i3] = ind2sub(size(diff3), find(diff3));
	
	% delete values close to border
	i1 = i1(i3<dim(3)-1);
	i2 = i2(i3<dim(3)-1);
	i3 = i3(i3<dim(3)-1);
	
	% get values of consecutive changes
	val1 = diff3(sub2ind(size(diff3), i1, i2, i3));
	val2 = diff3(sub2ind(size(diff3), i1, i2, i3+1));
	
	% find changes separated with 2 pixels
	ind = find(val2 & val1~=val2);
	edges = [edges ; unique([val1(ind) val2(ind)], 'rows')];
end

% format output to have increasing order of n1,  n1<n2, and
% increasing order of n2 for n1=constant.
edges = sortrows(sort(edges, 2));

% remove eventual double edges
edges = unique(edges, 'rows');


%% Output processing

if nargout == 1
    varargout{1} = edges;
elseif nargout == 2
    % Also compute region centroids
    points = zeros(N, nd);
    labels = unique(img);
    labels(labels==0) = [];
    if nd==2
        % compute 2D centroids
        for i=1:length(labels)
            label = labels(i);
            [iy ix] = ind2sub(dim, find(img==label));
            points(label, 1) = mean(ix);
            points(label, 2) = mean(iy);
        end
    else
        % compute 3D centroids
        for i=1:length(labels)
            label = labels(i);
            [iy ix iz] = ind2sub(dim, find(img==label));
            points(label, 1) = mean(ix);
            points(label, 2) = mean(iy);
            points(label, 3) = mean(iz);
        end
    end
    
    % setup output arguments
    varargout{1} = points;
    varargout{2} = edges;
end

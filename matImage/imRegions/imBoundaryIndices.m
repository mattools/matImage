function ind = imBoundaryIndices(img, c1, c2)
%IMBOUNDARYINDICES Find indices of boundary pixels between 2 regions.
%
%   Usage:
%   IND = imBoundaryIndices(LBL, C1, C2)
%   Identifies pixels which are adjacent to both regions C1 and C2 in
%   labeled image LBL, and returns their indices in image.
%
%   Example:
%   lbl = [1 1 0 2 2;1 1 0 2 2;1 0 2 2 2;1 0 2 2 2];
%   imBoundaryIndices(lbl, 1, 2)
%   ans =
%        7
%        8
%        9
%       10
%
%   See also:
%   watershed, imRAG, imLabelEdges
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 19/07/2004.
%


%   HISTORY
%   2008/10/10 clean-up code, add doc

% initialize array
dim = size(img);

ind1=[];  ind2=[];  ind3=[];
ind01=[]; ind02=[]; ind03=[];

if length(dim)==2
    
	% compute matrix of absolute differences in the first direction
	diff1 = abs(diff(double(img), 1, 1));
	
	% find non zero values (region changes)
	[i1, i2] = find(diff1);
	
	% delete values close to border
	i2 = i2(i1<dim(1)-1);
	i1 = i1(i1<dim(1)-1);
	
	% get values of consecutive changes
	val1 = diff1(sub2ind(size(diff1), i1, i2));
	val2 = diff1(sub2ind(size(diff1), i1+1, i2));
	
	% find changes separated with 2 pixels
	ind = find((val1==c1 & val2==c2) | (val1==c2 & val2==c1));
	
    if ~isempty(ind)
        % select interesting coordinates, corresponding to 0 between two
        % pixels with values cA and c2.
        i11 = i1(ind);  i12 = i2(ind);
       
        % convert coordinates into indices
        ind1 = sub2ind(dim, i11+1, i12);
    end
    
    ind0 = find((val1~=c1 & val1~=c2 & val1>0) | (val2~=c1 & val2~=c2 & val2>0));
    if ~isempty(ind0)
        % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0);
        ind01 = sub2ind(dim, i11+1, i12);
    end
    
    ind0 = find(val1~=c1 & val1~=c2 & val2==0);
    if ~isempty(ind0)
         % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0);
        ind01 = unique([ind01; sub2ind(dim, i11, i12)]);
    end       

    
    
    % compute matrix of absolute differences in the second direction
	diff2 = abs(diff(double(img), 1, 2));
	
	% find non zero values (region changes)
	[i1, i2] = find(diff2);
	
    
	% delete values close to border
	i1 = i1(i2<dim(2)-1);
	i2 = i2(i2<dim(2)-1);
	
	% get values of consecutive changes
	val1 = diff2(sub2ind(size(diff2), i1, i2));
	val2 = diff2(sub2ind(size(diff2), i1, i2+1));

	% find changes separated with 2 pixels
	ind = find((val1==c1 & val2==c2) | (val1==c2 & val2==c1));
    
    if ~isempty(ind)
        % select interesting coordinates, corresponding to 0 between two
        % pixels with values c1 and c2.
        i11 = i1(ind);  i12 = i2(ind);
    
        % convert coordinates into indices    
        ind2 = sub2ind(dim, i11, i12+1);
    end

    ind0 = find((val1~=c1 & val1~=c2 & val1>0) | (val2~=c1 & val2~=c2 & val2>0));
    if ~isempty(ind0)
        % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0);
        ind02 = sub2ind(dim, i11, i12+1);
    end

    ind0 = find(val1~=c1 & val1~=c2 & val2==0);
    if ~isempty(ind0)
         % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0);
        ind02 = unique([ind02; sub2ind(dim, i11, i12)]);
    end       
    
    % reduce number of indices
    ind = unique([ind1;ind2]);
    ind0 = unique([ind01;ind02]);
    
    % consider only indices which do not share boundary with another cell
    ind = ind(~ismember(ind, ind0));
    
elseif length(dim)==3
    
    % compute matrix of absolute differences in the first direction
	diff1 = abs(diff(double(img), 1, 1));
	
	% find non zero values (region changes)
	[i1, i2, i3] = ind2sub(size(diff1), find(diff1));

	% delete values close to border
	i2 = i2(i1<dim(1)-1);
	i3 = i3(i1<dim(1)-1);
	i1 = i1(i1<dim(1)-1);
	
    ind = [];
    if ~isempty(i1)
    	% get values of consecutive changes
    	val1 = diff1(sub2ind(size(diff1), i1, i2, i3));
    	val2 = diff1(sub2ind(size(diff1), i1+1, i2, i3));
	
    	% find changes separated with 2 pixels
    	ind = find((val1==c1 & val2==c2) | (val1==c2 & val2==c1));
    end
    
    
    if ~isempty(ind)
        % select interesting coordinates, corresponding to 0 between two
        % pixels with values cA and c2.
        i11 = i1(ind);  i12 = i2(ind); i13=i3(ind);
       
        % convert coordinates into indices
        ind1 = sub2ind(dim, i11+1, i12, i13);
    end
    
    ind0 = find((val1~=c1 & val1~=c2 & val1>0) | (val2~=c1 & val2~=c2 & val2>0));
    if ~isempty(ind0)
        % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0); i13 = i3(ind0);
        ind01 = sub2ind(dim, i11+1, i12, i13);
    end

    
	% compute matrix of absolute differences in the second direction
	diff2 = abs(diff(double(img), 1, 2));
	
	% find non zero values (region changes)
	[i1, i2, i3] = ind2sub(size(diff2), find(diff2));
	
	% delete values close to border
	i1 = i1(i2<dim(2)-1);
	i3 = i3(i2<dim(2)-1);
	i2 = i2(i2<dim(2)-1);
	
    ind = [];
    if ~isempty(i1)
    	% get values of consecutive changes
	    val1 = diff1(sub2ind(size(diff2), i1, i2, i3));
	    val2 = diff1(sub2ind(size(diff2), i1, i2+1, i3));
	
    	% find changes separated with 2 pixels
    	ind = find((val1==c1 & val2==c2) | (val1==c2 & val2==c1));
    end
    
    
    if ~isempty(ind)
        % convert coordinates into indices
        i11 = i1(ind);  i12 = i2(ind); i13=i3(ind);
        ind1 = sub2ind(dim, i11, i12+1, i13);
    end

    ind0 = find((val1~=c1 & val1~=c2 & val1>0) | (val2~=c1 & val2~=c2 & val2>0));
    if ~isempty(ind0)
        % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0); i13 = i3(ind0);
        ind02 = sub2ind(dim, i11, i12+1, i13);
    end
    
    
    % compute matrix of absolute differences in the third direction
	diff3 = abs(diff(double(img), 1, 3));
	
	% find non zero values (region changes)
	[i1, i2, i3] = ind2sub(size(diff3), find(diff3));
	
	% delete values close to border
	i1 = i1(i3<dim(3)-1);
	i2 = i2(i3<dim(3)-1);
	i3 = i3(i3<dim(3)-1);
	
    ind = [];
    if ~isempty(i1)
    	% get values of consecutive changes
    	val1 = diff1(sub2ind(size(diff3), i1, i2, i3));
    	val2 = diff1(sub2ind(size(diff3), i1, i2, i3+1));
	
    	% find changes separated with 2 pixels
    	ind = find((val1==c1 & val2==c2) | (val1==c2 & val2==c1));
    end
    
    if ~isempty(ind)
        % convert coordinates into indices
        i11 = i1(ind);  i12 = i2(ind); i13=i3(ind);
        ind1 = sub2ind(dim, i11, i12, i13+1);
    end

    ind0 = find((val1~=c1 & val1~=c2 & val1>0) | (val2~=c1 & val2~=c2 & val2>0));
    if ~isempty(ind0)
        % convert coordinates into indices    
        i11 = i1(ind0);  i12 = i2(ind0); i13 = i3(ind0);
        ind03 = sub2ind(dim, i11, i12, i13+1);
    end
    
    
    % reduce number of indices
    ind = unique([ind1;ind2;ind3]);
    ind0 = unique([ind01;ind02;ind03]);
    
    % consider only indices which do not share boundary with another cell
    ind = ind(~ismember(ind, ind0));

end

return;


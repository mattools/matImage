function varargout = imLabelEdges(img, varargin)
%IMLABELEDGES Label edges between adjacent regions of labeled image.
%
%   usage:
%   LBL = imLabelEdges(IMG, SE)
%   Return a new image the same dimensions as labeled image IMG, containig
%   zeros everywhere but at boundaries between 2 labels of IMG. The value
%   of the label of the edge is the index of array as defined by IMRAG
%   function (called with the same structuring element).
%
%   If no structuring element is specified, a STREL('DIAMOND', 2) is used as
%   default. It works fine for results of watershed with 4-connectivity.
%
%   [LBL EDGES] = imLabelEdges(IMG, SE)
%   Also return Adjacency graph of image. EDGES is a [NE*2] array, with NE
%   being the number of edges in the image (the max value of LBL).
%   Each line of EDGES contains indices of the two regions adjacent to
%   edge whose index is number of line.
%
%
%   See also:
%   watershed, imRAG, imBoundaryIndices
%
%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 20/02/2004.
%

%   HISTORY
%   24/02/2004 : add doc for 2 arguments in output.


% count number of regions
N = double(max(img(:)));

% if no points or no edges, initialize arrays
edges = [];

labels = uint16(zeros(size(img)));

% compute structuring element
se = strel('diamond', 2);
if ~isempty(varargin)
    se = varargin{1};
end

se1 = strel('diamond', 1);

%TODO: could maybe use faster algorithm ?
for c=1:N
    %evite d'afficher progression : economise 60% du temps ....
    %disp(sprintf('cell : %d', c));
       
    % find neighbours whose label is superior to current label
    lbl = intersect(c+1:N, unique(immultiply(img, imdilate(img==c, se))));
    
    for c2 = 1:length(lbl)
        limit = imdilate(img==c, se1) & imdilate(img==lbl(c2), se1);
        edges(size(edges, 1)+1, 1:2) = [c lbl(c2)]; %#ok<AGROW>
        labels(limit) = size(edges, 1);
    end
end



if nargout == 1
    varargout{1} = labels;
end

if nargout == 2
    varargout{1} = labels;
    varargout{2} = edges;
end


return;


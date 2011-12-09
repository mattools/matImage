function points = detectePoints2(img)
%DETECTEPOINTS2 detect triple points of boundary in a labeled image
%
%   POINTS = DETECTEPOINTS2(LABELS) returns coordinates of points whose
%   label is zero (belonging to background), and whose [3*3] neigbourhood
%   contains 3 different labels. These points are considered as triple
%   points of the skeletoon boundary.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation


% recup taille image
dim = size(img);

points = [];
nbpoints = 0;


% itere sur chaque pixel
for y=2:dim(1)-1
    for x=2:dim(2)-1
        % consider only points on boundary
        if img(y,x)~=0
            continue;
        end
        
        % at least 3 different labels, plus zero => strict greater than 3
        if length(unique(img(y-1:y+1, x-1:x+1))) > 3
            nbpoints = nbpoints + 1;
            points(nbpoints, 1) = x;
            points(nbpoints, 2) = y;
        end
    end
end


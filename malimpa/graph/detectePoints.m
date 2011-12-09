function points = detectePoints(img)
%DETECTEPOINTS detect triple points in a binary image
% detecte le nombre de points triples dans une image squeletisee.
% l'image d'entree doit etre bianire : 0->fond, 1->squelette.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation

% binarization (au cas ou...)
img = img~=0;

% recup taille image
dim = size(img);

points = [];
nbpoints = 0;


% itere sur chaque pixel
for y=2:dim(1)-1
    for x=2:dim(2)-1
        if img(y,x)==0
            continue;
        end
        vois = img(y-1:y+1, x-1:x+1);
        if sum(sum(vois))>3
            nbpoints = nbpoints + 1;
            points(nbpoints, 1) = x;
            points(nbpoints, 2) = y;
        end
    end
end


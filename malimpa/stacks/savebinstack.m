function savebinstack(bin, fname)
%SAVEBINSTACK Save an binary stack to a file, as RGB Image.
%
%  if file name contains '??', then image is saved into a serie
%  of files, with increasing index.
%
%   See also:
%   savestack, imread
%
%   ---------
%   author: David Legland, david.legland(at)grignon.inra.fr
%   INRA - Cepia Software Platform
%   created the 10/09/2003.
%   http://www.pfl-cepia.inra.fr/index.php?page=slicer
%   Licensed under the terms of the new BSD license, see file license.txt

dim = size(bin);

pos = strfind(fname, '??');
if ~isempty(pos)
    % save a serie file, one file per slice of images
    disp('save slices - not yet implemented');
    
else
    % save one file containing all slices of image
    disp('save a stack');
    if length(dim)==3
        img = uint8(zeros([dim(1) dim(2) 3]));
        for i=1:dim(3)
            img(:,:,1) = uint8(bin(:,:,i)*255);
            img(:,:,2) = uint8(bin(:,:,i)*255);
            img(:,:,3) = uint8(bin(:,:,i)*255);
            imwrite(img, fname, 'tif', 'Compression', 'none', ...
                'WriteMode', 'append');
        end
    else
        for i=1:dim(4)
            imwrite(bin(:,:,:,i), fname, 'tif', 'Compression', 'none', ...
                'WriteMode', 'append');
        end
    end
end
    

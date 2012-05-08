% IMSTACKS Manipulation and display of 3D images
% Version 1.1 01-Jul-2011 .
%
% Interactive Display
%   Slicer         - GUI for exploration of 3D images, using Object Oriented Programming
%   OrthoSlicer3d  - Display 3D interactive orthoslicer
%   orthoSlices    - Display three orthogonal slices in the same figure
%
% Visualisation routines
%   orthoSlices3d  - Show three orthogonal slices of a 3D image
%   slice3d        - Show a moving 3D slice of an image
%   showXSlice     - Show YZ slice of a 3D image
%   showYSlice     - Show ZX slice of a 3D image
%   showZSlice     - Show XY slice of a 3D image
%
% Read/Write 3D images
%   readstack      - Read either a list of 2D images (slices), or a 3D image
%   savebinstack   - Save an binary stack to a file, as RGB Image.
%   savestack      - Save an image stack to a file or a serie of files
%
% Read/Write images in MetaImage format (used by ITK)
%   metaImageInfo  - Read information header of meta image data
%   metaImageRead  - Read an image in MetaImage format
%   metaImageWrite - Write header and data files of an image in MetaImage format
%
% Get information on 3D images
%   stackSize      - Compute the size of a 3D stack in [x y z] form
%   stackExtent    - Compute the physical extent of a 3D image
%   isColorStack   - Check if a 3D stack is color or gray-scale
%
% Manipulation of 3D images
%   createRGBStack - Concatenate 2 or 3 grayscale stacks to form a color stack
%   stackSlice     - Extract a planar slice from a 3D image
%   stackRotate90  - Rotate a 3D image by 90 degrees around one image axis
%   rotateStack90  - Rotate a 3D image by 90 degrees around one image axis
%   flipStack      - Flip a 3D image along specified X, Y, or Z dimension
%
% -----
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the  07/11/2005.
% Copyright INRA - Cepia Software Platform.
% http://www.pfl-cepia.inra.fr/index.php?page=slicer

%


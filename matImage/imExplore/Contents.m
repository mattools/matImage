% IMSTACKS Manipulation and display of 3D images
% Version 1.1 01-Jul-2011 .
%
% Interactive Display
%   Slicer              - GUI for exploration of 3D images, using Object Oriented Programming.
%   OrthoSlicer3d       - Display 3D interactive orthoslicer
%   orthoSlices         - Display three orthogonal slices in the same figure
%
% Visualisation routines
%   orthoSlices3d       - Show three orthogonal slices of a 3D image
%   slice3d             - Show a moving 3D slice of an image
%   showXSlice          - Show YZ slice of a 3D image
%   showYSlice          - Show ZX slice of a 3D image
%   showZSlice          - Show XY slice of a 3D image
%
% Read/Write 3D images
%   readstack           - Read either a list of 2D images (slices), or a 3D image.
%   imFileInfo          - Generalization of the imfinfo function
%   imReadRawData       - Read image data from raw data file.
%   imReadRegion3d      - Read a specific 3D region of a 3D image
%   imReadDownSampled3d - Read a down-sampled version of a 3D image
%   savebinstack        - Save an binary stack to a file, as an RGB Image.
%   savestack           - Save a 3D image into a file or a series of files.
%   metaImageInfo       - Read information header of meta image data
%   metaImageRead       - Read image data stored in MetaImage format (MHD).
%   metaImageWrite      - Save image data using MetaImage file format (MHD).
%   readVgiStack        - Read a 3D stack stored in VGI format
%   vgiStackInfo        - Read information necessary to load a 3D stack in VGI format
%   readVoxelMatrix     - Read a 3D image in VoxelMatrix (.vm) format
%
% Get information on 3D images
%   stackSize           - Compute the size of a 3D stack in [x y z] form
%   stackExtent         - Compute the physical extent of a 3D image
%   isColorStack        - Check if a 3D stack is color or gray-scale
%
% Manipulation of 3D images
%   createRGBStack      - Concatenate 2 or 3 grayscale stacks to form a color stack
%   stackSlice          - Extract a planar slice from a 3D image
%   stackRotate90       - Rotate a 3D image by 90 degrees around one image axis
%   rotateStack90       - Rotate a 3D image by 90 degrees around one image axis
%   flipStack           - Flip a 3D image along specified X, Y, or Z dimension
%   cropStack           - Crop a 3D image with the specified box limits
%   imMiddleSlice       - Extract the middle slice of a 3D stack
%
%
% Author: David Legland
% e-mail: david.legland@inra.fr
% Copyright INRA - Cepia Software Platform.
% http://github.com/mattools/matImage
% http://www.pfl-cepia.inra.fr/index.php?page=slicer

%
% Some GUI Classes used by Slicer
%   CropStackDialog               - Open a dialog for cropping 3D stacks.
%   IsosurfaceOptionsDialog       - Dialog for 3D isosurfaces of intensity images
%   LabelIsosurfacesOptionsDialog - Open a dialog for 3D label isosurfaces
%   OrthoSlicer3dOptionsDialog    - Open a dialog for 3D orthoslices display
%   SlicerHistogramDialog         - Open a dialog to setup image histogram display options

%

MatImage is a Matlab library for analysis and processing of digital images.
It contains functions for processing, analysis, and exploration of 2D, 3D, 
grayscale or color images. It is built as a complement to the Image Processing
Toolbox (IPT), and provides additional features as well as integration of IPT
functions into more elaborate functions.

To install the library, with all sub-directories, run the script 'installMatImage.m'. 

The library is organised into several modules.
* imFilters       - Image filtering (smooth, enhance, gradient...)
* imMeasures      - Measurement of various parameters in digital images
* imShapes        - Generation of images representing geometric shapes
* imStacks        - Functions for manipulation and display of 3D images
* imMinkowski     - Geometric measures (Surface, Perimeter...) in 2D or 3D
* imGeodesics     - Propagation of geodesic distances in images
* util            - General purpose functions
A comprehensive help is provided in each module directory.

Some functions need the "MatGeom" library, also available on sourceforge 
(http://matgeom.sourceforge.net/)

Official homepage for the MatImage project is http://matimage.sourceforge.net/.

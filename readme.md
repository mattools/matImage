MatImage is a Matlab library for analysis and processing of digital images.
It contains functions for processing, analysis, and exploration of 2D, 3D, 
grayscale or color images. It is built as a complement to the Image Processing
Toolbox (IPT), and provides additional features as well as integration of IPT
functions into more elaborate functions.

Official homepage for the MatImage project is http://github.com/dlegland/matImage.

Installation
---
To install the library, with all sub-directories, run the script 'installMatImage.m'. 
This will add all required directories to the current path variable.

Some functions need the "MatGeom" library, also available on GitHub 
(http://github.com/dlegland/matGeom)


Package prganization
---

The library is organised into several modules.
* imFilters       - Image filtering (smooth, enhance, gradient...)
* imMeasures      - Measurement of various parameters in digital images
* imShapes        - Generation of phantom images representing geometric shapes
* imStacks        - Functions for manipulation and display of 3D images
* imMinkowski     - Geometric measures (Surface area, Perimeter...) in 2D or 3D
* imGeodesics     - Geodesic distance transform for 2D/3D binary images
* imGranulometry  - Computation of gray-level granulometry curves with mathematical morphology
* util            - General purpose functions
A comprehensive help is provided in each module directory.



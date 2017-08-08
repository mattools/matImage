MatImage is a Matlab library for analysis and processing of digital images.
It contains functions for processing, analysis, and exploration of 2D, 3D, 
grayscale or color images. It is built as a complement to the Image Processing
Toolbox (IPT), and provides additional features as well as integration of IPT
functions into more elaborate functions.

Official homepage for the MatImage project is http://github.com/mattools/matImage.
A starting help is provided in the [MatImage wiki](https://github.com/mattools/matImage/wiki "MatImage Wiki homepage")

Installation
---
To install the library, with all sub-directories, run the script 'installMatImage.m'. 
This will add all required directories to the current path variable.

Some functions need the "MatGeom" library, also available on GitHub 
(http://github.com/mattools/matGeom)

Library organization
---

The library is organised into several modules.
* [imFilters](https://github.com/mattools/matImage/wiki/imFilters "imFilters Wiki page")       - Image filtering (smooth, enhance, gradient...)
* [imMeasures](https://github.com/mattools/matImage/wiki/imMeasures "imMeasures Wiki page")      - Measurement of various parameters in digital images
* [imStacks](https://github.com/mattools/matImage/wiki/imStacks "imStacks Wiki page")       - Functions for manipulation and display of 3D images
* [imMinkowski](https://github.com/mattools/matImage/wiki/imMinkowski "imMinkowski Wiki page")     - Geometric measures (Surface area, Perimeter...) in 2D or 3D
* [imGeodesics](https://github.com/mattools/matImage/wiki/imGeodesics "imGeodesics Wiki page")     - Geodesic distance transform for 2D/3D binary images
* [imGranulometry](https://github.com/mattools/matImage/wiki/imGranulometry "imGranulometry Wiki page")  - Computation of gray-level granulometry curves with mathematical morphology
* [imShapes](https://github.com/mattools/matImage/wiki/imShapes "imShapes Wiki page")        - Generation of phantom images representing geometric shapes
* [util](https://github.com/mattools/matImage/wiki/util "image utilities Wiki page")            - General purpose functions
A more specific help is provided in each module directory.




% IMMINKOWSKI Geometric measures (Surface, Perimeter, Euler...) in 2D and 3D images
% Version 1.2 09-Nov-2011 .
%
%   Contains various functions for measuring or estimating geometric
%   quantities from 2D or 3D images.
%   For 2D images, parameters are the area, the perimeter and the (2D)
%   Euler Number. 
%   For 3D images, parameters are the volume, the surface area (called
%   surface), the mean breadth (also known as integral of mean curvature),
%   and the (3D) Euler Number.
%   For the sake of completeness, parameters for 1D images are also
%   included: length and number (1D Euler Number).
%
%   Several functions are provided for each parameter, depending on how the
%   parameter is considered:
%   * im<Param>: global measure of the parameter in the whole image. If the
%       structure touches the border of the image, it is considered as a
%       structure border.
%       Such functions should fit most needs.
%   * im<Param>Estimate: estimation of the parameter by considering image
%       is a representative window of a larger structure. Interesection of
%       the structure with iamge border are not taken into account for
%       measurements.
%   * im<Param>Density: Same as im<Param>Estimate, but the result is
%       normalised by the area or volume of the observed window.
%
%   Most functions work both for binary and label images. It is possible to
%   specify options (connectivity for Euler Number, number of directions
%   for perimeter or surface area), as well as image resolution in each
%   direction.
%
%   Examples
%     % compute perimeter of several coins 
%     lbl = bwlabel(imread('coins.png') > 100);
%     imPerimeter(lbl)
%     ans = 
%       184.8668
%       154.9495
%       185.1921
%       267.1690
%       187.3183
%       179.5038
%       182.7406
%       180.8445
%       155.5049
%       155.5049
% 
%     % Surface area measured in 3D binary image (result in pixel^2)
%     img = analyze75read(analyze75info('brainMRI.hdr'));
%     bin = imclose(img>0, ones([5 5 3]));
%     S = imSurface(bin, [1 1 2.5])      % specify resolution
%     ans = 
%         2.7291e+004
%
%
%  Perimeter in 2D images
%   imPerimeter         - Perimeter of a 2D image using Crofton formula
%   imPerimeterDensity  - Perimeter density of a 2D binary structure, using Crofton formula
%   imPerimeterEstimate - Perimeter estimate of a 2D binary structure
%
%  Area in 2D images
%   imArea              - Compute area of binary 2D image 
%   imAreaDensity       - Compute area density in a 2D image
%   imAreaEstimate      - Estimate area of binary 2D structure with edge correction
%
%  Euler-Poincare characteristic in 2D images
%   imEuler2d           - Euler number of a binary 2D image
%   imEuler2dDensity    - Euler density in a 2D image
%   imEuler2dEstimate   - Estimate Euler number in a 2D image
%
%  Volume in 3D images
%   imVolume            - Volume measure of a 3D binary structure
%   imVolumeDensity     - Compute volume density of a 3D image
%   imVolumeEstimate    - Estimate volume of a 3D binary structure with edge correction
%
%  Surface area in 3D images
%   imSurface           - Surface area measure of a binary 3D structure
%   imSurfaceDensity    - Surface area density of a 3D binary structure
%   imSurfaceEstimate   - Estimate surface area of a binary 3D structure
%
%  Mean breadth (integral of mean curvature) in 3D images
%   imMeanBreadth       - Global mean breadth in 3D image
%
%  Euler-Poincare characteristic in 3D images
%   imEuler3d           - Euler number of a binary 3D image
%   imEuler3dDensity    - Compute Euler density in a 3D image
%   imEuler3dEstimate   - Estimate Euler number in a 3D image
%
%  Euler-Poincare characteristic and length in 1D images
%   imEuler1d           - Compute Euler number of a binary 1D image
%   imEuler1dEstimate   - Compute Euler number of a binary 1D image
%   imLength            - Compute total length of a binary 1D structure
%   imLengthDensity     - Estimate length density of a binary 1D structure using edge correction
%   imLengthEstimate    - Estimate total length  of a binary 1D structure using edge correction
%
% 
% References
% If you use this package, please be kind to cite following reference:
%   "Computation of Minkowski measures on 2D and 3D binary images". 
%   David Legland, Kien Kieu and Marie-Francoise Devaux (2007)
%   Image Analysis and Stereology, Vol 26(2), June 2007
%   web: http://www.ias-iss.org/ojs/IAS/article/view/811
% 
% Following reference can also be of interest:
%   "Statistical Analysis of Microstructures in Material Sciences"
%   Joachim Ohser and Frank Muecklich (2000)
%   John Wiley and Sons
% 
%
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Copyright 2011 INRA - Cepia Software Platform.

%% under development
%   imSurfaceLut        - Look-Up Table for computing surface of 3D image

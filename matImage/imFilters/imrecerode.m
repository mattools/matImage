function res = imrecerode(img, h, varargin)
%IMRECERODE Perform a morphological reconstruction by erosion
%
%   usage:
%   RES = imrecerode(IMG, H)
%   performs morphological reconstruction by erosion of img+h over img.
%
%   RES = imrecerode(IMG, H, CONN)
%   specifies connectivity, by default 8 or 26, depending on image
%   dimension
%

% Process input arguments
if length(size(img))==3
    conn = 26;
else
    conn = 8;
end

if ~isempty(varargin)
    conn=varargin{1};
end

% apply reconstruction
marker = imcomplement(img);
res = imcomplement(imreconstruct(marker, imadd(marker, h), conn));
function varargout = mlMatShow(Matrix,boxsize)

% Usage: [MatrixOut] = mlMatShow(Matrix,boxsize)
% 
% Displays a matrix as an image, with each cell being [boxsize x boxsize]
% pixels. This is one line of code. Sheer laziness.  
% 
% Created by ML 2008.04.04

Im = imresize(Matrix,boxsize,'box');
imshow(Im,[])

if nargout
    varargout{1} = Im;
end
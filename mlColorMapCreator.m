function [cMap] = mlColorMapCreator(InterpColors,nValues)

% Usage: [cMap] = mlColorMapCreator(InterpColors,nValues)
% 
% Creates a color map - of size [sum(nValues) x 3], interpolating nValues 
% between each of the colors in InterpColors. Colors should all be in the
% range of 0-1.
% 
% Created by ML 2009.??.??

if ~nargin
    InterpColors = [0,0,1;1,1,0;1,0,0];
    nValues = [10,10]; % Must be one shorter than length of InterpColors (3-1 = 2, here)
end


cMap = [];
for i = 1:size(InterpColors,1)-1
    if i>1
        nValues(i) = nValues(i)+1;
    end
    Tmp = [linspace(InterpColors(i,1),InterpColors(i+1,1),nValues(i));...
           linspace(InterpColors(i,2),InterpColors(i+1,2),nValues(i));...
           linspace(InterpColors(i,3),InterpColors(i+1,3),nValues(i))]';
    if i>1
        cMap = [cMap;Tmp(2:end,:,:)];
    else
        cMap = [cMap;Tmp];
    end
end

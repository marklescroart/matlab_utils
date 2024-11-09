% mlGLColorMaker
% 
% Simple script to transfer contents of MLColors.mat (in 0-255 RGB triples)
% to MLColorsOpenGL (in 0-1 RGB triples)

clear all;

load MLColors.mat

ColorStruct = who;

for ii = 1:length(ColorStruct)
    ColorTemp = ColorStruct{ii};
    GLCol.(ColorTemp) = eval([ColorTemp '/255']);
    clear(ColorStruct{ii});
end

clear ColorStruct
clear ColorTemp
clear ii

save MLColorsOpenGL.mat GLCol

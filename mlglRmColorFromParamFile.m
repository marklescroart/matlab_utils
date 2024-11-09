function mlglRmColorFromParamFile(fName)

% Usage: mlglRmColorFromParamFile(fName)

load(fName)
%load MLColorsOpenGLBRIGHT.mat
%load MLColorsOpenGL

Shapes = fieldnames(Params);
%Colors = [170 170 170; 185 185 185; 200 200 200; 215 215 215];
%Colors = fieldnames(GLCol);
%Colors = GLCol.Gold; %[111 111 111];
%nCols = size(Colors,1);
%ColMixer = randperm(nCols);
%Count = 1;

for iField = 1:length(Shapes)
    for iLL = 1:length(Params.(Shapes{iField}))
        ParamsNew.(Shapes{iField})(iLL) = rmfield(Params.(Shapes{iField})(iLL),'Color');
    end
end

Params = ParamsNew;

save(fName,'Params')
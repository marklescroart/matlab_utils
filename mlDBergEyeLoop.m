% Loop for dberg's markEye only

path = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/MRI_GlobFeat/SJ_08_07_07/EyeData/';
SubjInits = 'SJ';

MarkupDir = dir([path SubjInits '*.reyeS']);

for iMkUp = 1:length(MarkupDir)
    markEye([path MarkupDir(iMkUp).name],'sf',240,'autosave',1,'ppd',[43 43],'sac-minamp',1);
end; clear iMkUp;

return
function NeedsFn = mlDependencyCheck(FnName)

NeededDirs = depdir(FnName);

NeededDirs = grep(NeededDirs,'-v','/Applications/MATLAB74/toolbox/matlab/');


VTCs = mlStructExtract(dir('*.vtc'),'name');
RTCs = mlStructExtract(dir('LOST*.rtc'),'name');
VOI = mlStructExtract(dir('../Anatomical/*voi'),'name');
VOI = ['../Anatomical/' VOI{1}];
nPoints = 10;
aa = importdata('ConditionNames.txt');
for ii = 1:length(aa); for jj = 1:nPoints; VarNames{jj+10*(ii-1)} = [aa{ii} '_' num2str(jj-1)]; end; end
VarNames(2:end+1) = VarNames;
VarNames{1} = 'MRI Signal';

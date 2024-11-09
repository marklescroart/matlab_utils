function mlBV_VTCListMaker(VTCdir,SubNm)

% Call (in a given directory) to make a text file list of all the VTC files 
% in that directory

if ~nargin || ~ischar(SubNm)
    error('Please give me a directory where the vtcs are and a string for a subject ID.')
end

VTCfiles = mlStructExtract(dir([VTCdir,'*',SubNm,'*.vtc']),'name');
VTCfiles = mlAddToCell(VTCfiles,VTCdir,true);

% fid = 1; % To test below lines, uncomment this and comment out next:
fid = fopen([SubNm '_VTCs.txt'],'w');
fprintf(fid,'%.0f\n',length(VTCfiles));
for ii = 1:length(VTCfiles)
    fprintf(fid,'%s\n',VTCfiles{ii});
end

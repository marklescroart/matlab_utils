function mlBV_PRTListMaker(PRTdir,SubID,PRTPrefix,AddOn)

% Usage: mlBV_PRTListMaker(PRTdir,SubID,PRTPrefix,AddOn)
% 
% Call (in a given directory) to make a text file list of all the PRT files 
% in that directory starting with PRTPrefix

if nargin < 2
    error('You stupid. Check the usage, please.')
end
if ~exist('PRTPrefix','var')
    PRTPrefix = [];
end
if ~exist('AddOn','var')
    AddOn = [];
end

PRTfiles = mlStructExtract(dir([PRTdir,PRTPrefix,'*.prt']),'name');
PRTfiles = mlAddToCell(PRTfiles,PRTdir,true);

sName = [SubID AddOn '_PRTs.txt'];
fprintf('File Name = %s\n\n',sName);

% fid = 1; % To test below lines, uncomment this and comment out next:
fid = fopen(sName,'w');
fprintf(fid,'%.0f\n',length(PRTfiles));
for ii = 1:length(PRTfiles)
    fprintf(fid,'%s\n',PRTfiles{ii});
end
